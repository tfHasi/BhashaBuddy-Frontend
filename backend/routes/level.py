from fastapi import APIRouter, HTTPException
from config import get_db

db = get_db()
levels_router = APIRouter()

@levels_router.get("/{level_id}/tasks")
async def get_level_tasks(level_id: int):
    try:
        doc_ref = db.collection('levels').document(str(level_id))
        doc = doc_ref.get()
        if not doc.exists:
            raise HTTPException(status_code=404, detail="Level not found")
        return {"level": level_id, "tasks": doc.to_dict().get("tasks", [])}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))