from fastapi import APIRouter, HTTPException
from config import get_db

leaderboard_router = APIRouter()
db = get_db()

@leaderboard_router.get("/leaderboard/top5")
async def get_leaderboard_top5():
    try:
        leaderboard = await get_current_leaderboard()
        return {"top5": leaderboard}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

async def get_current_leaderboard():
    try:
        tasks = db.collection('completed_tasks').get()
        scores = {}
        for t in tasks:
            s_id = t.get('student_id')
            scores[s_id] = scores.get(s_id, 0) + 1

        leaderboard = []
        for s_id, stars in scores.items():
            s_doc = db.collection('students').document(s_id).get()
            if s_doc.exists:
                nickname = s_doc.to_dict().get('nickname')
                leaderboard.append({'user_id': s_id, 'nickname': nickname, 'total_stars': stars})

        return sorted(leaderboard, key=lambda x: x['total_stars'], reverse=True)[:5]
    except Exception:
        return []