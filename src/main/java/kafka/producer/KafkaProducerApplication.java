package kafka.producer;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import utils.PDFUtil;

import java.io.FileInputStream;
import java.util.Arrays;
import java.util.Map;
import java.util.Properties;
import java.util.logging.Logger;

public class KafkaProducerApplication {
    private static final Logger logger = Logger.getLogger(KafkaProducerApplication.class.getName());

    private final String topic;
    private final Map<String, String> fileToContentMap;
    private final Properties producerProperties;

    public KafkaProducerApplication(String propertiesFile, String topic, String directory) {
        this.topic = topic;
        this.producerProperties = new Properties();
        try {
            logger.info("Loading properties file: " + propertiesFile);
            producerProperties.load(new FileInputStream(propertiesFile));
        } catch (Exception e) {
            logger.severe("Error loading properties file: " + e.getMessage());
        }
        this.fileToContentMap = PDFUtil.getPDFTextForAllFilesInDirectory(directory);
    }

    public static void main(String[] args) {
        String propertiesFile = args[0];
        String topic = args[1];
        String directory = args[2];
        KafkaProducerApplication producerApplication = new KafkaProducerApplication(propertiesFile, topic, directory);
        producerApplication.run();
    }

    public void run() {
        logger.info("Starting Kafka Producer Application...");
        logger.info("Topic: " + topic);
        logger.info("Properties: " + producerProperties.toString());

        // get total partitions for the topic from kafka
        try (KafkaProducer<String, String> producer = new KafkaProducer<>(producerProperties)) {
            for (Map.Entry<String, String> entry : fileToContentMap.entrySet()) {
                String key = entry.getKey();
                String value = entry.getValue();
                logger.info("Processing file: " + key);
                final int[] count = {0};
                Arrays.stream(value.split("\\n+")).forEach(line -> {
                    ProducerRecord<String, String> record = new ProducerRecord<>(topic, key, line);
                    producer.send(record);
                    if (count[0] % 1000 == 0)
                        logger.info("Produced " + count[0] + " records for file: " + key);
                    count[0]++;
                });
                logger.info("Finished processing file: " + key);
            }
        } catch (Exception e) {
            logger.severe("Error creating Kafka Producer: " + e.getMessage());
        }
    }
}
