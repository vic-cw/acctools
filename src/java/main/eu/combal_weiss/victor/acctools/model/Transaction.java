package eu.combal_weiss.victor.acctools.model;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class Transaction {

    private final Date date;
    private final Date valueDate;
    private final double amount;
    private String description;
    
    public Transaction(Date date, Date valueDate, 
            String description, double amount) {
        if (date == null || valueDate == null || description == null)
            throw new IllegalArgumentException(
                    "Null argument passed to Transaction constructor : " + 
                            date + ", " + valueDate + ", " 
                            + amount + ", " + description);
        this.date = date;
        this.valueDate = valueDate;
        this.amount = amount;
        this.description = description;
    }
    
    public void appendToDescription(String suffix) {
        description = description + " " + suffix;
    }
    
    public Date getDate() { return (Date)date.clone(); }
    
    public Date getValueDate() { return (Date)valueDate.clone(); }
    
    public double getAmount() { return amount; }
    
    public String getDescription() { return description; }

    @Override
    public String toString() {
        DateFormat dateFormat =  new SimpleDateFormat("yyyy-MM-dd");
        return dateFormat.format(date) + ", " + dateFormat.format(valueDate) + ", "
                + "\"" + description + "\"" + ", " + amount;
    }
}
