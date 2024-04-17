package kafka.consumer;

import org.apache.kafka.clients.consumer.ConsumerRebalanceListener;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.OffsetAndMetadata;
import org.apache.kafka.common.TopicPartition;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

public class KafkaConsumerRebalanceListener implements ConsumerRebalanceListener {
    private static final Logger logger = Logger.getLogger(KafkaConsumerRebalanceListener.class.getName());

    private final KafkaConsumer<String, Long> consumer;
    private final Map<TopicPartition, OffsetAndMetadata> currentOffsets;

    public KafkaConsumerRebalanceListener(KafkaConsumer<String, Long> consumer) {
        this.currentOffsets = new HashMap<>();
        this.consumer = consumer;
    }

    public void addOffsetToTrack(String topic, int partition, long offset) {
        currentOffsets.put(
                new TopicPartition(topic, partition),
                new OffsetAndMetadata(offset + 1, null));
    }

    public Map<TopicPartition, OffsetAndMetadata> getCurrentOffsets() {
        return currentOffsets;
    }

    @Override
    public void onPartitionsRevoked(Collection<TopicPartition> collection) {
        logger.info("onPartitionsRevoked callback triggered");
        logger.info("Committing offsets: " + currentOffsets);

        consumer.commitSync(currentOffsets);
    }

    @Override
    public void onPartitionsAssigned(Collection<TopicPartition> collection) {
        logger.info("onPartitionsAssigned callback triggered");
        logger.info("Partitions assigned: " + collection);
    }

    @Override
    public void onPartitionsLost(Collection<TopicPartition> partitions) {
        ConsumerRebalanceListener.super.onPartitionsLost(partitions);
    }
}
