#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <id> <clear_logs (optional)>"
    exit 1
fi

id=$1
clearLogs=$2

if ! pgrep -f "stream-app-$id" > /dev/null; then
    echo "Stream App with id $id is not running"
else
    echo "Stopping Stream App with id $id"
    pkill -f "stream-app-$id"
fi

sleep 2

if [ "$clearLogs" == "Y" ]; then
    echo "Clearing logs from /tmp"
    rm -rf /tmp/kafka-streams-101*
    echo "Logs cleared"
fi