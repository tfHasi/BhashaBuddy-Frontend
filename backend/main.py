import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes.student import student_router
from routes.admin import admin_router
from routes.auth import auth_router

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(student_router, prefix="/student", tags=["Students"])
app.include_router(admin_router, prefix="/admin", tags=["Admins"])
app.include_router(auth_router, tags=["Auth"])

# Health check endpoint for Koyeb
@app.get("/health")
def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)