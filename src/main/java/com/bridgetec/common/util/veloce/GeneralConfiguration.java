package com.bridgetec.common.util.veloce;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.Properties;

public abstract class GeneralConfiguration implements Config {

	protected static Object lock = new Object();
	protected Properties _props;
	protected static long lastModified = 0L;

	public GeneralConfiguration() throws ConfigurationException {
		_props = null;
	}

	@Override
	public String get(String s) {
		return getString(s);
	}

	@Override
	public boolean getBoolean(String s) {
		boolean flag = false;
		try {
			flag = (new Boolean(_props.getProperty(s))).booleanValue();
		} catch (IllegalArgumentException exception) {
			throw new IllegalArgumentException("Illegal Boolean Key : " + s);
		} catch (Exception exception) {
			throw new IllegalArgumentException("Illegal Boolean Key : " + s);
		}
		return flag;
	}

	@Override
	public int getInt(String s) {
		int i = -1;
		try {
			i = Integer.parseInt(_props.getProperty(s));
		} catch (IllegalArgumentException exception) {
			throw new IllegalArgumentException("Illegal Integer Key : " + s);
		} catch (Exception exception) {
			throw new IllegalArgumentException("Illegal Integer Key : " + s);
		}
		return i;
	}

	@Override
	public long getLong(String s) {
		long l = -1L;
		try {
			l = Long.parseLong(_props.getProperty(s));
		} catch (IllegalArgumentException exception) {
			throw new IllegalArgumentException("Illegal Long Key : " + s);
		} catch (Exception exception) {
			throw new IllegalArgumentException("Illegal Long Key : " + s);
		}
		return l;
	}

	@Override
	public Properties getProperties() {
		return _props;
	}

	@Override
	public String getString(String s) {
		String s1 = null;
		try {
			String s2 = _props.getProperty(s);
			
			if (s2 == null) {
				throw new Exception();
			}
			s1 = CharConversion.E2K(s2);
		} catch (IllegalArgumentException exception) {
			throw new IllegalArgumentException("Illegal String Key : " + s);
		} catch (Exception exception) {
			throw new IllegalArgumentException("Illegal String Key : " + s);
		}
		return s1;
	}

	protected abstract void initialize() throws ConfigurationException;

	@Override
	public long lastModified() {
		return lastModified;
	}
	
	protected synchronized void loadConfigFile(File file) throws ConfigurationException {
		FileInputStream fileinputstream = null;
		
		try {
			fileinputstream = new FileInputStream(file);
			_props.load(new BufferedInputStream(fileinputstream));
			fileinputstream.close();
		} catch (IOException ie) {
			System.out.println("IOException : " + ie.toString());
		} catch (Exception exception) {
			_props = null;
			throw new ConfigurationException(getClass().getName()
					+ " - Can't read configuration file:" + file.getName()
					+ " " + exception);
		} finally {
			if(fileinputstream != null) {
				try {
					fileinputstream.close();
				} catch (IOException ie) {
					System.out.println("IOException : " + ie.toString());
				} catch (Exception e) {
					System.out.println("Exception : " + e.toString());
				}
			}
		}
	}

	protected synchronized void saveConfigFile(File file, String key, String value)
			throws ConfigurationException {
		PrintWriter out = null;
		BufferedReader in = null;
		
		try {
			boolean		 bKeyFind = false;
			StringBuffer contents = new StringBuffer();
			StringBuffer buff = new StringBuffer();
			in = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"));
			while(in.ready()){
				buff.setLength(0);
				buff.append(in.readLine());
				if( buff.indexOf("=") > -1 && buff.substring(0, buff.indexOf("=")).trim().equals(key) ){
					contents.append(buff.substring(0, buff.indexOf("=")).trim()).append("=").append(value.trim()).append("\r\n");
					bKeyFind = true;
				} else {
//					System.out.println(bKeyFind + "buff = " + buff);						
					if (bKeyFind == false && buff.indexOf("# [ DB ConnectionPool Use Mode ]") > -1)
						contents.append((key + "=" + value)).append("\r\n");
					contents.append(buff).append("\r\n");
				}
			}
			
			out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(file), "UTF-8"));
			//out = new PrintWriter(file);
			out.print(contents.toString());
//System.out.println("contents.toString()=" + contents.toString());			
			out.flush();
			out.close();
			
			in.close();
			
			//logger.info("환경설정변경="+contents.toString());
		} catch (FileNotFoundException fnfe) {
			System.out.println("Exception : " + fnfe.toString());
		} catch (UnsupportedEncodingException uee) {
			System.out.println("Exception : " + uee.toString());
		} catch (Exception exception) {
//			exception.printStackTrace();
			System.out.println("Exception : " + exception.toString());
			_props = null;
			throw new ConfigurationException(getClass().getName()
					+ " - Can't read configuration file:" + file.getName()
					+ " " + exception);
		} finally {
			if( out != null ){
				out.flush();
				out.close();
			}
			if( in != null ){
				try {
					in.close();
				} catch(IOException ie) { 
					System.out.println("IOException : " + ie.toString());
				} catch(Exception e) { 
					System.out.println("Exception : " + e.toString());
				}
			}
		}
	}
}