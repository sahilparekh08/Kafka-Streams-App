#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <id>"
    exit 1
fi

id=$1

if ! pgrep -f "consumer-$id" > /dev/null; then
    echo "Consumer with id: $id is not running"
    exit 0
fi

echo "Stopping consumer with id: $id"
pkill -f "consumer-$id"