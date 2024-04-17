package kafka.stream;

import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.kstream.Consumed;
import org.apache.kafka.streams.kstream.KStream;
import org.apache.kafka.streams.kstream.Produced;
import utils.StreamUtil;

import java.io.FileInputStream;
import java.time.Duration;
import java.util.Arrays;
import java.util.Properties;
import java.util.Set;
import java.util.concurrent.CountDownLatch;
import java.util.logging.Logger;

public class KafkaStreamsApplication {
    private static final Logger logger = Logger.getLogger(KafkaStreamsApplication.class.getName());

    private final String inputTopic;
    private final String commonWordsOutputTopic;
    private final String uncommonWordsOutputTopic;
    private final Properties streamProperties;
    private final Set<String> commonWords;

    public KafkaStreamsApplication(String propertiesFile, String inputTopic, String commonWordsOutputTopic, String uncommonWordsOutputTopic) {
        this.inputTopic = inputTopic;
        this.commonWordsOutputTopic = commonWordsOutputTopic;
        this.uncommonWordsOutputTopic = uncommonWordsOutputTopic;
        this.streamProperties = new Properties();
        try {
            logger.info("Loading properties file: " + propertiesFile);
            streamProperties.load(new FileInputStream(propertiesFile));
        } catch (Exception e) {
            logger.severe("Error loading properties file: " + e.getMessage());
        }
        commonWords = StreamUtil.getCommonWords();
    }

    public void run() {
        logger.info("Starting Kafka Streams Application...");
        logger.info("Input Topic: " + inputTopic);
        logger.info("Output Topics: " + commonWordsOutputTopic + ", " + uncommonWordsOutputTopic);
        logger.info("Properties: " + streamProperties.toString());

        StreamsBuilder builder = new StreamsBuilder();
        KStream<String, String> fileToLinesStream = builder.stream(inputTopic, Consumed.with(Serdes.String(), Serdes.String()));

        KStream<String, String> cleanedStream = fileToLinesStream
                .peek((key, value) -> logger.info("Processing line: " + value))
                .flatMapValues(value -> Arrays.asList(value.split("\\W+")))
                .filter((key, value) -> value.length() > 1 && !value.matches(".*\\d.*"))
                .mapValues(value -> value.toLowerCase());
        cleanedStream
                .filter((key, value) -> commonWords.contains(value))
                .groupBy((key, value) -> value) // converts the KStream to a KTable
                .count()
                .toStream() // convert the KTable to a KStream
                .to(commonWordsOutputTopic, Produced.with(Serdes.String(), Serdes.Long()));
        cleanedStream
                .filter((key, value) -> !commonWords.contains(value))
                .groupBy((key, value) -> value) // converts the KStream to a KTable
                .count()
                .toStream() // convert the KTable to a KStream
                .to(uncommonWordsOutputTopic, Produced.with(Serdes.String(), Serdes.Long()));

        // Start the Kafka Streams application
        try (KafkaStreams streams = new KafkaStreams(builder.build(), streamProperties)) {
            final CountDownLatch shutdownLatch = new CountDownLatch(1);

            Runtime.getRuntime().addShutdownHook(new Thread(() -> {
                streams.close(Duration.ofSeconds(2));
                shutdownLatch.countDown();
            }));
            try {
                streams.start();
                logger.info("Streaming has started...");
                shutdownLatch.await();
            } catch (Throwable e) {
                System.exit(1);
            }
        }
    }

    public static void main(String[] args) {
        String propertiesFile = args[0];
        String inputTopic = args[1];
        String commonWordsOutputTopic = args[2];
        String uncommonWordsOutputTopic = args[3];

        KafkaStreamsApplication kafkaStreamsApplication = new KafkaStreamsApplication(propertiesFile, inputTopic, commonWordsOutputTopic, uncommonWordsOutputTopic);
        kafkaStreamsApplication.run();
    }
}
