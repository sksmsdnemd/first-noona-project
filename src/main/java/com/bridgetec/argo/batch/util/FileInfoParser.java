package com.bridgetec.argo.batch.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class FileInfoParser {
	/**
	 * 해당경로의 파일을 읽어들여 파싱하여 리스트셋 리턴 
	 * @param Map FILE / DELIMITER/ENCODE
	 * @return List
	 * @throws Exception
	 */	
	public static List<Map<String, String>>  getParsFileToListMap(Map<String, String> paramMap) throws Exception{
		
		FileInputStream fis   = null;
		InputStreamReader isr = null;
		BufferedReader br     = null;	
		
		List<Map<String, String>> dataMapLst = new ArrayList< Map<String, String> >();
		
		String sFile     =  paramMap.get("FILE") ;
		String sDelimiter=  paramMap.get("DELIMITER") ;
		String sEncode   =  paramMap.get("ENCODE") ;
		//int nRows        =  Integer.parseInt(paramMap.get("ROWS")) ;
		
		int nRows        =  0 ;		
		 try {
			 
			  int iCnt = 0;

			  Map<String, String> dataMap = null;
			  
			  File sourceFile = new File(sFile);

			  fis = new FileInputStream(sourceFile);
		  	  isr = new InputStreamReader(fis, (sEncode ==null ? "EUC-KR" : sEncode) );
			  br  = new BufferedReader(isr);

		      String line = "";		      
		      String[] sSplitSize = null;

		      if(sDelimiter.startsWith("W_")) { // 너비로 자를 경우 e.g ) W_8|20 ==> 8Byte 20 Byte
		         sDelimiter =  sDelimiter.replaceFirst("W_", "") ;
		    	 sSplitSize =  sDelimiter.split("[|]") ;		    	  
		      }
		      
		      while ((line = br.readLine()) != null) {
		     
			      if(  nRows > 0 && iCnt == nRows ) break; //row 제한일 경우 ( 0 보다 클 경우 ) 해당 건수만큼만 읽어서 처리한다.
			     
			      dataMap =  new HashMap<String, String>();	
			      
			      if(sSplitSize==null) {
			    	  String[] token = line.split((sDelimiter ==null ? "," : "["+sDelimiter+"]") , -1);  // -1 옵션은 마지막 "," 이후 빈 공백도 읽기 위한 옵션
			         for(int i=0 ; i < token.length ; i++ ) {		    		 
			    		  dataMap.put(String.valueOf(i), token[i].trim()) ;
			    	  }
			      }
			      else {
			    	  for(int i=0 ; i < sSplitSize.length ; i++ ) {	
			    		  Integer iByte =  Integer.parseInt(sSplitSize[i]) ;
			    		  String sValue= new String(line.getBytes(), (i==0? i:  Integer.parseInt(sSplitSize[i-1])), iByte);
			    		  dataMap.put(String.valueOf(i), sValue.trim()) ;
			    	  }			    	  
			      } 
			      
			    dataMapLst.add(dataMap) ; 
		       
		       iCnt++;
		      } // --while end
		      
		      br.close();
				 
		    } catch (FileNotFoundException e) {
		        e.printStackTrace();
		    } catch (IOException e) {
		        e.printStackTrace();
		    } finally {
				
		    }
		 return dataMapLst;
	}	
	

	/**
	 * properties의 설정을 이용하여 경로 혹은 파일명을 반환
	 * @param parmProp : DIR,DATE_FORMAT의 형식
	 *              ex) D:/data/%1$tY%1$tm%1$td/|yyyyMMdd -> D:/data/20140405/
	 *                   여기서 DATE_FORMAT은 workDate의 포멧을 의미한다.
	 *                   날짜형식에 의해 동적으로 추가되는 날짜부분 문자열값은 
	 *                   String.forma()의 형식 [%1$tY%1$tm%1$td]에 의해 제어된다. 
  
	 * @param workDate 일반적으로 yyyyMMdd의 형식
	 * @return
	 * @throws Exception 
	 */
	public static String getFormatedName(String parmProp, String workDate) throws Exception {
		if (parmProp == null) return null;		

		String[] params = parmProp.split("[|]");
		
		try {
			
			if (params.length > 1) {
				return String.format(params[0], DateUtil.stringToDate(workDate, params[1]));
			}

		} catch (ParseException e) {
			throw new Exception();
		}
		return params[0];
	}

	
	/**
	 * 해당경로의 파일을 읽어들여 파싱하여 리스트셋 리턴 - 미리보기를 위해 그리드 바인딩하기 위해
	 * @param sFile
	 * @param sDelimiter
	 * @param sEncode
	 * @return List
	 * @throws Exception
	 */		
	
	public static List<String> getParsFileToList(Map<String, String> paramMap) throws Exception{
		
		FileInputStream fis   = null;
		InputStreamReader isr = null;
		BufferedReader br     = null;	
		
		List<String> dataMapLst = new ArrayList<String >();
		
		String sFile     =  paramMap.get("FILE") ;
		String sEncode   =  paramMap.get("ENCODE") ;
		int nRows        =  Integer.parseInt(paramMap.get("ROWS")) ;
		
		 try {
			 
			  int iCnt = 0;
			  
  		      File sourceFile = new File(sFile);

			  fis = new FileInputStream(sourceFile);
		  	  isr = new InputStreamReader(fis, (sEncode ==null ? "EUC-KR" : sEncode) );
			  br  = new BufferedReader(isr);

		      String line = "";
	      
		      while ((line = br.readLine()) != null) {
		     
		      if(  nRows > 0 && iCnt == nRows ) break; //row 제한일 경우 ( 0 보다 클 경우 ) 해당 건수만큼만 읽어서 처리한다.
		     
		      dataMapLst.add(line)       ;
		       iCnt++;
		      } // --while end
		      br.close();
		     
				 
		    } catch (FileNotFoundException e) {
		        e.printStackTrace();
		    } catch (IOException e) {
		        e.printStackTrace();
		    } finally {
				
		    }
		 return dataMapLst;
	}

	/**
	 * 다운로드 디렉토리에 파일이 존재하는지 여부를 확인하여, 존재하지 않을 경우 
	 * 이후 처리를 스킵하기 위한 체크로직
	 * @param files
	 * @return 파일이 존재=true, 파일이 존재하지 않음(혹은 디렉토리만 존재)=false
	 */
	public static boolean chkFileExist(File[] files) {
		if (files == null) { 
			return false;
		}
		boolean chk = false;
		for (File file : files) {
			if (file.isFile()) {
				chk = true; // 파일이 하나라도 있으면 처리 속행
			}
		}
		return chk;
	}
}


