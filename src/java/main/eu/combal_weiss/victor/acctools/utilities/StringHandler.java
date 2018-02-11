package eu.combal_weiss.victor.acctools.utilities;


public class StringHandler {

    
    /**
     * 
     * @return substring from startIndex to endIndex - 1
     */
    public String substring(String string, int startIndex, int endIndex) {
        if (string == null)
            throw new IllegalArgumentException(
                    "Null string passed as parameter to substring()");
        if (startIndex >= string.length())
            return "";
        return string.substring(startIndex, Math.min(endIndex, string.length()));
    }
    
    public String csvEscape(String string) {
        if (string == null)
            throw new IllegalArgumentException("Null argument passed to " + 
                    StringHandler.class.getSimpleName() + "'s escape method");
        char[] charArray = new char[string.length() + countCharsToEscape(string)];
        int index = 0;
        for (int i = 0; i < string.length(); i++) {
            char c = string.charAt(i);
            if (c == '"') {
                charArray[index] = '"';
                index++;
            }
            charArray[index] = c;
            index++;
        }
        return new String(charArray);
    }

    private int countCharsToEscape(String string) {
        if (string == null)
            throw new IllegalArgumentException("Null argument passed to " + 
                    StringHandler.class.getSimpleName() + 
                    "'s countCharsToEscape method");
        int count = 0;
        for (int i = 0; i < string.length(); i++) {
            char c = string.charAt(i);
            if (c == '"')
                count ++ ;
        }
        return count;
    }

    public String trimQuotes(String text) {
        if (text == null) {
            throw new IllegalArgumentException("Null string passed to trimQuotes");
        }
        // TODO : make more efficient with just one rewrite
        String result = text;
        if (result.charAt(0) == '"') {
            result = result.substring(1);
        }
        if (result.charAt(result.length() - 1) == '"') {
            result = result.substring(0, result.length() - 1);
        }
        return result;
    }
}
