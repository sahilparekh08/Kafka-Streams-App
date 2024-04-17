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

echo "Creating topic : $topic with 6 partitions and 3 replication-factor"
$BIN_DIR/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic $topic --partitions 6 --replication-factor 3 > $APP_LOG_DIR/create-topic.log 2>&1

topic_description_b1=$($BIN_DIR/kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic $topic)
topic_description_b2=$($BIN_DIR/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic $topic)
topic_description_b3=$($BIN_DIR/kafka-topics.sh --bootstrap-server localhost:9093 --describe --topic $topic)

echo "Topic description on broker 1: $topic_description_b1"
echo "Topic description on broker 2: $topic_description_b2"
echo "Topic description on broker 3: $topic_description_b3"
