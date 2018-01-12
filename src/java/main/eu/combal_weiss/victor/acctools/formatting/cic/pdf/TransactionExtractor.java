package eu.combal_weiss.victor.acctools.formatting.cic.pdf;

import eu.combal_weiss.victor.acctools.utilities.IteratorWithBackLog;
import eu.combal_weiss.victor.acctools.utilities.StringHandler;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

class TransactionExtractor implements Iterator<LineWithColumnWidths> {

    private static final Logger logger = Logger.getLogger(
            TransactionExtractor.class.getName());
    
    private final IteratorWithBackLog<String> in;
    private final Pattern startLineRegex;
    private final Pattern transactionRegex;
    private final Pattern endLineRegex;
    private final int descriptionColumnIndex;
    
    private LineWithColumnWidths next = null;
    private boolean started = false;
    
    TransactionExtractor(Iterator<String> in, Pattern startLineRegex, 
            Pattern transactionRegex, Pattern endLineRegex,
            int descriptionColumnIndex) {
        this.in = new IteratorWithBackLog(new LinkedList<>(), in);
        this.startLineRegex = startLineRegex;
        this.transactionRegex = transactionRegex;
        this.endLineRegex = endLineRegex;
        this.descriptionColumnIndex = descriptionColumnIndex;
        
        advanceDocument();
    }
    
    
    @Override
    public boolean hasNext() {
        return next != null;
    }

    @Override
    public LineWithColumnWidths next() {
        if (!hasNext())
            throw new IllegalStateException(
                    TransactionExtractor.class.getSimpleName() + 
                            " has no more transactions to extract");
        LineWithColumnWidths result = next;
        advanceDocument();
        return result;
    }
    
    private void advanceDocument() {
        if (!in.hasNext()) {
            next = null;
            return;
        }
        
        logger.log(Level.FINEST, "line received");
        String line = in.next();
        if (started && !endLineRegex.matcher(line).matches()) {
            next = new LineWithColumnWidths(line, next.columnWidths);
        } else {
            if (!started)
                started = true;
            
            // skip until find start line again
            String startLine = skipFirstLines();
            if (startLine == null || !in.hasNext()) {
                next = null;
                return;
            }
            // compute and correct column widths
            List<Integer> columnWidths = computeColumnWidths(startLine);
            List<String> backLog = correctColumnWidths(columnWidths);
            in.resetBackLog(backLog);
            
            // skip non transaction lines
            line = skipFirstTransactionLines(columnWidths);
            if (line == null) {
                next = null;
                return;
            }
            
            next = new LineWithColumnWidths(line, columnWidths);
        }
    }
    
    private String skipFirstLines() {
        String line;
        while(in.hasNext()) {
            line = in.next();
            logger.log(Level.FINEST, "line received : \n{0}", line);
            if (startLineRegex.matcher(line).matches()) {
                logger.log(Level.FINEST, "matches start line regex");
                return line;
            }
        }
        return null;
    }

    private List<Integer> computeColumnWidths(String startLine) {
        List<Integer> result = new LinkedList<>();
        Matcher matcher = startLineRegex.matcher(startLine);
        if (!matcher.matches())
            throw new IllegalStateException("computeColumnWidths called on a "
                    + "line that doesn't matche the start line regex");
        int previous = 0;
        for (int i = 1; i <= matcher.groupCount(); i++) {
            int newPosition = matcher.start(i);
            result.add(newPosition - previous);
            previous = newPosition;
        }
        return result;
    }

    private List<String> correctColumnWidths(List<Integer> columnWidths) {
        List<String> backLog = new LinkedList<>();
        
        while(in.hasNext()) {
            String line = in.next();
            backLog.add(line);
            Matcher matcher = transactionRegex.matcher(line);
            if (matcher.matches()) {
                int descriptionStart = matcher.start(1);
                correctColumnWidths(columnWidths, descriptionColumnIndex, 
                        descriptionStart);
                break;
            }
        }
        return backLog;
    }

    private void correctColumnWidths(List<Integer> columnWidths, 
            int indexToUpdate, int targetNumber) {
        
        if (indexToUpdate < 0 || indexToUpdate >= columnWidths.size())
            throw new IndexOutOfBoundsException("Trying to update value of an "
                    + "index larger than column widths list");
        // TODO : make more efficient
        int currentStart = 0;
        for (int i = 0; i < indexToUpdate; i++)
            currentStart += columnWidths.get(i);
        int diff = currentStart - targetNumber;
        columnWidths.set(indexToUpdate - 1, 
                columnWidths.get(indexToUpdate - 1) - diff);
        columnWidths.set(indexToUpdate, columnWidths.get(indexToUpdate) + diff);
    }

    
    private String skipFirstTransactionLines(List<Integer> columnWidths) {
        while (in.hasNext()) {
            String line = in.next();
            if (line.isEmpty())
                continue;
            if (transactionRegex.matcher(line).matches()
                    || hasOnlyDescription(line, columnWidths))
                return line;
        }
        return null;
    }    
    
    
    private boolean hasOnlyDescription(String line, List<Integer> columnWidths) {
        int before = 0;
        int after = 0;
        int counter = 0;
        for (int width : columnWidths) {
            if (counter < descriptionColumnIndex)
                before += width;
            else if (counter == descriptionColumnIndex)
                after = before + width;
            else
                break;
            counter++;
        }
        StringHandler stringHandler = new StringHandler();
        return 
                stringHandler.substring(line, 0, before).trim().isEmpty()
                && stringHandler.substring(line, after, line.length()).trim().isEmpty();
    }
}
