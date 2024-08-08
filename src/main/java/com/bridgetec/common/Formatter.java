package com.bridgetec.common;

import java.io.UnsupportedEncodingException;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class Formatter {
	
	private static final String sMeDateFormat = "yyyy.MM.dd";
	private static final String sMeDecimalFormat = "#,##0";
	private static final String sMeTimestampFormat = "yyyy-MM-dd HH:mm:ss";
	
	public static String decimalFormat( long lNumber, String sFormat ) {
		
		String sResult;
	    DecimalFormat formatter;
	    
    	if( sFormat == null || sFormat.equals( "" ) == true ) sFormat = sMeDecimalFormat;

    	try {	    	
	    	formatter = new DecimalFormat( sFormat );
	    	sResult = formatter.format( lNumber );
	    } catch( ArithmeticException ae ) {
    		sResult = "";
	    } catch( Exception e ) {
	    	sResult = "";
    	}

	    return sResult;
		
	}
	
	public static String decimalFormat( double dNumber, String sFormat ) {
		
		String sResult;
	    DecimalFormat formatter;
	    
    	if( sFormat == null || sFormat.equals( "" ) == true ) sFormat = sMeDecimalFormat;

    	try {	    	
	    	formatter = new DecimalFormat( sFormat );
	    	sResult = formatter.format( dNumber );
	    } catch( ArithmeticException ae ) {
    		sResult = "";
	    } catch( Exception e ) {
	    	sResult = "";
    	}

	    return sResult;
		
	}
	
	public static double stringToDecimal( String sNumber ) {
		
		double dResult;
		
		if( sNumber == null || sNumber.equals( "" ) == true ) sNumber = "0";
		
    	try {	    	
    		dResult = Double.parseDouble( NumberFormat.getInstance().format( sNumber ) );
	    } catch( NumberFormatException nfe ) {
    		dResult = 0;
	    } catch( IllegalArgumentException iae ) {
	    	dResult = 0;
	    } catch( Exception e ) {
	    	dResult = 0;
    	}

	    return dResult;
	}
	

	public static String dateToString( Date date , String sFormat ) {
		
	    String sResult;
	    SimpleDateFormat formatter; 
	    
	    if( sFormat == null || sFormat.equals( "" ) == true ) sFormat = sMeDateFormat;
	    
	    try {	    
	    	formatter = new SimpleDateFormat( sFormat );    
	    	sResult = formatter.format( date );
	    } catch( IllegalArgumentException iae ) {
	    	sResult = "";
	    } catch( Exception e ) {
	    	sResult = "";
	    }
	    
	    return sResult;		
		
	}
	
	public static Date stringToDate( String sDate , String sFormat ) {
		
	    Date date;
	    SimpleDateFormat formatter;
	    
	    if( sFormat == null || sFormat.equals( "" ) == true ) sFormat = sMeDateFormat;

	    try {
	    	formatter = new SimpleDateFormat( sFormat );    
	    	date = formatter.parse( sDate );
	    } catch( IllegalArgumentException iae ) {
	    	date = null;
	    } catch( Exception e ) {
	    	date = null;
	    }

	    return date;

	}
	
	public static String dateToTimestamp( Date oDate, String sFormat ) {
		
	    String sResult;
	    SimpleDateFormat formatter;
	    
	    if( sFormat == null || sFormat.equals( "" ) == true ) sFormat = sMeTimestampFormat;
	    
	    try {	    
	    	formatter = new SimpleDateFormat( sFormat );    
	    	sResult = formatter.format( oDate );
	    } catch( IllegalArgumentException iae ) {
	    	sResult = "";
	    } catch( Exception e ) {
	    	sResult = "";
	    }
	    
	    return sResult;		

	}
	
	public static String cutByteUTF8String(String source, int slength) throws UnsupportedEncodingException {
        byte[] utf8 = source.getBytes("UTF-8");
        if (utf8.length <= slength) {
            return source;
        }
        int n16 = 0;
        boolean extraLong = false;
        int i = 0;
        while (i < slength) {
            // Unicode characters above U+FFFF need 2 words in utf16
            extraLong = ((utf8[i] & 0xF0) == 0xF0);
            if ((utf8[i] & 0x80) == 0) {
                i += 1;
            } else {
                int b = utf8[i];
                while ((b & 0x80) > 0) {
                    ++i;
                    b = b << 1;
                }
            }
            if (i <= slength) {
                n16 += (extraLong) ? 2 : 1;
            }
        }
        return source.substring(0, n16);
    }
    
    public static double round(double d, int n) {
        return Math.round(d * Math.pow(10, n)) / Math.pow(10, n);
     }
}