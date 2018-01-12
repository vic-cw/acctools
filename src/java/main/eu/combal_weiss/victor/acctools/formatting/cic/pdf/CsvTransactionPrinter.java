package eu.combal_weiss.victor.acctools.formatting.cic.pdf;

import eu.combal_weiss.victor.acctools.utilities.StringHandler;
import eu.combal_weiss.victor.acctools.model.Transaction;
import java.io.PrintStream;
import java.text.DateFormat;
import java.util.function.Consumer;

class CsvTransactionPrinter implements Consumer<Transaction> {

    private final PrintStream out;
    private final char delim;
    private final DateFormat outputDateFormat;
    private final StringHandler stringHandler = new StringHandler();
    
    CsvTransactionPrinter(PrintStream out, char delim, 
            DateFormat outputDateFormat) {
        this.out = out;
        this.delim = delim;
        this.outputDateFormat = outputDateFormat;
    }
    
    @Override
    public void accept(Transaction transaction) {
        out.
                append(outputDateFormat.format(transaction.getDate())).
                append(delim).
                append(outputDateFormat.format(transaction.getValueDate())).
                append(delim).
                append('"').
                append(stringHandler.csvEscape(transaction.getDescription())).
                append('"').
                append(delim).
                append('"').append(transaction.getAmount()).append('"').
                println();
    }
    
}
