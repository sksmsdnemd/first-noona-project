package com.bridgetec.common.util.veloce;

import java.util.Properties;

public interface Config {

	public abstract String get(String s);

	public abstract boolean getBoolean(String s);

	public abstract int getInt(String s);

	public abstract long getLong(String s);

	public abstract Properties getProperties();

	public abstract String getString(String s);

	public abstract long lastModified();

}
