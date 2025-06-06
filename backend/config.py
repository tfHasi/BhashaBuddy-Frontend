import firebase_admin
from firebase_admin import credentials, firestore, auth

# Only initialize if not already initialized
if not firebase_admin._apps:
    cred = credentials.Certificate("firebase-credentials.json")
    firebase_admin.initialize_app(cred)

def get_db():
    return firestore.client()

def get_auth():
    return auth