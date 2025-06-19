import os
import numpy as np
from PIL import Image
from tensorflow.keras.models import load_model
from tensorflow.keras.layers import PReLU
from sklearn.preprocessing import LabelEncoder
import pickle

# Paths
model_dir = 'intelligence'
label_encoder_path = 'intelligence/label_encoder.pkl'  # update if elsewhere

# Load label encoder
with open(label_encoder_path, 'rb') as f:
    le = pickle.load(f)

# Load all models
models = [load_model(os.path.join(model_dir, f'model_fold_{i}.keras'), custom_objects={'PReLU': PReLU}) for i in range(1, 6)]

# Preprocess one character image
def preprocess_image(path):
    img = Image.open(path).convert('L').resize((32, 32), Image.Resampling.LANCZOS)
    img = np.array(img, dtype='float32') / 255.0
    return img.reshape(1, 32, 32, 1)

# Predict a single character image path
def predict_character(image_path):
    img = preprocess_image(image_path)
    avg_pred = sum(model.predict(img, verbose=0) for model in models) / len(models)
    predicted_label = np.argmax(avg_pred)
    return le.inverse_transform([predicted_label])[0]
