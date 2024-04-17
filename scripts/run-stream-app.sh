#!/bin/bash

if [ $# -ne 4 ]; then
    echo "Usage: $0 <id> <input_topic> <common_words_output_topic> <uncommon_words_output_topic>"
    exit 1
fi

id=$1
input_topic=$2
common_words_output_topic=$3
uncommon_words_output_topic=$4

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_BASE_DIR="$(dirname $DIR)"
PROPERTIES_DIR=$APP_BASE_DIR/config/properties
KAFKA_APP_DIR=$APP_BASE_DIR/src/main/java/kafka
APP_LOG_DIR=$APP_BASE_DIR/logs
LIB_DIR=$APP_BASE_DIR/build/libs

echo "LIB_DIR: $LIB_DIR"
echo "PROPERTIES_DIR: $PROPERTIES_DIR"
echo "KAFKA_APP_DIR: $KAFKA_APP_DIR"
echo "APP_LOG_DIR: $APP_LOG_DIR"

echo "Starting stream app"
echo "java -Dapp_name=\"stream-app-$id\" -Djava.util.logging.SimpleFormatter.format='%1\$tY-%1\$tm-%1\$td %1\$tH:%1\$tM:%1\$tS %4\$s %2\$s : %5\$s%6\$s%n' -cp \"$LIB_DIR/*:$LIB_DIR/kafka-demo-1.0.0.jar\" kafka.stream.KafkaStreamsApplication \"$PROPERTIES_DIR/stream.properties\" \"$input_topic\" \"$common_words_output_topic\" \"$uncommon_words_output_topic\" > \"$APP_LOG_DIR/stream-app-$id.log\" 2>&1 &"
java -Dapp_name="stream-app-$id" -Djava.util.logging.SimpleFormatter.format='%1$tY-%1$tm-%1$td %1$tH:%1$tM:%1$tS %4$s %2$s : %5$s%6$s%n' -cp "$LIB_DIR/*:$LIB_DIR/kafka-demo-1.0.0.jar" kafka.stream.KafkaStreamsApplication "$PROPERTIES_DIR/stream.properties" "$input_topic" "$common_words_output_topic" "$uncommon_words_output_topic" > "$APP_LOG_DIR/stream-app-$id.log" 2>&1 &