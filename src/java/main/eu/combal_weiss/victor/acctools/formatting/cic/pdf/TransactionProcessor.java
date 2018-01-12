package eu.combal_weiss.victor.acctools.formatting.cic.pdf;

import java.util.List;

interface TransactionProcessor {

    void processLine(String line, List<Integer> columnWidths);
    
    void close();
    
}
