from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from firebase_admin import credentials, firestore, initialize_app
from flask_cors import CORS
import requests

app = Flask(__name__)
CORS(app)

# Initialize Firebase
cred = credentials.Certificate("C:/Users/anasu/Desktop/zerohunger/zerohungerr/backend/zerohungerr-37d86-firebase-adminsdk-fbsvc-65b6ab34a0.json")
 # Replace with your Firebase credentials
initialize_app(cred)
db = firestore.client()

# Sample Data
data = pd.DataFrame({
    'temperature': [25, 30, 35, 40, 45],
    'humidity': [60, 65, 70, 75, 80],
    'risk_level': [0, 1, 1, 2, 2]  # 0 = Safe, 1 = Medium Risk, 2 = High Risk
})

# Train Model
X = data[['temperature', 'humidity']]
y = data['risk_level']
model = RandomForestClassifier()
model.fit(X, y)

def get_weather_alert(latitude, longitude):
    """Fetches real-time weather alerts from Open-Meteo."""
    try:
        url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current=temperature_2m,precipitation,weathercode"
        response = requests.get(url)
        data = response.json()

        weather_code = data["current"].get("weathercode", 0)
        temp = data["current"].get("temperature_2m", 0)
        precipitation = data["current"].get("precipitation", 0)

        alert = "No major weather events detected."
        if weather_code in [95, 96, 99]:  # Thunderstorm warnings
            alert = "⚠️ Storm Warning!"
        elif precipitation > 50:
            alert = "🌧️ Heavy Rainfall Alert!"
        elif temp > 45:
            alert = "🔥 Heatwave Alert!"

        return alert
    except Exception as e:
        return f"Error fetching weather data: {e}"

@app.route('/', methods=['GET'])
def home():
    return "Early Warning API is running!"

@app.route('/predict_warning', methods=['POST'])
def predict_warning():
    try:
        data = request.json
        temp, humidity = data['temperature'], data['humidity']
        latitude, longitude = data.get('latitude', 0), data.get('longitude', 0)

        # AI Prediction
        risk = model.predict([[temp, humidity]])[0]
        risk_label = ["Safe", "Medium Risk", "High Risk"][risk]

        # Fetch Weather Alerts
        weather_alert = get_weather_alert(latitude, longitude)

        # Store warning in Firestore
        db.collection('warnings').add({
            'temperature': temp,
            'humidity': humidity,
            'risk': risk_label,
            'weather_alert': weather_alert,
            'timestamp': firestore.SERVER_TIMESTAMP
        })

        return jsonify({'status': 'success', 'risk': risk_label, 'weather_alert': weather_alert})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

