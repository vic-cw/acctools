package eu.combal_weiss.victor.acctools.formatting.cic.pdf;

import eu.combal_weiss.victor.acctools.utilities.CommandLineUtilities;
import java.util.Scanner;

public class IsCicPdfText {
    
    public static void main(String[] args) {
        
        new CommandLineUtilities().checkForCallOfHelp(args, IsCicPdfText.class);
        
        PdfTextProcessor pdfTextProcessor = new PdfTextProcessor(
                new Scanner(System.in));
        if (pdfTextProcessor.isLikelyCICPdfText())
            System.exit(0);
        else
            System.exit(1);
    }
    
}