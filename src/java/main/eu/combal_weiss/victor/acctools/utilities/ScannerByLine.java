package eu.combal_weiss.victor.acctools.utilities;

import java.util.Iterator;
import java.util.Scanner;

public class ScannerByLine implements Iterator<String> {

    private final Scanner in;
    
    public ScannerByLine(Scanner in) { this.in = in; }
    
    @Override
    public boolean hasNext() {
        return in.hasNextLine();
    }

    @Override
    public String next() {
        return in.nextLine();
    }
    
}
