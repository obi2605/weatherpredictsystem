

#!/bin/bash

# Ensure city name is provided
if [ -z "$1" ]; then
    echo "Usage: ./fetch_weather_data2.sh <city_name>"
    exit 1
fi

CITY="$1"
API_KEY="your-api-key"
URL="https://api.openweathermap.org/data/2.5/weather?q=${CITY}&appid=${API_KEY}&units=metric"

# Fetch weather data
response=$(curl -s "$URL")

# Check for valid response
if [[ $(echo "$response" | jq -r '.cod') != "200" ]]; then
    echo "Failed to fetch weather data for city: $CITY"
    exit 1
fi

# Parse the JSON response and extract relevant fields
temp=$(echo "$response" | jq -r '.main.temp')
humidity=$(echo "$response" | jq -r '.main.humidity')
wind_speed=$(echo "$response" | jq -r '.wind.speed')
date=$(date +%Y-%m-%d)

# Save the data to CSV
echo "date,temp,humidity,wind_speed" > weather_data.csv
echo "$date,$temp,$humidity,$wind_speed" >> weather_data.csv
echo "Weather data for $CITY saved to weather_data.csv"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is required but not installed. Installing jq..."
    sudo apt-get update && sudo apt-get install -y jq
fi

NUM_DAYS=100  # Number of days to fetch historical data for
OUTPUT_FILE="weather_dataset.csv"

# Initialize CSV file
echo "date,temp,humidity,wind_speed" > "$OUTPUT_FILE"

# Loop to fetch historical data
for (( i=1; i<=NUM_DAYS; i++ )); do
    # Calculate the timestamp for each day
    DATE=$(date -d "$i days ago" +%Y-%m-%d)
    TIMESTAMP=$(date -d "$DATE" +%s)

    # Fetch data for each day
    RESPONSE=$(curl -s "https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=40.7128&lon=-74.0060&dt=$TIMESTAMP&appid=$API_KEY&units=metric")

    # Parse JSON response
    TEMP=$(echo "$RESPONSE" | jq -r '.current.temp')
    HUMIDITY=$(echo "$RESPONSE" | jq -r '.current.humidity')
    WIND_SPEED=$(echo "$RESPONSE" | jq -r '.current.wind_speed')

    # Append data to CSV file
    echo "$DATE,$TEMP,$HUMIDITY,$WIND_SPEED" >> "$OUTPUT_FILE"
done

echo "Data collection complete! Weather data saved in $OUTPUT_FILE."
