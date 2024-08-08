package com.bridgetec.common.osu.veloce;

import java.text.ParsePosition;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

import com.bridgetec.common.util.veloce.StringUtility;

public class DateUtil {
	public DateUtil() {
	}

	public static String getTime() {
		return getTime("yyyyMMddHHmmss");
	}

	public static String getDate() {
		return getTime("yyyyMMdd");
	}
	public static String getDateM() {
		return getTime("yyyyMM");
	}

	public static String date(String sParam) {
		Calendar cal = Calendar.getInstance();
		int yy = cal.get(Calendar.YEAR);
		int mo = cal.get(Calendar.MONTH) + 1;
		int dd = cal.get(Calendar.DAY_OF_MONTH);

		String yyy = null;
		String mmo = null;
		String ddd = null;

		yyy = "" + yy;
		if (mo < 10)
			mmo = "0" + mo;
		else
			mmo = "" + mo;
		if (dd < 10)
			ddd = "0" + dd;
		else
			ddd = "" + dd;

		StringBuffer addDate = new StringBuffer();
		addDate.append(yyy)
				.append(sParam)
				.append(mmo)
				.append(sParam)
				.append(ddd);
		return addDate.toString();
	}
	public static String date2(String sParam) {
		Calendar cal = Calendar.getInstance();
		int yy = cal.get(Calendar.YEAR);
		int mo = cal.get(Calendar.MONTH) -5;
		int dd = cal.get(Calendar.DAY_OF_MONTH);

		String yyy = null;
		String mmo = null;
		String ddd = null;

		yyy = "" + yy;
		if (mo < 10)
			mmo = "0" + mo;
		else
			mmo = "" + mo;
		if (dd < 10)
			ddd = "0" + dd;
		else
			ddd = "" + dd;

		StringBuffer addDate = new StringBuffer();
		addDate.append(yyy)
				.append(sParam)
				.append(mmo)
				.append(sParam)
				.append(ddd);
		return addDate.toString();
	}
	public static String getTime(String s) {
		Calendar calendar = Calendar.getInstance();
		SimpleDateFormat simpledateformat = new SimpleDateFormat(s);
		return simpledateformat.format(calendar.getTime());
	}

	public static java.util.Date stringToDate(String s, String s1) {
		SimpleDateFormat simpledateformat = new SimpleDateFormat(s1);
		ParsePosition parseposition = new ParsePosition(0);
		return simpledateformat.parse(s, parseposition);
	}

	public static Calendar stringToCalendar(String s, String s1) {
		SimpleDateFormat simpledateformat = new SimpleDateFormat(s1);
		ParsePosition parseposition = new ParsePosition(0);
		java.util.Date date = simpledateformat.parse(s, parseposition);
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);
		return calendar;
	}

	public static String formatDate(java.util.Date date, String s) {
		SimpleDateFormat simpledateformat = new SimpleDateFormat(s);
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);
		return simpledateformat.format(calendar.getTime());
	}

	public static String formatCalendar(Calendar calendar, String s) {
		SimpleDateFormat simpledateformat = new SimpleDateFormat(s);
		return simpledateformat.format(calendar.getTime());
	}

	public static boolean isLeapYear(int i) {
		if (i % 4 != 0)
			return false;
		if (i % 400 == 0)
			return true;
		else
			return i % 100 != 0;
	}

	public static int lastDate(int i, int j) {
		int ai[] = { 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
		if (j > 12 || j < 0)
			j = 0;
		if (j == 2 && isLeapYear(i))
			return ai[j] + 1;
		else
			return ai[j];
	}

	public static int daysDiff(String s, String s1, String s2) {
		if (s == null || s1 == null) {
			return 0;
		} else {
			java.util.Date date = stringToDate(s, s2);
			java.util.Date date1 = stringToDate(s1, s2);
			
			long dateGetTime = (date == null) ? 0 : date.getTime();
			long date1GetTime = (date1 == null) ? 0 : date1.getTime();
			
//			return (int) ((date1.getTime() - date.getTime()) / 0x5265c00L);
			return (int) ((date1GetTime - dateGetTime) / 0x5265c00L);
		}
	}
	
	public static long timeDiff(String s, String s1, String s2) {
		if (s == null || s1 == null) {
			return 0;
		} else {
			java.util.Date date = stringToDate(s, s2);
			java.util.Date date1 = stringToDate(s1, s2);
			
			long dateGetTime = (date == null) ? 0 : date.getTime();
			long date1GetTime = (date1 == null) ? 0 : date1.getTime();
			
//			return ((date1.getTime() - date.getTime()));
			return ((date1GetTime - dateGetTime));
		}
	}
	
	public static int compareDate(String s, String s1, String s2) {
		Calendar calendar = stringToCalendar(s, s2);
		Calendar calendar1 = stringToCalendar(s1, s2);
		return compareDate(calendar, calendar1);
	}

	public static int compareDate(java.util.Date date, java.util.Date date1) {
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);
		Calendar calendar1 = Calendar.getInstance();
		calendar1.setTime(date1);
		return compareDate(calendar, calendar1);
	}

	public static int compareDate(Calendar calendar, Calendar calendar1) {
		byte byte0 = 9;
		if (calendar.before(calendar1))
			byte0 = -1;
		if (calendar.after(calendar1))
			byte0 = 1;
		if (calendar.equals(calendar1))
			byte0 = 0;
		return byte0;
	}

	public static Date rollYears(java.util.Date date, int i) {
		GregorianCalendar gregoriancalendar = new GregorianCalendar();
		gregoriancalendar.setTime(date);
		gregoriancalendar.add(1, i);
		return new Date(gregoriancalendar.getTime().getTime());
	}

	public static Date rollMonths(java.util.Date date, int i) {
		GregorianCalendar gregoriancalendar = new GregorianCalendar();
		gregoriancalendar.setTime(date);
		gregoriancalendar.add(2, i);
		return new Date(gregoriancalendar.getTime().getTime());
	}

	public static Date rollDays(java.util.Date date, int i) {
		GregorianCalendar gregoriancalendar = new GregorianCalendar();
		gregoriancalendar.setTime(date);
		gregoriancalendar.add(5, i);
		return new Date(gregoriancalendar.getTime().getTime());
	}

	public static String getTomorrow() {
		return getDate(1, "yyyyMMdd");
	}

	public static String getTomorrow(String s) {
		return getDate(1, s);
	}

	public static String getYesterday() {
		return getDate(-1, "yyyyMMdd");
	}

	public static String getYesterday(String s) {
		return getDate(-1, s);
	}

	public static String getDate(int i) {
		return getDate(i, "yyyyMMdd");
	}

	public static String getDate(int i, String s) {
		GregorianCalendar gregoriancalendar = new GregorianCalendar();
		SimpleDateFormat simpledateformat = new SimpleDateFormat(s);
		gregoriancalendar.add(5, i);
		return simpledateformat.format(gregoriancalendar.getTime());
	}

	public static String dateFilter(String s, String s1) {
		if (s == null || s.length() < 14 || s1.length() < 2)
			return "";
		String s2 = "";
		int i = Integer.parseInt(s.substring(0, 4));
		int j = Integer.parseInt(s.substring(2, 4));
		int k = Integer.parseInt(s.substring(4, 6));
		int l = Integer.parseInt(s.substring(6, 8));
		int i1 = Integer.parseInt(s.substring(8, 10));
		int j1;
		if (i1 > 12)
			j1 = i1 - 12;
		else
			j1 = i1;
		int k1 = Integer.parseInt(s.substring(10, 12));
		int l1 = Integer.parseInt(s.substring(12, 14));
		s2 = StringUtility.replaceString(s1, "YYYY", intToString(i));
		s2 = StringUtility.replaceString(s2, "YY", intToString(j));
		s2 = StringUtility.replaceString(s2, "MM", intToString(k));
		s2 = StringUtility.replaceString(s2, "DD", intToString(l));
		s2 = StringUtility.replaceString(s2, "HH24", intToString(i1));
		s2 = StringUtility.replaceString(s2, "HH", intToString(j1));
		s2 = StringUtility.replaceString(s2, "MI", intToString(k1));
		s2 = StringUtility.replaceString(s2, "SS", intToString(l1));
		return s2;
	}

	public static String dateFilter(String s, String s1, boolean flag) {
		if (s == null || s.length() < 14 || s1.length() < 2)
			return "";
		String s2 = "";
		if (flag) {
			int j2 = Integer.parseInt(s.substring(8, 10));
			int j1;
			if (j2 > 12)
				j1 = j2 - 12;
			else
				j1 = j2;
			String s4 = intToString(j1);
			if (s4.length() <= 1)
				s4 = "0" + s4;
			s2 = StringUtility.replaceString(s1, "YYYY", s.substring(0, 4));
			s2 = StringUtility.replaceString(s2, "YY", s.substring(2, 4));
			s2 = StringUtility.replaceString(s2, "MM", s.substring(4, 6));
			s2 = StringUtility.replaceString(s2, "DD", s.substring(6, 8));
			s2 = StringUtility.replaceString(s2, "HH24", s.substring(8, 10));
			s2 = StringUtility.replaceString(s2, "HH", s4);
			s2 = StringUtility.replaceString(s2, "MI", s.substring(10, 12));
			s2 = StringUtility.replaceString(s2, "SS", s.substring(12, 14));
		} else {
			int i = Integer.parseInt(s.substring(0, 4));
			int j = Integer.parseInt(s.substring(2, 4));
			int k = Integer.parseInt(s.substring(4, 6));
			int l = Integer.parseInt(s.substring(6, 8));
			int i1 = Integer.parseInt(s.substring(8, 10));
			int k1;
			if (i1 > 12)
				k1 = i1 - 12;
			else
				k1 = i1;
			int l1 = Integer.parseInt(s.substring(10, 12));
			int i2 = Integer.parseInt(s.substring(12, 14));
			s2 = StringUtility.replaceString(s1, "YYYY", intToString(i));
			s2 = StringUtility.replaceString(s2, "YY", intToString(j));
			s2 = StringUtility.replaceString(s2, "MM", intToString(k));
			s2 = StringUtility.replaceString(s2, "DD", intToString(l));
			s2 = StringUtility.replaceString(s2, "HH24", intToString(i1));
			s2 = StringUtility.replaceString(s2, "HH", intToString(k1));
			s2 = StringUtility.replaceString(s2, "MI", intToString(l1));
			s2 = StringUtility.replaceString(s2, "SS", intToString(i2));
		}
		return s2;
	}

	private static String intToString(int i) {
		return (new Integer(i)).toString();
	}
	
	public static String date(String str, String kindStr) {

		String temp = null;
		int len = str.length();

		if (len != 8)
			return str;
		if ((str.equals("00000000"))||(str.equals("       0")))
			 return "";
		temp = str.substring(0,4) 
				+ kindStr + str.substring(4,6)
				+ kindStr + str.substring(6,8);

	  	return  temp;
	}
	
	public static String month(String str, String kindStr) {

		String temp = null;
		int len = str.length();

		if (len != 6)
			return str;
		if ((str.equals("000000"))||(str.equals("     0")))
			 return "";
		temp = str.substring(0,4) 
				+ kindStr + str.substring(4,6);

	  	return  temp;
	}
	
	public static String time(String str, String kindStr) {

		String temp=null;
		if (str==null) return "";

		int len = str.length();
		if (len != 6) return str;

		temp = str.substring(0,2) + kindStr + str.substring(2,4)
			+ kindStr + str.substring(4,6);

  		return  temp;
	}
	
	
	/**
	 * return add day to date strings
	 * @param String date string
	 * @param int 더할 일수
	 * @return int 날짜 형식이 맞고, 존재하는 날짜일 때 일수 더하기
	 *           형식이 잘못 되었거나 존재하지 않는 날짜: java.text.ParseException 발생
	 */
	public static String addDays(String s, int day) throws java.text.ParseException {
		return addDays(s, day, "yyyyMMdd");
	}
	/**
	 * return add day to date strings with user defined format.
	 * @param String date string
	 * @param int 더할 일수
	 * @param format string representation of the date format. For example, "yyyy-MM-dd".
	 * @return int 날짜 형식이 맞고, 존재하는 날짜일 때 일수 더하기
	 *           형식이 잘못 되었거나 존재하지 않는 날짜: java.text.ParseException 발생
	 */
	public static String addDays(String s, int day, String format) throws java.text.ParseException{
 		java.text.SimpleDateFormat formatter =
		    new java.text.SimpleDateFormat (format, java.util.Locale.KOREA);
		java.util.Date date = check(s, format);

		date.setTime(date.getTime() + ((long)day * 1000 * 60 * 60 * 24));
		return formatter.format(date);
	}
	/**
	 * return add month to date strings
	 * @param String date string
	 * @param int 더할 월수
	 * @return int 날짜 형식이 맞고, 존재하는 날짜일 때 월수 더하기
	 *           형식이 잘못 되었거나 존재하지 않는 날짜: java.text.ParseException 발생
	 */
	public static String addMonths(String s, int month) throws Exception {
		return addMonths(s, month, "yyyyMMdd");
	}
	/**
	 * return add month to date strings with user defined format.
	 * @param String date string
	 * @param int 더할 월수
	 * @param format string representation of the date format. For example, "yyyy-MM-dd".
	 * @return int 날짜 형식이 맞고, 존재하는 날짜일 때 월수 더하기
	 *           형식이 잘못 되었거나 존재하지 않는 날짜: java.text.ParseException 발생
	 */
	public static String addMonths(String s, int addMonth, String format) throws Exception {
 		java.text.SimpleDateFormat formatter =
		    new java.text.SimpleDateFormat (format, java.util.Locale.KOREA);
		java.util.Date date = check(s, format);

 		java.text.SimpleDateFormat yearFormat =
		    new java.text.SimpleDateFormat("yyyy", java.util.Locale.KOREA);
 		java.text.SimpleDateFormat monthFormat =
		    new java.text.SimpleDateFormat("MM", java.util.Locale.KOREA);
 		java.text.SimpleDateFormat dayFormat =
		    new java.text.SimpleDateFormat("dd", java.util.Locale.KOREA);
		int year = Integer.parseInt(yearFormat.format(date));
		int month = Integer.parseInt(monthFormat.format(date));
		int day = Integer.parseInt(dayFormat.format(date));

		month += addMonth;
		if (addMonth > 0) {
			while (month > 12) {
				month -= 12;
				year += 1;
			}
		} else {
			while (month <= 0) {
				month += 12;
				year -= 1;
			}
		}
 		java.text.DecimalFormat fourDf = new java.text.DecimalFormat("0000");
 		java.text.DecimalFormat twoDf = new java.text.DecimalFormat("00");
		String tempDate = String.valueOf(fourDf.format(year))
						 + String.valueOf(twoDf.format(month))
						 + String.valueOf(twoDf.format(day));
		java.util.Date targetDate = null;

		try {
			targetDate = check(tempDate, "yyyyMMdd");
		} catch(java.text.ParseException pe) {
			day = lastDay(year, month);
			tempDate = String.valueOf(fourDf.format(year))
						 + String.valueOf(twoDf.format(month))
						 + String.valueOf(twoDf.format(day));
			targetDate = check(tempDate, "yyyyMMdd");
		}

		return formatter.format(targetDate);
	}
	public static String addYears(String s, int year) throws java.text.ParseException {
		return addYears(s, year, "yyyyMMdd");
	}
	public static String addYears(String s, int year, String format) throws java.text.ParseException {
 		java.text.SimpleDateFormat formatter =
		    new java.text.SimpleDateFormat (format, java.util.Locale.KOREA);
		java.util.Date date = check(s, format);
		date.setTime(date.getTime() + ((long)year * 1000 * 60 * 60 * 24 * (365 + 1)));
		return formatter.format(date);
	}
	
	/**
	 * check date string validation with an user defined format.
	 * @param s date string you want to check.
	 * @param format string representation of the date format. For example, "yyyy-MM-dd".
	 * @return date java.util.Date
	 */
	public static java.util.Date check(String s, String format) throws java.text.ParseException {
		if ( s == null )
			throw new java.text.ParseException("date string to check is null", 0);
		if ( format == null )
			throw new java.text.ParseException("format string to check date is null", 0);

		java.text.SimpleDateFormat formatter =
			new java.text.SimpleDateFormat (format, java.util.Locale.KOREA);
		java.util.Date date = null;
		try {
			date = formatter.parse(s);
		}
		catch(java.text.ParseException e) {
			/*
			throw new java.text.ParseException(
				e.getMessage() + " with format \"" + format + "\"",
				e.getErrorOffset()
			);
			*/
			throw new java.text.ParseException(" wrong date:\"" + s +
			"\" with format \"" + format + "\"", 0);
		}

		if ( ! formatter.format(date).equals(s) )
			throw new java.text.ParseException(
				"Out of bound date:\"" + s + "\" with format \"" + format + "\"",
				0
			);
		return date;
	}
	
	private static int lastDay(int year, int month) throws java.text.ParseException {
		int day = 0;
		switch(month)
		{
			case 1:
			case 3:
			case 5:
			case 7:
			case 8:
			case 10:
			case 12: day = 31;
					 break;
			case 2: if ((year % 4) == 0) {
						if ((year % 100) == 0 && (year % 400) != 0) { day = 28; }
						else { day = 29; }
					} else { day = 28; }
					break;
			default: day = 30;
		}
		return day;
	}
	
	public static String getSecToTime(long seconds) {
		StringBuffer	secChgRslt	= new StringBuffer();
		long hours = seconds / 3600;
		long temp = seconds % 3600;
		long mins = temp / 60;
		temp = temp % 60;
		long secs = temp;
		secChgRslt.append(StringUtility.padLeft(Long.toString(hours),'0', 2))
				.append( ":")
				.append(StringUtility.padLeft(Long.toString(mins), '0', 2))
				.append(":")
				.append(StringUtility.padLeft(Long.toString(secs), '0', 2));
		return secChgRslt.toString();
	}
	
	public static int getTimeToSec(int hour, int min, int sec) {
		int hours = hour * 3600;
		int mins = min * 60;
		int secs = hours + mins + sec;
		return secs;
	}

	/** 
	 * 2011-02-11 santra
	 * srcFmt형식의 date를 입력하면 destFmt형식의 date를 리턴함
	 * 입력된 date가 null일 경우 ""를 리턴, 
	 * Comn.fmtDate("20001008", "yyyyMMdd", "yyyy-MM-dd"); 
	 * Comn.fmtDate("2000.10.08.","yyyy.MM.dd." "yyyy/MM/dd"); 
	 * 
	 * 2011-04-14 16:32:24.329 -> yyyy-MM-dd HH:mm:ss.SSS
	 * 
	 * @param date "20001010"
	 * @param srcFmt "yyyyMMdd"
	 * @param destFmt "yyyy-MM-dd"
	 * @return String 2000-10-10
	*/
	public static String fmtDate(String date, String srcFmt, String destFmt){
		java.text.SimpleDateFormat srcFormat;
		java.text.SimpleDateFormat destFormat;
		java.util.Date targetDate;
		String result = "";

		if (date.trim().length() > 0) {

			srcFormat = new java.text.SimpleDateFormat(srcFmt);
			destFormat = new java.text.SimpleDateFormat(destFmt);
		
			try {
				targetDate = srcFormat.parse(date);
			} catch (IllegalArgumentException iae) {
				return date;
			} catch (Exception e) {
				return date;
			}
			result = destFormat.format(targetDate);

		}
		return result;
	}	
	
	public static String fmtDate(Object date, String srcFmt, String destFmt){
		return fmtDate(date+"", srcFmt, destFmt);
	}	
	
    /**
     * 월 마지막 날 가져오기
     *
     * @param yyyyMM
     * @return
     * @throws Exception
     */
    public static String getLastDateOfMonth(String yyyyMM) throws Exception {
        String year = yyyyMM.substring(0, 4);
        String month = yyyyMM.substring(4, 6);

        Calendar cal = Calendar.getInstance();
        cal.set(Integer.parseInt(year), Integer.parseInt(month) - 1, 1);

        String lastDay = year + month + Integer.toString(cal.getActualMaximum(Calendar.DAY_OF_MONTH));

        return lastDay;
    }

    /**
     * 두 날짜간의 차이 가져오기 (월)
     *
     * @param dateStr1
     * @param dateStr2
     * @return
     * @throws Exception
     */
    @SuppressWarnings("deprecation")
    public static int getMonthsDifference(String dateStr1, String dateStr2) throws Exception {
        SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");

        Date date1 = format.parse(dateStr1);
        Date date2 = format.parse(dateStr2);

        /* 해당년도에 12를 곱해서 총 개월수를 구하고 해당 월을 더 한다. */
        int month1 = date1.getYear() * 12 + date1.getMonth();
        int month2 = date2.getYear() * 12 + date2.getMonth();

        return month2 - month1;
    }
    
}