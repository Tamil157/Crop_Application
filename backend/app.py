import os
import io
from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import img_to_array
from tensorflow.keras.initializers import GlorotUniform
from PIL import Image
import numpy as np
import uuid
import logging
import traceback
import pickle
import json

app = Flask(__name__)

# Set up logging
logging.basicConfig(level=logging.DEBUG)

# Load the models
crop_recommendation_model = pickle.load(open('recommend.pkl', 'rb'))

# Ensure that the initializer is handled correctly when loading the Keras model
custom_objects = {'GlorotUniform': GlorotUniform}
disease_prediction_model = load_model('disease_prediction_model.h5', custom_objects=custom_objects)

# Load fertilizer recommendation data
with open('fertilizer_recommendation.json') as f:
    fertilizer_data = json.load(f)

UPLOAD_FOLDER = 'dynamic_temp_uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

class_indices = {
    "0": "Apple___Apple_scab", "1": "Apple___Black_rot", "2": "Apple___Cedar_apple_rust", "3": "Apple___healthy",
    "4": "tomato ", "5": "Cherry_(including_sour)___Powdery_mildew", "6": "Cherry_(including_sour)___healthy",
    "7": "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot", "8": "tomato_beach",
    "9": "Corn_(maize)___Northern_Leaf_Blight", "10": "potato_blight", "11": "Grape___Black_rot",
    "12": "Grape___Esca_(Black_Measles)", "13": "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)", "14": "Grape___healthy",
    "15": "Orange___Haunglongbing_(Citrus_greening)", "16": "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot", "17": "Peach___healthy",
    "18": "Pepper,_bell___Bacterial_spot", "19": "Pepper,_bell___healthy", "20": "Potato___Early_blight",
    "21": "Potato___Late_blight", "22": "Potato___healthy", "23": "Raspberry___healthy", "24": "Soybean___healthy",
    "25": "Squash___Powdery_mildew", "26": "Strawberry___Leaf_scorch", "27": "Strawberry___healthy",
    "28": "Tomato___Bacterial_spot", "29": "Tomato___Early_blight", "30": "Tomato___Late_blight",
    "31": "Tomato___Leaf_Mold", "32": "Tomato___Septoria_leaf_spot", "33": "Tomato___Spider_mites Two-spotted_spider_mite",
    "34": "Tomato___Target_Spot", "35": "Tomato___Tomato_Yellow_Leaf_Curl_Virus", "36": "Tomato___Tomato_mosaic_virus",
    "37": "Tomato___healthy"
}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/predict-disease', methods=['POST'])
def predict_disease():
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    if not file or not allowed_file(file.filename):
        return jsonify({'error': 'Invalid file type'}), 400

    try:
        # Create a dynamic folder if it doesn't exist
        if not os.path.exists(UPLOAD_FOLDER):
            os.makedirs(UPLOAD_FOLDER)

        # Generate a unique filename for the uploaded image
        filename = str(uuid.uuid4()) + "_" + file.filename
        filepath = os.path.join(UPLOAD_FOLDER, filename)

        # Save the file to the created folder
        file.save(filepath)

        # Open and process the saved image for prediction
        img = Image.open(filepath)
        img = img.resize((224, 224))  # Adjust the size based on the model's expected input
        img_array = img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0) / 255.0  # Normalize the image

        # Predict the disease
        prediction = disease_prediction_model.predict(img_array)
        predicted_class_index = np.argmax(prediction)
        predicted_class = class_indices[str(predicted_class_index)]

        # Optionally, delete the saved file after prediction
        os.remove(filepath)

        return jsonify({'disease': predicted_class})

    except Exception as e:
        logging.error(f"Error during prediction: {e}")
        traceback.print_exc()
        return jsonify({'error': 'Error during prediction'}), 500

import pandas as pd
import traceback
import logging
@app.route('/recommend-crop', methods=['POST'])
def recommend_crop():
    data = request.json
    required_fields = ['N', 'P', 'K', 'temperature', 'humidity', 'ph', 'rainfall']

    # Check if all required fields are provided
    if not all(field in data for field in required_fields):
        return jsonify({'error': f'Missing fields. Required fields: {required_fields}'}), 400

    try:
        # Create a DataFrame for the input data
        features = {field: [data[field]] for field in required_fields}
        input_df = pd.DataFrame(features)
        print("Input DataFrame:", input_df)

        # Make prediction
        prediction = crop_recommendation_model.predict(input_df)

        # Handle both string and integer predictions
        predicted_crop = prediction[0]  # Could be string or int
        if isinstance(predicted_crop, str):  # If it's a string, use directly
            recommended_crop = predicted_crop
        else:  # If it's an integer, map using the label encoder or crop_dict
            recommended_crop = crop_dict.get(predicted_crop, "No suitable crop found")

        return jsonify({'recommended_crop': recommended_crop})
    
    except Exception as e:
        logging.error(f"Error occurred: {str(e)}")
        traceback.print_exc()
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@app.route('/recommend-fertilizer', methods=['POST'])
def recommend_fertilizer():
    data = request.json
    if 'disease' not in data:
        return jsonify({'error': 'No disease provided'}), 400

    disease = data['disease']
    
    # Check for exact match in the fertilizer_data
    recommendation = fertilizer_data.get(disease)
    
    if recommendation:
        return jsonify({
            'recommended_fertilizer': recommendation['fertilizer'],
            'application': recommendation['application'],
            'steps': recommendation['steps']
        })
    else:
        return jsonify({'error': 'No recommendation available for the provided disease'}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
