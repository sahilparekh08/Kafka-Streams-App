#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <id>"
    exit 1
fi

id=$1

if ! pgrep -f "producer-$id" > /dev/null; then
    echo "Producer with id: $id is not running"
    exit 0
fi

echo "Stopping producer with id: $id"
pkill -f "producer-$id"