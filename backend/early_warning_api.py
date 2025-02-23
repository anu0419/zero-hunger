from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from firebase_admin import credentials, firestore, initialize_app
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Initialize Firebase
cred = credentials.Certificate("C:/Users/anasu/Desktop/zerohunger/zerohungerr/backend/zerohungerr-37d86-firebase-adminsdk-fbsvc-65b6ab34a0.json")
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

@app.route('/', methods=['GET'])
def home():
    return "Early Warning API is running!"

@app.route('/predict_warning', methods=['GET', 'POST'])
def predict_warning():
    if request.method == 'GET':
        return jsonify({'message': 'Please send a POST request with temperature and humidity data'})
    
    try:
        data = request.json
        temp, humidity = data['temperature'], data['humidity']
        risk = model.predict([[temp, humidity]])[0]
        risk_label = ["Safe", "Medium Risk", "High Risk"][risk]

        # Store warning in Firestore
        db.collection('warnings').add({
            'temperature': temp,
            'humidity': humidity,
            'risk': risk_label,
            'timestamp': firestore.SERVER_TIMESTAMP
        })

        return jsonify({'status': 'success', 'risk': risk_label})

    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
