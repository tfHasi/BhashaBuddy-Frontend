from fastapi import APIRouter, UploadFile, File, HTTPException, Form
from typing import List
from PIL import Image
import io
from config import get_db
from scripts.inference import predict_word_from_images

predict_router = APIRouter()
db = get_db()

@predict_router.post("/student/{student_uid}/predict-task")
async def predict_task(
    student_uid: str,
    level_id: int = Form(...),
    task_id: int = Form(...),
    images: List[UploadFile] = File(...)
):
    try:
        if not (3 <= len(images) <= 6):
            raise HTTPException(status_code=400, detail="Provide 3 to 6 images")

        # Fetch target word for validation
        level_doc = db.collection("levels").document(str(level_id)).get()
        if not level_doc.exists:
            raise HTTPException(status_code=404, detail="Level not found")

        tasks = level_doc.to_dict().get("tasks", [])
        if task_id >= len(tasks):
            raise HTTPException(status_code=400, detail="Invalid task ID")

        target_word = tasks[task_id]
        if len(images) != len(target_word):
            raise HTTPException(
                status_code=400,
                detail=f"Expected {len(target_word)} images for word '{target_word}'"
            )

        # Convert images to PIL
        pil_images = []
        for i, file in enumerate(images):
            if not file.content_type.startswith("image/"):
                raise HTTPException(status_code=400, detail=f"File {i+1} is not an image")
            try:
                content = await file.read()
                image = Image.open(io.BytesIO(content))
                pil_images.append(image)
            except Exception as e:
                raise HTTPException(status_code=400, detail=f"Error reading image {i+1}: {str(e)}")

        # Predict
        predicted_word = predict_word_from_images(pil_images)

        return {
            "student_uid": student_uid,
            "level_id": level_id,
            "task_id": task_id,
            "target_word": target_word,
            "predicted_word": predicted_word,
            "correct": predicted_word.upper() == target_word.upper()
        }

    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))