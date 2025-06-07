import os
import base64
import firebase_admin
from firebase_admin import credentials, firestore, auth

FIREBASE_CREDENTIALS_PATH = "firebase-credentials.json"

# Decode Base64 env var if file is missing
if not os.path.exists(FIREBASE_CREDENTIALS_PATH):
    firebase_b64 = os.getenv("FIREBASE_CREDENTIALS_B64")
    if not firebase_b64:
        raise RuntimeError("FIREBASE_CREDENTIALS_B64 environment variable not set")
    with open(FIREBASE_CREDENTIALS_PATH, "wb") as f:
        f.write(base64.b64decode(firebase_b64))

# Initialize Firebase app only once
if not firebase_admin._apps:
    cred = credentials.Certificate(FIREBASE_CREDENTIALS_PATH)
    firebase_admin.initialize_app(cred)

def get_db():
    return firestore.client()

def get_auth():
    return auth