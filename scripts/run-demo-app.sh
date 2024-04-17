#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <id> <pdf_dir>"
    exit 1
fi

id=$1
pdf_dir=$2

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_BASE_DIR="$(dirname $DIR)"
SCRIPTS_DIR="$APP_BASE_DIR/scripts"

echo "SCRIPTS_DIR: $SCRIPTS_DIR"
chmod +x $SCRIPTS_DIR/*

stream_input_topic=$id'_input_topic'
stream_common_words_output_topic=$id'_common_words_output_topic'
stream_uncommon_words_output_topic=$id'_uncommon_words_output_topic'

# start all brokers and controllers
echo -e "\n"
echo "Starting all brokers and controllers"
$SCRIPTS_DIR/start-brokers-controllers.sh
sleep 5
echo "All brokers and controllers started"

# create topics
echo -e "\n"
echo "Creating topics"
$SCRIPTS_DIR/create-topic.sh $stream_input_topic
$SCRIPTS_DIR/create-topic.sh $stream_common_words_output_topic
$SCRIPTS_DIR/create-topic.sh $stream_uncommon_words_output_topic
sleep 2
echo "Topics created"

# start producer
echo -e "\n"
echo "Starting producer"
$SCRIPTS_DIR/run-producer.sh $id $stream_input_topic $pdf_dir
sleep 2
echo "Producer started"

# start consumers
echo -e "\n"
echo "Starting consumer for common words output topic"
$SCRIPTS_DIR/run-consumer.sh "$id-common-words" $stream_common_words_output_topic
sleep 2
echo "Consumer started"

echo -e "\n"
echo "Starting consumer for uncommon words output topic"
$SCRIPTS_DIR/run-consumer.sh "$id-uncommon-words" $stream_uncommon_words_output_topic
sleep 2
echo "Consumer started"

# start stream app
echo -e "\n"
echo "Starting stream app"
$SCRIPTS_DIR/run-stream-app.sh $id $stream_input_topic $stream_common_words_output_topic $stream_uncommon_words_output_topic
sleep 2
echo "Stream app started"