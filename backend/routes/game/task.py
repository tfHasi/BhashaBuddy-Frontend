from fastapi import APIRouter, HTTPException
from firebase_admin import firestore
from config import get_db
from models.schemas import TaskSubmission
from websocket_manager import manager
from .leaderboard import get_current_leaderboard

task_router = APIRouter()
db = get_db()

@task_router.post("/task/submit")
async def submit_task(submission: TaskSubmission):
    try:
        student_ref = db.collection('students').document(submission.user_id)
        student_doc = student_ref.get()
        if not student_doc.exists:
            raise HTTPException(status_code=404, detail="Student not found")

        task_id = f"{submission.user_id}_{submission.level_id}_{submission.task_id}"
        if db.collection('completed_tasks').document(task_id).get().exists:
            raise HTTPException(status_code=400, detail="Task already completed")

        db.collection('completed_tasks').document(task_id).set({
            'student_id': submission.user_id,
            'level_id': submission.level_id,
            'task_id': submission.task_id,
            'completed_at': firestore.SERVER_TIMESTAMP
        })

        total_stars = len(db.collection('completed_tasks').where('student_id', '==', submission.user_id).get())

        await manager.broadcast_score_update({
            'user_id': submission.user_id,
            'nickname': student_doc.to_dict().get('nickname'),
            'level_id': submission.level_id,
            'task_id': submission.task_id,
            'total_stars': total_stars
        })

        leaderboard = await get_current_leaderboard()
        await manager.broadcast_leaderboard_update(leaderboard)

        return {"message": "Task completed", "total_stars": total_stars}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))