package utils;

import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.logging.Logger;

public class ConsumerUtil {
    private static final Logger logger = Logger.getLogger(ConsumerUtil.class.getName());

    private static final Set<String> commonWords = StreamUtil.getCommonWords();

    public static Map<String, Long> getTopNWordsFromMap(Map<String, Long> wordCountMap, int n) {
        Map<String, Long> topNWords = new LinkedHashMap<>();
        for (Map.Entry<String, Long> entry : wordCountMap.entrySet()) {
            if(commonWords.contains(entry.getKey())) {
                topNWords.put(entry.getKey(), entry.getValue());
                continue;
            }

            boolean isPrefix = false;
            String prefix = "";
            if (!topNWords.isEmpty()) {
                for (String key : topNWords.keySet()) {
                    if (!key.isEmpty()
                            && (key.startsWith(entry.getKey()) || entry.getKey().startsWith(key))
                            && Math.abs(key.length() - entry.getKey().length()) <= 2) {
                        isPrefix = true;
                        prefix = key;
                        break;
                    }
                }
            }
            if (isPrefix) {
                topNWords.put(prefix, topNWords.get(prefix) + entry.getValue());
            } else {
                topNWords.put(entry.getKey(), entry.getValue());
            }
        }
        Map<String, Long> topNWordsResult = new LinkedHashMap<>();
        topNWords.entrySet().stream()
                .sorted(Map.Entry.comparingByValue(Comparator.reverseOrder()))
                .limit(n)
                .forEachOrdered(x -> topNWordsResult.put(x.getKey(), x.getValue()));
        logger.info("Top " + n + " words: " + topNWordsResult);
        return topNWordsResult;
    }
}
