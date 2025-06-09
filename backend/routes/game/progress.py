from fastapi import APIRouter, HTTPException
from config import get_db

progress_router = APIRouter()
db = get_db()

@progress_router.get("/student/{user_id}/progress")
async def get_student_progress(user_id: str):
    try:
        student_doc = db.collection('students').document(user_id).get()
        if not student_doc.exists:
            raise HTTPException(status_code=404, detail="Student not found")
        student_data = student_doc.to_dict()

        tasks = db.collection('completed_tasks').where('student_id', '==', user_id).get()
        completed = [{
            'level_id': t.get('level_id'),
            'task_id': t.get('task_id'),
            'completed_at': t.get('completed_at')
        } for t in map(lambda x: x.to_dict(), tasks)]

        return {
            'nickname': student_data.get('nickname'),
            'total_stars': len(completed),
            'completed_tasks': completed
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))