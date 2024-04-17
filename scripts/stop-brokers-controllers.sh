#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_BASE_DIR="$(dirname $DIR)"
BIN_DIR=$APP_BASE_DIR/kafka_2.13-3.7.0/bin
KRAFT_CONFIG_DIR=$APP_BASE_DIR/config/kraft
APP_LOG_DIR=$APP_BASE_DIR/logs
OUTPUT_DIR=$APP_BASE_DIR/output

echo "KRAFT_CONFIG_DIR: $KRAFT_CONFIG_DIR"
echo "BIN_DIR: $BIN_DIR"

echo "Stopping brokers"
$BIN_DIR/kafka-server-stop.sh $KRAFT_CONFIG_DIR/broker.1.properties > $APP_LOG_DIR/broker.1.stop.log 2>&1
$BIN_DIR/kafka-server-stop.sh $KRAFT_CONFIG_DIR/broker.2.properties > $APP_LOG_DIR/broker.2.stop.log 2>&1
$BIN_DIR/kafka-server-stop.sh $KRAFT_CONFIG_DIR/broker.3.properties > $APP_LOG_DIR/broker.3.stop.log 2>&1
echo "Brokers stopped"

#wait for brokers to stop
sleep 1

echo "Stopping controllers"
$BIN_DIR/kafka-server-stop.sh $KRAFT_CONFIG_DIR/controller.1.properties > $APP_LOG_DIR/controller.1.stop.log 2>&1
$BIN_DIR/kafka-server-stop.sh $KRAFT_CONFIG_DIR/controller.2.properties > $APP_LOG_DIR/controller.2.stop.log 2>&1
$BIN_DIR/kafka-server-stop.sh $KRAFT_CONFIG_DIR/controller.3.properties > $APP_LOG_DIR/controller.3.stop.log 2>&1
echo "Controllers stopped"

if [ "$1" = "Y" ]; then
  echo "Clearing logs"
  rm -rf $APP_LOG_DIR/*.log
  rm -rf $APP_LOG_DIR/*.txt
  echo "Logs cleared"

  echo "Clearing output directory"
  rm -rf $OUTPUT_DIR/*.out
  echo "Output directory cleared"

  echo "Clearing Kafka logs"
  rm -rf $APP_BASE_DIR/kafka_2.13-3.7.0/logs/*
  echo "Kafka logs cleared"

  echo "Clearing /tmp logs"
  rm -rf /tmp/broker*
  rm -rf /tmp/controller*
  echo "/tmp logs cleared"
fi