#!/bin/bash

# Ensure city name is provided
if [ -z "$1" ]; then
    echo "Usage: ./predict_tomorrow_weather.sh <city_name>"
    exit 1
fi

CITY="$1"

# Fetch current weather data for the specified city
./fetch_weather_data2.sh "$CITY"

# Check if weather data file was created
if [ ! -f weather_data.csv ]; then
    echo "Weather data for $CITY not available. Cannot make prediction."
    exit 1
fi


python3 train_weather_model2.py

# Use Python to load the model and make a prediction
python3 - <<END
import pandas as pd
import joblib

# Load today's weather data
data = pd.read_csv("weather_data.csv")

# Extract features for prediction
X_today = data[['humidity', 'wind_speed']]

# Load the trained model
model = joblib.load("weather_model.pkl")

# Predict tomorrow's temperature
predicted_temp = model.predict(X_today)[0]

print(f"Predicted temperature for tomorrow in $CITY: {predicted_temp:.2f}°C")
END

