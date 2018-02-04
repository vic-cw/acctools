package eu.combal_weiss.victor.acctools.formatting.cic.pdf;

import eu.combal_weiss.victor.acctools.model.Transaction;
import java.text.DateFormat;
import java.text.NumberFormat;
import java.util.LinkedList;
import java.util.List;
import java.util.function.Consumer;

class SimpleTransactionProcessor implements TransactionProcessor {

    private final TransactionParser parser;
    private final Consumer<Transaction> transactionPrinter;
    private Transaction current = null;
    
    SimpleTransactionProcessor(
            String lineRegex,
            DateFormat inputDateFormat,
            NumberFormat inputAmountFormat,
            Consumer<Transaction> transactionPrinter) {
        this.parser = new TransactionParser(lineRegex, new LinkedList<>(), 
                inputDateFormat, inputAmountFormat);
        this.transactionPrinter = transactionPrinter;
    }
    
    @Override
    public void processLine(String line, List<Integer> columnWidths) {
        parser.updateColumnWidths(columnWidths);
        if (line.length() == 0)
            return;
        String[] splitLine = parser.splitLine(line);
        if (current != null && splitLine[0].isEmpty()) {
            current.appendToDescription(splitLine[2]);
        } else {
            if (current != null)
                transactionPrinter.accept(current);
            current = parser.parseTransaction(splitLine);
        }   
    }

    @Override
    public void close() {
        if(current != null)
            transactionPrinter.accept(current);
        current = null;
    }
    
}
