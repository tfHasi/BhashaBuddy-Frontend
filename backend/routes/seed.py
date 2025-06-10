from fastapi import APIRouter
from config import get_db

admin_router = APIRouter()
db = get_db()

@admin_router.post("/admin/init_levels_tasks")
async def init_levels_and_tasks():
    for level_num in range(1, 7):  # Levels 1 to 6
        level_id = f"level_{level_num}"
        
        # Create level document
        db.collection('levels').document(level_id).set({
            'name': f'Level {level_num}',
            'order': level_num
        })

        # Create 3 tasks for each level
        for task_num in range(1, 4):
            task_id = f"task_{level_num}_{task_num}"
            db.collection('tasks').document(task_id).set({
                'level_id': level_id,
                'task_number': task_num,
                'question': f"What is task {task_num} for level {level_num}?",
                'expected_answer': f"answer_{level_num}_{task_num}"
            })

    return {"message": "Initialized 6 levels with 3 tasks each."}