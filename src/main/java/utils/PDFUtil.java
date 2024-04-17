package utils;


import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

public class PDFUtil {
    private static final Logger logger = Logger.getLogger(PDFUtil.class.getName());

    private static String getPDFText(String pdfFile) {
        try (PDDocument document = Loader.loadPDF(new File(pdfFile))) {
            return new PDFTextStripper().getText(document);
        } catch (Exception e) {
            logger.severe("Error reading PDF file: " + e.getMessage());
        }
        return "";
    }

    public static Map<String, String> getPDFTextForAllFilesInDirectory(String directory) {
        Map<String, String> pdfTextMap = new HashMap<>();
        File[] files = new File(directory).listFiles();
        if (files != null) {
            for (File file : files) {
                if (file.isFile() && file.getName().endsWith(".pdf")) {
                    logger.info("Processing PDF file: " + file.getName());
                    pdfTextMap.put(file.getName(), getPDFText(file.getAbsolutePath()));
                }
            }
        }
        return pdfTextMap;
    }

}
