package com.bridgetec.common;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Comparator;
import java.util.Enumeration;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.TreeSet;
import java.util.Vector;

import egovframework.com.cmm.service.EgovProperties;

public class SortProperties extends Properties {
    
    /**
     * Called throughout by Properties, including Properties.store(OutputStream out, String comments).
     */
    @Override
    public synchronized Enumeration<Object> keys() {
        return new Vector(this.keySet()).elements();
    }

    /**
     * Called by Properties.stringPropertyNames() and this.keys().
     */
    @Override
    public Set<Object> keySet() {
        Set<Object> keySet = super.keySet();
        if (keySet == null)
            return keySet;
        return new TreeSet(keySet);
    }

    /**
     * Called by Properties.toString().
     */
    @Override
    public Set<Map.Entry<Object, Object>> entrySet() {
        Set<Map.Entry<Object, Object>> entrySet = super.entrySet();
        if (entrySet == null)
            return entrySet;

        Set<Map.Entry<Object, Object>> sortedSet = new TreeSet(new EntryComparator());
        sortedSet.addAll(entrySet);
        return sortedSet;
    }

    /**
     * Map 정렬 비교. 키를 기준으로 Null은 제외.
     */
    class EntryComparator implements Comparator<Map.Entry<Object, Object>> {

        @Override
        public int compare(Map.Entry<Object, Object> entry1,
                Map.Entry<Object, Object> entry2) {
            return entry1.getKey().toString().compareTo(entry2.getKey().toString());
        }

    }
    
    /**
     * properties에 값을 SET 하기위해 사용  security는 암호화해서 넣을지 말지를 결정
     * SWAT처럼 Property.java를 사용하지 않고  SortProperties를 사용하는 이유는 
     * properties를 SET한 후 내용이 뒤죽박죽 되지 않게 하기 위해서.
     */
    public Object setProperty(String key, String value, Boolean security) {
        if(security==null)  security = false;
        if(security)
            try {
                value = SecurityUtil.AESEncrypyt(value,null);
            } catch (Exception e) {
                //실패시 value를 그대로 사용.
            	System.out.println("Exception : " + e.toString());
            }
        return super.setProperty(key, value);
    }
    

    public static void setProperty(String key, String value, Boolean security, String filePath){
        
        if(filePath==null) filePath = EgovProperties.GLOBALS_PROPERTIES_FILE;
        SortProperties properties = new SortProperties();
        FileInputStream fis = null;
        FileOutputStream fos = null;
        
        try {
//            properties.load(new java.io.FileInputStream(filePath));
        	fis = new FileInputStream(filePath);
            properties.load(fis);

            properties.setProperty(key, value, security);
//            properties.store(new java.io.FileOutputStream(filePath), "");
            fos = new FileOutputStream(filePath);
            properties.store(fos, "");
            
            fos.close();
            fis.close();
        } catch (IOException ie) {
            System.out.println("IOException : " + ie.toString());
        } catch (Exception e) {
//            e.printStackTrace();
            System.out.println("Exception : " + e.toString());
        } finally {
        	if(fos != null) { try { fos.close(); } catch(IOException ie) { System.out.println("IOException : " + ie.toString()); } catch(Exception e) { System.out.println("Exception : " + e.toString()); } }
        	if(fis != null) { try { fis.close(); } catch(IOException ie) { System.out.println("IOException : " + ie.toString()); } catch(Exception e) { System.out.println("Exception : " + e.toString()); } }
        }
    }

}