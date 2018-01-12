package eu.combal_weiss.victor.acctools.formatting.cic.pdf;

import eu.combal_weiss.victor.acctools.utilities.StringHandler;
import eu.combal_weiss.victor.acctools.model.Transaction;
import java.text.DateFormat;
import java.text.ParseException;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

class TransactionParser {
    
    private static final Logger logger = Logger.getLogger(
            TransactionParser.class.getName());
    private List<Integer> columnWidths;
    private int nbColumns;
    private final DateFormat dateFormat;
    private final String lineRegex;
    private final StringHandler stringHandler = new StringHandler();

    public TransactionParser(String lineRegex, List<Integer> columnWidths, 
            DateFormat inputDateFormat) {
        this.lineRegex = lineRegex;
        this.dateFormat = inputDateFormat;
        updateColumnWidths(columnWidths);
        logger.log(Level.FINEST, "column widths passed to {0} constructor : {1}", 
                new Object[]{TransactionParser.class.getName(), this.columnWidths});
    }
    
    private int countGroups(String line, char delimiter) {
        int result = 0;
        for (int i = 0; i < line.length(); i++)
            if (line.charAt(i) == delimiter)
                result++;
        return result;
    }
    
    String[] splitLine(String line) {
        String[] result = new String[nbColumns];
        int previous = 0;
        int counter = 0;
        for(int width : columnWidths) {
            if (counter > 0) {
                result[counter - 1] = stringHandler.substring(
                        line,
                        previous,
                        width + previous).trim();
            }
            previous += width;
            counter++;
        }
        result[counter - 1] = stringHandler.substring(
                line, previous, line.length())
                .trim();
        return result;
    }    
    
    Transaction parseTransaction(String[] splitLine) {

        String amount = getAmount(splitLine[3], splitLine[4]);
        logger.log(Level.FINEST, "splitLine : {0}", Arrays.asList(splitLine));
        try {
            return new Transaction(
                    dateFormat.parse(splitLine[0]),
                    dateFormat.parse(splitLine[1]),
                    splitLine[2],
                    amount);
        } catch (ParseException ex) {
            logger.log(Level.WARNING, 
                    "Could not parse date in transaction {0}", 
                    Arrays.asList(splitLine));
            return null;
        }
    }


    private String getAmount(String debit, String credit) {
        if (debit.isEmpty() && credit.isEmpty()) {
            logger.log(Level.WARNING, "Transaction with empty amount");
            return "0";
        }
        return debit.isEmpty() ?
            trimAmount(credit) :
            "-" + trimAmount(debit);
    }

    private String trimAmount(String string) {
        Pattern regex = Pattern.compile("^" + PdfTextProcessor.AMOUNT_REGEX);
        Matcher matcher = regex.matcher(string);
        matcher.find();
        return matcher.group();
    }

    final void updateColumnWidths(List<Integer> columnWidths) {
        this.columnWidths = Collections.unmodifiableList(
                new LinkedList<>(columnWidths));
        nbColumns = countGroups(lineRegex, '(');
    }
}
