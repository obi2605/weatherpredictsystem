#!/bin/bash

# Prompt the user to enter a city name using Zenity
CITY=$(zenity --entry --title="Weather Prediction" --text="Enter the city name:")

# Ensure city name is provided
if [ -z "$CITY" ]; then
    zenity --error --text="City name is required to make a prediction."
    exit 1
fi

# Fetch current weather data for the specified city with a progress dialog
(
    echo "10"; sleep 1
    echo "# Fetching current weather data for $CITY..."
    ./fetch_weather_data2.sh "$CITY" && echo "50" || (zenity --error --text="Failed to fetch weather data for $CITY." && exit 1)
    echo "75"
) | zenity --progress --title="Fetching Weather Data" --percentage=0 --auto-close

# Check if today's weather data file was created
if [ ! -f today_weather.txt ]; then
    zenity --error --text="Weather data for $CITY not available. Cannot make prediction."
    exit 1
fi

# Load today's weather data
source today_weather.txt

# Train the model with another progress dialog
(
    echo "10"; sleep 1
    echo "# Training weather prediction model..."
    python3 train_weather_model2.py && echo "100" || (zenity --error --text="Model training failed." && exit 1)
) | zenity --progress --title="Training Model" --percentage=0 --auto-close

# Use Python to load the model and make a prediction, storing output in a variable
PREDICTION=$(python3 - <<END
import pandas as pd
import joblib

# Load today's weather data for prediction
data = pd.read_csv("weather_data.csv")

# Extract features for prediction
X_today = data[['humidity', 'wind_speed']]

# Load the trained model
model = joblib.load("weather_model.pkl")

# Predict tomorrow's temperature
predicted_temp = model.predict(X_today)[0]
print(f"{predicted_temp:.2f}")
END
)

# Display both today's weather and tomorrow's prediction in one Zenity window
if [ $? -eq 0 ]; then
    zenity --info --title="Weather Prediction" --text="Weather for $CITY:
Today's Temperature: $temp°C
Today's Humidity: $humidity%
Today's Wind Speed: $wind_speed m/s

Predicted Temperature for Tomorrow: ${PREDICTION}°C"
else
    zenity --error --text="Failed to predict tomorrow's weather."
    exit 1
fi
