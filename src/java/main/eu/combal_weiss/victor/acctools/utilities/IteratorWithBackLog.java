package eu.combal_weiss.victor.acctools.utilities;

import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

public class IteratorWithBackLog<T> implements Iterator<T> {

        private Iterator<T> backLog;
        private final Iterator<T> iterator;
        
        public IteratorWithBackLog(List<T> backLog, Iterator<T> scanner) {
            this.iterator = scanner;
            resetBackLog(backLog);
        }
        
        @Override
        public boolean hasNext() {
            return backLog.hasNext() || iterator.hasNext();
        }
        
        @Override
        public T next() {
            if (backLog.hasNext())
                return backLog.next();
            return iterator.next();
        }
        
        public final void resetBackLog(List<T> backLog) {
            this.backLog = Collections.unmodifiableList(new LinkedList<>(backLog)).iterator();
        }
    }