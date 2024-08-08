package com.bridgetec.common.util.veloce;

import java.io.File;


public class DefaultContext {

    private static DefaultContext instance;
    
    /**
     * OLD_RUNNING_MODE : JVM Option 으로 Properties Directory path 를 지정
     * NEW_RUNNING_MODE : Context home 부터 상대 경로로  Properties Directory path 를 지정
     * 
     * 2011-03-07 이후 NEW_RUNNING_MODE 를 사용하도록 한다.
     */
    public static int NEW_RUNNING_MODE = 1;
    public static int OLD_RUNNING_MODE = 2;
    public static int RUNNING_MODE = NEW_RUNNING_MODE; 

    static void createInstance(String path) {
        instance = new DefaultContext(path);
    }

    public static DefaultContext getInstance() {
        if (instance == null) {
            throw new NullPointerException("not yet");
        } else
            return instance;
    }

    final String baseDir;
    final String propertisePath;

    private DefaultContext(String path) {
        baseDir = path;
        propertisePath = baseDir+File.separator+"properties"+File.separator;
    }

    public String getPath() {
        return baseDir;
    }

	public String getPropertisePath() {
		return propertisePath;
	}

}



