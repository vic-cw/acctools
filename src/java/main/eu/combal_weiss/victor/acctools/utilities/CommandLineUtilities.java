package eu.combal_weiss.victor.acctools.utilities;

import java.io.PrintStream;
import java.text.MessageFormat;
import java.util.Scanner;

public class CommandLineUtilities {

    private static final String HELP_ARG = "-h";    
    
    public void checkForCallOfHelp(String[] args, Class<?> cl) {
        for(String s : args) {
            switch(s) {
                case HELP_ARG:
                    printUsageMessage(cl, System.out);
                    System.exit(0);
            }
        }

    }
    
    public void printUsageMessage(Class<?> cl, PrintStream out) {
        Scanner in = new Scanner(
                cl.getResourceAsStream(
                        cl.getSimpleName()
                        + "_" +
                        "UsageMessage.txt"));
        StringBuilder sb = new StringBuilder();
        while (in.hasNextLine()) {
            sb.append(in.nextLine()).append('\n');
        }
        out.println(MessageFormat.format(sb.toString(), new Object[]{
            cl.getPackage().getName(),
            cl.getSimpleName()}));
    }
    
}
