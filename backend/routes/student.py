from fastapi import APIRouter, HTTPException
from firebase_admin import auth
from config import get_db
from models.schemas import StudentSignup
import uuid

student_router = APIRouter()
db = get_db()

@student_router.post("/signup")
async def student_signup(data: StudentSignup):
    try:
        students = db.collection('students').where('nickname', '==', data.nickname).get()
        if students:
            raise HTTPException(status_code=400, detail="Nickname already exists")
        
        user = auth.create_user(email=data.email, password=data.password)
        sid = str(uuid.uuid4())[:8].upper()
        db.collection('students').document(user.uid).set({
            'sid': sid,
            'email': data.email,
            'nickname': data.nickname,
            'type': 'student'
        })
        return {"message": "Student created successfully", "sid": sid}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))