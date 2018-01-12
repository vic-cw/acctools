package eu.combal_weiss.victor.acctools.formatting.cic.pdf;

import java.util.Collections;
import java.util.List;


/*
 * Immutable
 */
class LineWithColumnWidths {

    final String line;
    final List<Integer> columnWidths;

    public LineWithColumnWidths(String line, List<Integer> columnWidths) {
        this.line = line;
        this.columnWidths = Collections.unmodifiableList(columnWidths);
    }
}