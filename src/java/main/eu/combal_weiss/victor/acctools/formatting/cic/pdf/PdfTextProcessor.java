package eu.combal_weiss.victor.acctools.formatting.cic.pdf;

import eu.combal_weiss.victor.acctools.utilities.ScannerByLine;
import java.io.PrintStream;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Iterator;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;

class PdfTextProcessor {

    private final Scanner in;
    
    private static final Pattern PDF_FIRST_LINE = Pattern.compile(
            " *Cr.dit +Industriel +et +Commercial *");
    
    private static final String START_LINE = 
            " *(Date) *(Date +valeur) *(Op.ration) *(D.bit +(?:euros|EUROS)) *"
            + "(Cr.dit +(?:euros|EUROS))";
    private static final Pattern START_LINE_REGEX = 
            Pattern.compile(START_LINE, Pattern.UNICODE_CASE);
    
    private static final int DESCRIPTION_COLUMN_INDEX = 3;
    
    private static final String DATE_REGEX = 
            "[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]";
    static final String AMOUNT_REGEX = 
            "([0-9]|[0-9][0-9]|[0-9][0-9][0-9])(\\.[0-9][0-9][0-9])*,[0-9][0-9]";
    private static final Pattern TRANSACTION_REGEX = Pattern.compile(
            " *" + DATE_REGEX + " +" + DATE_REGEX + 
            " +(.+)" + "(?: .*)?");
    
    
    private static final Pattern END_LINE_REGEX = Pattern.compile(
            "("
            + " *\\(GE\\) : prot.g. par la Garantie de l'Etat *"
                    + "(<<Suite au verso>>)?" +
            "|"
            + " *R.f : [0-9]+ +SOLDE CREDITEUR AU " + 
                    DATE_REGEX + " +" + AMOUNT_REGEX +
                    "( +.*)?" +
            "|"
            + " *Information sur la protection des comptes : *"
                    + "(<<Suite au verso>>)?" +
            ")");
    
    private static final DateFormat INPUT_DATE_FORMAT = 
            new SimpleDateFormat("dd/MM/yyyy");
    private static final DateFormat OUTPUT_DATE_FORMAT = 
            new SimpleDateFormat("yyyy-MM-dd");
    
    private static final Logger logger = Logger.getLogger(PdfTextProcessor.class.getName());
    
    PdfTextProcessor(Scanner in) {
        this.in = in;
    }

    void convertToCsv(PrintStream out) {
        
        logger.log(Level.FINEST, "Processing data : ");

        TransactionProcessor transactionProcessor = 
                new SimpleTransactionProcessor(START_LINE, INPUT_DATE_FORMAT, 
                    new CsvTransactionPrinter(out, ',', OUTPUT_DATE_FORMAT));
        Iterator<LineWithColumnWidths> transactionExtractor = 
                new TransactionExtractor(
                        new ScannerByLine(in),
                        START_LINE_REGEX, TRANSACTION_REGEX, END_LINE_REGEX, 
                        DESCRIPTION_COLUMN_INDEX);
        while(transactionExtractor.hasNext()){
            LineWithColumnWidths next = 
                    transactionExtractor.next();
            transactionProcessor.processLine(
                    next.line, 
                    next.columnWidths);
        }
        transactionProcessor.close();
    }
    
    boolean isLikelyCICPdfText() {
        String firstLine = skipEmptyLines(in);
        if (firstLine == null || !PDF_FIRST_LINE.matcher(firstLine).matches()) {
            logger.log(Level.FINEST, "Input doesn't appear to be text from CIC "
                    + "Pdf statement because opening line doesn't match.");
            return false;
        }
        return hasMatchingLine(in, START_LINE_REGEX);
    }

    private String skipEmptyLines(Scanner in) {
        while (in.hasNextLine()) {
            String line = in.nextLine();
            if (!line.isEmpty())
                return line;
        }
        return null;
    }

    private boolean hasMatchingLine(Scanner in, Pattern startLineRegex) {
        while (in.hasNextLine()) {
            String line = in.nextLine();
            if (!line.isEmpty())
                logger.log(Level.FINEST, "Checking line : '{0}'", line);
            if (startLineRegex.matcher(line).matches())
                return true;
        }
        return false;
    }
}
