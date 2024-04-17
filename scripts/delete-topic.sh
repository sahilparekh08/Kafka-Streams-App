#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <topic>"
    exit 1
fi

topic=$1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_BASE_DIR="$(dirname $DIR)"
BIN_DIR=$APP_BASE_DIR/kafka_2.13-3.7.0/bin
APP_LOG_DIR=$APP_BASE_DIR/logs

echo "APP_LOG_DIR: $APP_LOG_DIR"
echo "BIN_DIR: $BIN_DIR"

echo "Deleting topic : $topic"
$BIN_DIR/kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic $topic > $APP_LOG_DIR/delete-topic.log 2>&1
echo "Topic $topic deleted"