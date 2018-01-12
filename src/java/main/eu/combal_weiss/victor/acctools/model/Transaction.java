package eu.combal_weiss.victor.acctools.model;

import java.util.Date;

public class Transaction {

    private final Date date;
    private final Date valueDate;
    private final String amount;
    private String description;
    
    public Transaction(Date date, Date valueDate, 
            String description, String amount) {
        if (date == null || valueDate == null 
                || amount == null || description == null)
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
    
    public String getAmount() { return amount; }
    
    public String getDescription() { return description; }
    
}
