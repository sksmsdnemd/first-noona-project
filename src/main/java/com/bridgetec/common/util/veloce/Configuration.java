package com.bridgetec.common.util.veloce;

import java.io.File;
import java.util.Properties;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Configuration extends GeneralConfiguration {

	private static long last_modified = 0L;
	private static String mws_file_name = null;
	private static String resource_dir = null;

	private static Logger logger = LoggerFactory.getLogger(Configuration.class);
	
	public Configuration() throws ConfigurationException {
		try {
			mws_file_name	= resource_dir + "mws.properties";
			//logger.debug("mws_file_name1="+mws_file_name);
			initialize();
			
		} catch (NullPointerException npe) {
			logger.error("NullPointerException=" + npe.getMessage());
		} catch (Exception exception) {
			logger.error("Exception=" + exception.getMessage());
		}
	}
	public Configuration(String fileNm) throws ConfigurationException {
		try {
			mws_file_name	= resource_dir + fileNm;
			//logger.debug("mws_file_name2="+mws_file_name);
			initialize();
		} catch (NullPointerException npe) {
			logger.error("NullPointerException=" + npe.getMessage());
		} catch (Exception exception) {
			logger.error("Exception=" + exception.getMessage());
		}
	}
	@Override
	protected void initialize() throws ConfigurationException {
		synchronized (GeneralConfiguration.lock) {
			try {
				File file = new File(mws_file_name);
				if (!file.canRead()){
					throw new ConfigurationException(getClass().getName()
							+ " - Can't open mws configuration file: "
							+ mws_file_name);
				}
				if (last_modified != file.lastModified() || _props == null) {
					_props = new Properties();
					loadConfigFile(file);
					last_modified = file.lastModified();
					GeneralConfiguration.lastModified = System.currentTimeMillis();
				}
				
			} catch (ConfigurationException configurationexception) {
				logger.error("ConfigurationException="+configurationexception);
				GeneralConfiguration.lastModified = 0L;
				last_modified = 0L;
				throw configurationexception;
			} catch (Exception exception) {
				logger.error("resource_dir="+resource_dir);
				logger.error("Exception="+exception);
				
				GeneralConfiguration.lastModified = 0L;
				last_modified = 0L;
				throw new ConfigurationException(getClass().getName()
						+ " - Can't load configuration file: "
						+ exception.getMessage());
			}
		}
	}
	
	
	public void saveConfigFile(String key, String value) throws ConfigurationException {
		synchronized (GeneralConfiguration.lock) {
			try {

				File file = new File(mws_file_name);
				if (!file.canRead()){
					throw new ConfigurationException(getClass().getName()
							+ " - Can't open mws configuration file: "
							+ mws_file_name);
				}


				saveConfigFile(file, key, value);


			} catch (ConfigurationException configurationexception) {
				logger.error("ConfigurationException="+configurationexception);
				GeneralConfiguration.lastModified = 0L;
				last_modified = 0L;
				throw configurationexception;
			} catch (Exception exception) {
				logger.error("resource_dir="+resource_dir);
				logger.error("Exception="+exception);

				GeneralConfiguration.lastModified = 0L;
				last_modified = 0L;
				throw new ConfigurationException(getClass().getName()
						+ " - Can't load configuration file: "
						+ exception.getMessage());
			}
		}
	}
	
	static {
		if( DefaultContext.RUNNING_MODE == DefaultContext.OLD_RUNNING_MODE ){
			resource_dir	= System.getProperty("MWS.property"); 
		}
		else{
			resource_dir	= DefaultContext.getInstance().getPropertisePath();
		}

		/*mws_file_name	= resource_dir + "mws.properties";
		
		logger.debug("mws_file_name="+mws_file_name);*/
	}

	public static String getMws_file_name() {
		return mws_file_name;
	}

	public static String getResource_dir() {
		return resource_dir;
	}
}
