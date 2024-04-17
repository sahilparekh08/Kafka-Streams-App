#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_BASE_DIR="$(dirname $DIR)"
BIN_DIR=$APP_BASE_DIR/kafka_2.13-3.7.0/bin
KRAFT_CONFIG_DIR=$APP_BASE_DIR/config/kraft
APP_LOG_DIR=$APP_BASE_DIR/logs

echo "KRAFT_CONFIG_DIR: $KRAFT_CONFIG_DIR"
echo "BIN_DIR: $BIN_DIR"
echo "APP_LOG_DIR: $APP_LOG_DIR"

uuid=$($BIN_DIR/kafka-storage.sh random-uuid)
echo Generated UUID: $uuid

# format our log directories, allowing our controllers to know which broker belongs to which cluster
rm -rf /tmp/controller*
$BIN_DIR/kafka-storage.sh format -t $uuid -c $KRAFT_CONFIG_DIR/controller.1.properties
$BIN_DIR/kafka-storage.sh format -t $uuid -c $KRAFT_CONFIG_DIR/controller.2.properties
$BIN_DIR/kafka-storage.sh format -t $uuid -c $KRAFT_CONFIG_DIR/controller.3.properties
rm -rf /tmp/broker*
$BIN_DIR/kafka-storage.sh format -t $uuid -c $KRAFT_CONFIG_DIR/broker.1.properties
$BIN_DIR/kafka-storage.sh format -t $uuid -c $KRAFT_CONFIG_DIR/broker.2.properties
$BIN_DIR/kafka-storage.sh format -t $uuid -c $KRAFT_CONFIG_DIR/broker.3.properties

echo "Starting controllers"
$BIN_DIR/kafka-server-start.sh $KRAFT_CONFIG_DIR/controller.1.properties > $APP_LOG_DIR/controller.1.log 2>&1 &
sleep 1
$BIN_DIR/kafka-server-start.sh $KRAFT_CONFIG_DIR/controller.2.properties > $APP_LOG_DIR/controller.2.log 2>&1 &
sleep 1
$BIN_DIR/kafka-server-start.sh $KRAFT_CONFIG_DIR/controller.3.properties > $APP_LOG_DIR/controller.3.log 2>&1 &
sleep 1
echo "Starting brokers"
$BIN_DIR/kafka-server-start.sh $KRAFT_CONFIG_DIR/broker.1.properties > $APP_LOG_DIR/broker.1.log 2>&1 &
sleep 1
$BIN_DIR/kafka-server-start.sh $KRAFT_CONFIG_DIR/broker.2.properties > $APP_LOG_DIR/broker.2.log 2>&1 &
sleep 1
$BIN_DIR/kafka-server-start.sh $KRAFT_CONFIG_DIR/broker.3.properties > $APP_LOG_DIR/broker.3.log 2>&1 &
sleep 1
