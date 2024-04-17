#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <id> <clear_logs (optional)>"
    exit 1
fi

id=$1
clearLogs=$2

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_BASE_DIR="$(dirname $DIR)"
SCRIPTS_DIR="$APP_BASE_DIR/scripts"

echo "SCRIPTS_DIR: $SCRIPTS_DIR"
chmod +x $SCRIPTS_DIR/*

stream_input_topic=$id'_input_topic'
stream_common_words_output_topic=$id'_common_words_output_topic'
stream_uncommon_words_output_topic=$id'_uncommon_words_output_topic'

#stop producer
echo -e "\n"
echo "Stopping producer"
$SCRIPTS_DIR/stop-producer.sh $id
sleep 2
echo "Producer stopped"

# stop stream app
echo -e "\n"
echo "Stopping stream app"
$SCRIPTS_DIR/stop-stream-app.sh $id $clearLogs
sleep 2
echo "Stream app stopped"

# stop consumer
echo -e "\n"
echo "Stopping consumer for common words output topic"
$SCRIPTS_DIR/stop-consumer.sh "$id-common-words"
sleep 2
echo "Consumer stopped"

echo -e "\n"
echo "Stopping consumer for uncommon words output topic"
$SCRIPTS_DIR/stop-consumer.sh "$id-uncommon-words"
sleep 2
echo "Consumer stopped"

# delete topics
echo -e "\n"
echo "Deleting topics"
$SCRIPTS_DIR/delete-topic.sh $stream_input_topic
$SCRIPTS_DIR/delete-topic.sh $stream_common_words_output_topic
$SCRIPTS_DIR/delete-topic.sh $stream_uncommon_words_output_topic
sleep 2
echo "Topics deleted"

# stop all brokers and controllers
echo -e "\n"
echo "Stopping all brokers and controllers"
$SCRIPTS_DIR/stop-brokers-controllers.sh $clearLogs
sleep 5
echo "All brokers and controllers stopped"