package eu.combal_weiss.victor.acctools.formatting.cic.pdf;

import eu.combal_weiss.victor.acctools.utilities.CommandLineUtilities;
import java.util.Scanner;

public class ConvertCicPdfTextToCsv {
    
    public static void main(String[] args) {

        new CommandLineUtilities().checkForCallOfHelp(args, ConvertCicPdfTextToCsv.class);
        
        PdfTextProcessor converter = new PdfTextProcessor(
                new Scanner(System.in));
        converter.convertToCsv(System.out);
        
        System.exit(0);
    }
        
}