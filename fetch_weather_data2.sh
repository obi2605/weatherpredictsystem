#!/bin/bash

# Ensure city name is provided
if [ -z "$1" ]; then
    echo "Usage: ./fetch_weather_data2.sh <city_name>"
    exit 1
fi

CITY="$1"
API_KEY="4f7e673e2d42333f1904de8de533ddaa"
URL="https://api.openweathermap.org/data/2.5/weather?q=${CITY}&appid=${API_KEY}&units=metric"

# Fetch today's weather data
response=$(curl -s "$URL")

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is required but not installed. Installing jq..."
    sudo apt-get update && sudo apt-get install -y jq
fi

# Check for valid response
if [[ $(echo "$response" | jq -r '.cod') != "200" ]]; then
    echo "Failed to fetch weather data for city: $CITY"
    exit 1
fi

# Parse today's weather data
temp=$(echo "$response" | jq -r '.main.temp')
humidity=$(echo "$response" | jq -r '.main.humidity')
wind_speed=$(echo "$response" | jq -r '.wind.speed')
date=$(date +%Y-%m-%d)

# Save today’s weather data to a text file for display
echo "temp=$temp" > today_weather.txt
echo "humidity=$humidity" >> today_weather.txt
echo "wind_speed=$wind_speed" >> today_weather.txt

# Save today’s data to weather_data.csv
echo "date,temp,humidity,wind_speed" > weather_data.csv
echo "$date,$temp,$humidity,$wind_speed" >> weather_data.csv
echo "Today's weather data for $CITY saved to weather_data.csv and today_weather.txt."

# Historical data fetching
NUM_DAYS=100  # Number of days to fetch historical data for
OUTPUT_FILE="weather_dataset.csv"

# Initialize CSV file for historical data
echo "date,temp,humidity,wind_speed" > "$OUTPUT_FILE"

# Coordinates for the city's historical data (latitude and longitude)
LAT=40.7128  # Replace with actual latitude
LON=-74.0060  # Replace with actual longitude

# Loop to fetch historical data
for (( i=1; i<=NUM_DAYS; i++ )); do
    # Calculate the timestamp for each historical day
    DATE=$(date -d "$i days ago" +%Y-%m-%d)
    TIMESTAMP=$(date -d "$DATE" +%s)

    # Fetch historical data
    RESPONSE=$(curl -s "https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=$LAT&lon=$LON&dt=$TIMESTAMP&appid=$API_KEY&units=metric")

    # Parse historical weather data
    TEMP=$(echo "$RESPONSE" | jq -r '.current.temp')
    HUMIDITY=$(echo "$RESPONSE" | jq -r '.current.humidity')
    WIND_SPEED=$(echo "$RESPONSE" | jq -r '.current.wind_speed')

    # Append historical data to CSV file
    echo "$DATE,$TEMP,$HUMIDITY,$WIND_SPEED" >> "$OUTPUT_FILE"
done

echo "Historical data collection complete! Weather data saved in $OUTPUT_FILE."
