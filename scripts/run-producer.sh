#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Usage: $0 <id> <topic> <directory>"
    exit 1
fi

id=$1
topic=$2
directory=$3

if [ ! -d "$directory" ]; then
    echo "Directory $directory does not exist"
    exit 1
fi

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

echo "Starting producer"
echo "java -Dapp_name="producer-$id" -Djava.util.logging.SimpleFormatter.format='%1$tY-%1$tm-%1$td %1$tH:%1$tM:%1$tS %4$s %2$s : %5$s%6$s%n' -cp "$LIB_DIR/*:$LIB_DIR/kafka-demo-1.0.0.jar" kafka.producer.KafkaProducerApplication "$PROPERTIES_DIR/producer.properties" "$topic" "$directory" > "$APP_LOG_DIR/producer-$id.log" 2>&1 &"
java -Dapp_name="producer-$id" -Djava.util.logging.SimpleFormatter.format='%1$tY-%1$tm-%1$td %1$tH:%1$tM:%1$tS %4$s %2$s : %5$s%6$s%n' -cp "$LIB_DIR/*:$LIB_DIR/kafka-demo-1.0.0.jar" kafka.producer.KafkaProducerApplication "$PROPERTIES_DIR/producer.properties" "$topic" "$directory" > "$APP_LOG_DIR/producer-$id.log" 2>&1 &