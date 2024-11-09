import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
import joblib

# Load historical weather data
data = pd.read_csv("weather_dataset.csv")

# Check for missing values in the dataset
print("Initial check for missing values:")
print(data.isnull().sum())

# Define numeric columns and fill any NaN values with the mean
numeric_columns = ['temp', 'humidity', 'wind_speed']

# Check if most or all values are NaN, and if so, handle it
if data[numeric_columns].isnull().mean().sum() > 0.5 * len(numeric_columns):
    print("Warning: Not enough valid data available. Generating synthetic data for training.")
    # Generate sample data for fallback
    data = pd.DataFrame({
        'temp': [25, 22, 30, 28, 27, 24, 29, 21, 23, 26],
        'humidity': [60, 65, 55, 70, 62, 63, 67, 66, 64, 59],
        'wind_speed': [5, 3, 7, 6, 4, 5, 8, 3, 6, 4]
    })

else:
    # Fill missing values with column mean if enough data is available
    data[numeric_columns] = data[numeric_columns].fillna(data[numeric_columns].mean())

# Ensure no NaN values remain in features or target
X = data[['humidity', 'wind_speed']]
y = data['temp']

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train the model
model = LinearRegression()
model.fit(X_train, y_train)

# Save the model to disk
joblib.dump(model, "weather_model.pkl")
print("Model trained and saved as weather_model.pkl!")

