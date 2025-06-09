from fastapi import APIRouter, HTTPException
from config import get_db
from websocket_manager import ConnectionManager
from models.schemas import TaskSubmission
from firebase_admin import firestore
import logging

logger = logging.getLogger(__name__)
game_router = APIRouter()
db = get_db()

@game_router.get("/student/{user_id}/progress")
async def get_student_progress(user_id: str):
    try:
        student_doc = db.collection('students').document(user_id).get()
        student_data = student_doc.to_dict()
        # Get all completed tasks
        tasks = db.collection('completed_tasks').where('student_id', '==', user_id).get()
        completed_tasks = []
        total_stars = 0
        for task in tasks:
            task_data = task.to_dict()
            completed_tasks.append({
                'level_id': task_data['level_id'],
                'task_id': task_data['task_id'],
                'completed_at': task_data['completed_at']
            })
            total_stars += 1  # Each task = 1 star
        return {
            'nickname': student_data.get('nickname'),
            'total_stars': total_stars,
            'completed_tasks': completed_tasks
        }
    except Exception as e:
        logger.error(f"Error getting student progress: {str(e)}")

@game_router.post("/task/submit")
async def submit_task(submission: TaskSubmission):
    try:
        student_doc = db.collection('students').document(submission.user_id).get()
        student_data = student_doc.to_dict()
        # Check if task already completed
        task_doc_id = f"{submission.user_id}_{submission.level_id}_{submission.task_id}"
        existing_task = db.collection('completed_tasks').document(task_doc_id).get()
        if existing_task.exists:
            raise HTTPException(status_code=400, detail="Task already completed")
        
        # Save completed task
        db.collection('completed_tasks').document(task_doc_id).set({
            'student_id': submission.user_id,
            'level_id': submission.level_id,
            'task_id': submission.task_id,
            'completed_at': firestore.SERVER_TIMESTAMP
        })
        
        # Calculate new total stars
        user_tasks = db.collection('completed_tasks').where('student_id', '==', submission.user_id).get()
        total_stars = len(list(user_tasks))
        # Broadcast score update
        score_update = {
            'user_id': submission.user_id,
            'nickname': student_data.get('nickname'),
            'level_id': submission.level_id,
            'task_id': submission.task_id,
            'total_stars': total_stars
        }
        await ConnectionManager.broadcast_score_update(score_update)
        # Broadcast updated leaderboard
        leaderboard = await get_current_leaderboard()
        await ConnectionManager.broadcast_leaderboard_update(leaderboard)
        return {
            'message': 'Task completed',
            'total_stars': total_stars
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error submitting task: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@game_router.get("/leaderboard/top5")
async def get_leaderboard_top5():
    try:
        leaderboard = await get_current_leaderboard()
        return {"top5": leaderboard}
    except Exception as e:
        logger.error(f"Error getting leaderboard: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

async def get_current_leaderboard():
    try:
        # Get all completed tasks and count per student
        tasks = db.collection('completed_tasks').get()
        user_scores = {}
        for task in tasks:
            task_data = task.to_dict()
            student_id = task_data.get('student_id')
            if student_id not in user_scores:
                user_scores[student_id] = 0
            user_scores[student_id] += 1
        # Get student nicknames
        leaderboard = []
        for student_id, total_stars in user_scores.items():
            student_doc = db.collection('students').document(student_id).get()
            if student_doc.exists:
                student_data = student_doc.to_dict()
                leaderboard.append({
                    'user_id': student_id,
                    'nickname': student_data.get('nickname'),
                    'total_stars': total_stars
                })
        leaderboard.sort(key=lambda x: x['total_stars'], reverse=True)
        return leaderboard[:5]
        
    except Exception as e:
        logger.error(f"Error getting leaderboard: {str(e)}")
        return []