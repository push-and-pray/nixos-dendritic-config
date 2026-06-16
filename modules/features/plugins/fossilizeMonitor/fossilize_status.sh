#!/bin/bash
LOG_FILE="$HOME/.local/share/Steam/logs/shader_log.txt"

# If log file doesn't exist or is empty
if [ ! -f "$LOG_FILE" ]; then
    echo '{"status": "idle"}'
    exit 0
fi

# Find the latest lines related to fossilize status
LATEST_LINE=$(grep -E "Still replaying|fossilize_replay completed|Starting processing job" "$LOG_FILE" | tail -n 1)

if [ -z "$LATEST_LINE" ]; then
    echo '{"status": "idle"}'
    exit 0
fi

if echo "$LATEST_LINE" | grep -q "completed"; then
    echo '{"status": "idle"}'
    exit 0
fi

if echo "$LATEST_LINE" | grep -q "Starting processing job"; then
    APPID=$(echo "$LATEST_LINE" | grep -oP "app \K[0-9]+")
    MANIFEST="$HOME/.local/share/Steam/steamapps/appmanifest_${APPID}.acf"
    GAME_NAME="Unknown Game"
    if [ -f "$MANIFEST" ]; then
        GAME_NAME=$(grep -i '"name"' "$MANIFEST" | head -n 1 | cut -d'"' -f4)
    fi
    echo "{\"status\": \"starting\", \"appid\": \"$APPID\", \"game\": \"$GAME_NAME\"}"
    exit 0
fi

if echo "$LATEST_LINE" | grep -q "Still replaying"; then
    APPID=$(echo "$LATEST_LINE" | grep -oP "replaying \K[0-9]+")
    PERCENT=$(echo "$LATEST_LINE" | grep -oP "\(\K[0-9]+(?=%)")
    PROGRESS=$(echo "$LATEST_LINE" | grep -oP "\([0-9]+%, \K[0-9]+/[0-9]+")
    
    # Try to find game name from appmanifest
    MANIFEST="$HOME/.local/share/Steam/steamapps/appmanifest_${APPID}.acf"
    GAME_NAME="Unknown Game"
    if [ -f "$MANIFEST" ]; then
        GAME_NAME=$(grep -i '"name"' "$MANIFEST" | head -n 1 | cut -d'"' -f4)
    fi

    # Check if CPU processes are running to confirm it's active
    if pgrep -f "fossilize_replay" > /dev/null; then
        RUNNING="true"
    else
        RUNNING="false"
    fi
    
    echo "{\"status\": \"replaying\", \"running\": $RUNNING, \"appid\": \"$APPID\", \"game\": \"$GAME_NAME\", \"percent\": $PERCENT, \"progress\": \"$PROGRESS\"}"
    exit 0
fi

echo '{"status": "idle"}'
