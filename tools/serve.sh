#!/bin/bash
# Serves the audio editor on localhost so mic permissions are remembered

PORT=8765
URL="http://localhost:$PORT/audio_editor.html"

echo "Opening audio editor at $URL"
sleep 0.5 && open "$URL" &

cd "$(dirname "$0")"
python3 -m http.server $PORT
