package kafka.consumer;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import utils.ConsumerUtil;
import utils.StreamUtil;

import java.io.*;
import java.time.Duration;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.logging.Logger;

public class KafkaConsumerApplication {
    private static final Logger logger = Logger.getLogger(KafkaConsumerApplication.class.getName());

    private final String topic;
    private final Properties consumerProperties;
    private final Map<String, Long> wordCountMap = new HashMap<>();
    private final String outputFilePath;
    private KafkaConsumer<String, Long> consumer;
    private KafkaConsumerRebalanceListener consumerRebalanceListener;

    public KafkaConsumerApplication(String propertiesFile, String topic, String outputFilePath) {
        this.topic = topic;
        this.consumerProperties = new Properties();
        this.outputFilePath = outputFilePath;
        try {
            logger.info("Loading properties file: " + propertiesFile);
            consumerProperties.load(new FileInputStream(propertiesFile));
        } catch (Exception e) {
            logger.severe("Error loading properties file: " + e.getMessage());
        }
        File file = new File(outputFilePath);
        if (!file.exists()) {
            try {
                if (file.createNewFile()) {
                    logger.info("Output file created: " + outputFilePath);
                }
            } catch (Exception e) {
                logger.severe("Error creating output file: " + e.getMessage());
            }
        }
    }

    public void run() {
        logger.info("Starting Kafka Consumer Application...");
        logger.info("Topic: " + topic);
        logger.info("Properties: " + consumerProperties.toString());
        logger.info("Output file: " + outputFilePath);

        // close resources on interrupt
        Runtime.getRuntime().addShutdownHook(new Thread(this::closeResources));

        consumer = new KafkaConsumer<>(consumerProperties);
        consumerRebalanceListener = new KafkaConsumerRebalanceListener(consumer);

        try {
            consumer.subscribe(Collections.singletonList(topic), consumerRebalanceListener);
            int count = 0, lastSeenCount = 0;

            long startTime = System.currentTimeMillis();

            while (true) {
                if (count > 0 && (count % 1000 == 0 || System.currentTimeMillis() - startTime > 10000)) {
                    startTime = System.currentTimeMillis();
                    if (count == lastSeenCount) {
                        try (BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(outputFilePath, true))) {
                            logger.info("Writing to " + outputFilePath + " after processing " + count + " records...");
                            bufferedWriter.append("=====================================\n");
                            bufferedWriter.append(String.valueOf(count)).append(" records processed\n");
                            ConsumerUtil.getTopNWordsFromMap(wordCountMap, 10).forEach((key, value) -> {
                                try {
                                    bufferedWriter.append(key).append(": ").append(String.valueOf(value)).append("\n");
                                } catch (IOException e) {
                                    logger.severe("Error writing to file: " + e.getMessage());
                                }
                            });
                            bufferedWriter.append("=====================================\n");
                        }
                        logger.info("No new records to process. Exiting...");
                        break;
                    } else {
                        lastSeenCount = count;
                    }
                }

                ConsumerRecords<String, Long> records = consumer.poll(Duration.ofMillis(100));
                for (ConsumerRecord<String, Long> record : records) {
                    count++;
                    logger.info("Received key: " + record.key() + ", value: " + record.value() + " at partition: " + record.partition());
                    wordCountMap.put(record.key(), record.value());
                    consumerRebalanceListener.addOffsetToTrack(record.topic(), record.partition(), record.offset());
                }
                if (records.count() > 0) consumer.commitAsync();
            }
        } catch (Exception e) {
            logger.severe("Error: " + e.getMessage());
        } finally {
            closeResources();
        }
    }

    private void closeResources() {
        try {
            logger.info("Committing offsets: " + consumerRebalanceListener.getCurrentOffsets());
            consumer.commitSync(consumerRebalanceListener.getCurrentOffsets());
        } catch (Exception e) {
            logger.severe("Error committing offsets: " + e.getMessage());
        } finally {
            consumer.close();
            logger.info("Kafka Consumer closed...");
        }
    }

    public static void main(String[] args) {
        String propertiesFile = args[0];
        String topic = args[1];
        String outputFilePath = args[2];
        KafkaConsumerApplication consumerApplication = new KafkaConsumerApplication(propertiesFile, topic, outputFilePath);
        consumerApplication.run();
    }
}
