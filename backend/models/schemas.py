from pydantic import BaseModel

class StudentSignup(BaseModel):
    email: str
    password: str
    nickname: str

class AdminSignup(BaseModel):
    email: str
    password: str

class LoginRequest(BaseModel):
    email: str
    password: str

class TaskSubmission(BaseModel):
    user_id: str
    level_id: str
    task_id: str