package com.bridgetec.argo.batch.work;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.OutputStreamWriter;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;

//import org.apache.commons.compress.compressors.FileNameUtil;
//import org.apache.log4j.Logger;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
//import org.apache.tools.ant.types.resources.selectors.Date;

import com.bridgetec.argo.batch.common.AbstractDbLogic;
import com.bridgetec.argo.batch.util.DBManager;
import com.bridgetec.argo.batch.util.DateUtil;
import com.bridgetec.argo.batch.util.FileInfoParser;
import com.bridgetec.argo.batch.util.FileManager;
import com.bridgetec.argo.batch.util.PropManager;
import com.bridgetec.argo.batch.util.RegExpUtil;
import com.bridgetec.argo.batch.util.SecurityUtil;
import com.bridgetec.argo.batch.util.StringUtil;
import com.bridgetec.common.util.security.AESUtil;
import com.bridgetec.common.util.security.CSNcryptUtil;

import egovframework.com.utl.fcc.service.EgovStringUtil;
import egovframework.rte.psl.dataaccess.util.CamelUtil;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

public class WorkLogic extends AbstractDbLogic {
	private static final Logger logger = LogManager.getLogger(WorkLogic.class);
	private static final WorkLogic dbLogic = new WorkLogic();

	public static WorkLogic getInstance() {
		return dbLogic;
	}

	/**
	 * doWorkIn 수신 처리
	 * 
	 * @param HashMap
	 *            rowWorkInfo ( 작업정보 맵)
	 * @return Map 처리결과맵
	 * @throws Exception
	 */
	protected Map<String, String> doWorkIn(HashMap<String, String> rowWorkInfo) throws Exception {
		//logger.info("ARGO BATCH doWorkIn(수신) start>>");

		// 리턴 map
		Map<String, String> mapProcResult = new HashMap<String, String>();
		mapProcResult.put("RESULT_CD", "S");
		mapProcResult.put("RESULT_CNT", "0");
		mapProcResult.put("RESULT_MSG", "");
		int procTotalCnt = 0;

		Connection connArgo = null; // ARGO CONNECTION
		PreparedStatement pstmtExec = null;
		PreparedStatement prePstmtExec = null;
		PreparedStatement nextPstmtExec = null;

		Connection connS = null;
		PreparedStatement pstmtSel = null;
		ResultSet rsSel = null;

		int batchCnt = 1000; // 배치 처리 건수
		int commitCnt = 0;


		try {
			/*
			 * ===============================================================
			 * 0. 실행쿼리 파싱
			 * ===============================================================
			 */
			// String strQuery =
			// "INSERT INTO TB_CM_CODE( CL_CD , CD , SET_GB , CL_CD_NM , CD_NM , CD_ABBR )  VALUES ( [CL_CD] , [CD] , [SET_GB] , [CL_CD_NM] , [CD_NM] , [CD_ABBR])"
			// ;
			// String strQuery =
			// "INSERT INTO TMP_BATCH (COL_1, COL_2, COL_3) VALUES ([0], [1],TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS'))"
			// ;
			
			String preStrQuery = StringUtil.nullToSpace(rowWorkInfo.get("PRE_EXE_QUERY"));
			String nextStrQuery = StringUtil.nullToSpace(rowWorkInfo.get("NEXT_EXE_QUERY"));
			
			String strQuery = StringUtil.nullToSpace(rowWorkInfo.get("EXE_QUERY"));
			String strExeQuery = strQuery; // 실행하기 위한 가공 쿼리
			List<String> strColList = new ArrayList<String>(); // 쿼리로 부터 컬러목록
																// 꺼내어 저장

			String strPattern = "\\[\\w+]+"; // [0] 또는 [컬럼명] 패턴
			Matcher objMatcher = RegExpUtil.matchString(strQuery, strPattern);

			while (objMatcher.find()) {
				strExeQuery = strExeQuery.replace(objMatcher.group(), "?"); // 정규표현[컬럼명
																			// 또는
																			// 인덱스]
																			// 를
																			// ?
																			// 로
																			// 치환
				strColList.add(objMatcher.group().replace("[", "").replace("]", "")); // 컬럼명 또는 인덱스를 꺼내서 저장
			}

			////logger.info("strExeQuery>>" + strExeQuery);
			connArgo = DBManager.getArgoDbConn();
			connArgo.createStatement();
			pstmtExec = connArgo.prepareStatement(strExeQuery);
			
			connArgo.setAutoCommit(false);
			
			//선행 SQL작업이 있는경우
			if(!"".equals(preStrQuery)){
				prePstmtExec = connArgo.prepareStatement(preStrQuery);
				prePstmtExec.execute();
				connArgo.commit();
				//logger.info("PRE_EXE_QUERY >>" + preStrQuery);
			}
			
			/*
			 * ===============================================================
			 * 1. 소스데이터 조회 : FILE 인 경우
			 * ===============================================================
			 */
			if ("FILE".equals(rowWorkInfo.get("SOURCE_TYP"))) {

				String filePath = StringUtil.nullToSpace(rowWorkInfo.get("FILE_PATH"));
				String fileName = StringUtil.nullToSpace(rowWorkInfo.get("FILE_NM"));

				// 파일일 경우 파일경로 및 파일명의 날짜 포맷 처리 전 FILE_DAYS 로 날짜 계산
				int iDays = Integer.parseInt(rowWorkInfo.get("FILE_DAYS"));
				String sWorkDate = rowWorkInfo.get("WORK_DT");

				if (iDays != 0)
					sWorkDate = DateUtil.addDay(sWorkDate, iDays);
				//logger.info("파일처리일자>>" + sWorkDate);

				// 파일명 패턴에 따라 처리
				filePath = FileInfoParser.getFormatedName(filePath, sWorkDate);// 실행일자로
																				// 파일경로
																				// 처리
																				// "D:/Working/ARGO/배치/TEST/%1$tY%1$tm%1$td/|yyyyMMdd","20170607"
				fileName = FileInfoParser.getFormatedName(fileName, sWorkDate);// 실행일자로
																				// 파일명
																				// 처리

				// String filePath =
				// FileInfoParser.getFormatedName("D:/Working/ARGO/배치/TEST/%1$tY%1$tm%1$td/|yyyyMMdd","20170607")
				// ;
				// String fileName = "" ;
				// String filePath = "D:/Working/ARGO/배치/TEST/" ;
				// String fileName =
				// FileInfoParser.getFormatedName("GrantList_%1$tY%1$tm%1$td.prn|yyyyMMdd","20170607")
				// ;
				// rowWorkInfo.put("FILE_BACKUP_DIR", filePath+"backup/") ; //
				// 파일 처리 후 이동할 백업 위치 ( 해당 파일경로 아래 BACKUP 생성)

				// 파일 백업 및 작업위치 경로 : 대상 파일을 작업대상 위치에 이동 후 처리 한다.
				String fileBackupPath = filePath + "backup/";
				String fileExceptionPath = filePath + "exception/";

				List<Map<String, String>> fileList = new ArrayList<Map<String, String>>();
				List<Map<String, String>> dataMapLst;
				Map<String, String> fileMap = null;
				/*
				 * ==============================================================
				 * = 1.1 대상파일 목록 생성
				 * ==============================================================
				 */
				// 파일명이 존재하는 경우
				if (fileName.length() > 0) {

					fileMap = new HashMap<String, String>();
					File file = new File(filePath + fileName);
					if (file.exists()) {

//						if (!FileManager.moveFile(file.getPath(), fileWorkPath + file.getName())) {
//							logger.warn("작업파일 이동처리에 실패하였습니다. FILENAME = " + file.getName());
//						}

						fileMap.put("FILE", file.getPath());
						fileMap.put("FILE_NM", fileName);
						fileList.add(fileMap);
					}else{
						File[] files = new File(filePath).listFiles();
						
						Arrays.sort(files);
						for (File f : files) {
							if (!f.isFile())
								continue; // 파일이 아닐경우 SKIP
							
							String[] nameSplit = null;
							if(fileName.indexOf("*") >= 0){
								nameSplit = fileName.split("\\*");
								
								if(nameSplit[0].equals("") && f.getName().endsWith(nameSplit[1]) || //파일명 pre-fix가 없으면 확장자만 체크
										(!nameSplit[0].equals("") && f.getName().startsWith(nameSplit[0]) && f.getName().endsWith(nameSplit[1]))){ //파일명 pre-fix가 있으면 앞,뒤로 체크
//									if (!FileManager.moveFile(f.getPath(), fileWorkPath + f.getName())) {
//										logger.warn("작업파일 이동처리에 실패하였습니다. FILENAME = " + f.getName());
//									}

									fileMap = new HashMap<String, String>();
									fileMap.put("FILE", f.getPath());
									fileMap.put("FILE_NM", f.getName());

									fileList.add(fileMap);
									
								}
							}							
						}
					}
				} else {// 파일경로만 있을 경우
					File[] files = new File(filePath).listFiles();

					if (!FileInfoParser.chkFileExist(files)) {
						//logger.info(" 파일이 존재하지 않습니다. path= " + filePath);
					} else {
						Arrays.sort(files); // 파일 이름순으로 정렬
						// Arrays.sort(files,LastModifiedFileComparator.LASTMODIFIED_COMPARATOR)
						// ; // 최종 수정일시로 정렬

						// 파일 수 만큼 파일명
						for (File file : files) {
							if (!file.isFile())
								continue; // 파일이 아닐경우 SKIP

//							if (!FileManager.moveFile(file.getPath(), fileWorkPath + file.getName())) {
//								logger.warn("작업파일 이동처리에 실패하였습니다. FILENAME = " + file.getName());
//							}

							fileMap = new HashMap<String, String>();
							fileMap.put("FILE", file.getPath());
							fileMap.put("FILE_NM", file.getName());

							fileList.add(fileMap);
						}
					}
				}
				/*
				 * ==============================================================
				 * = 1.2 대상파일목록 LOOP - 파일별 데이터생성
				 * ==================================
				 * =============================
				 */
				if (fileList.size() == 0) {
					logger.warn("해당 경로에 대상파일이 존재하지 않습니다." + filePath + fileName);
					mapProcResult.put("RESULT_CD", "F");
					mapProcResult.put("RESULT_MSG", "해당 경로에 대상파일이 존재하지 않습니다." + filePath + fileName);
				} else {
					Map<String, String> paramMap = new HashMap<String, String>();
					// paramMap.put("DELIMITER" , ",") ; //e.g , \t 또는 너비 일때
					// "W_8|26"
					paramMap.put("DELIMITER", StringUtil.nullToSpace(rowWorkInfo.get("FILE_DELIMITER"))); // e.g
																				// ,
																				// \t
																				// 또는
																				// 너비
																				// 일때
																				// "W_8|26"
					paramMap.put("ENCODE", StringUtil.nullToSpace(rowWorkInfo.get("FILE_ENCODE"))); // e.g EUC-KR

					for (Map<String, String> mapFile : fileList) {

						paramMap.put("FILE", mapFile.get("FILE"));
						dataMapLst = FileInfoParser.getParsFileToListMap(paramMap);
						commitCnt = 0;
						try{
							for (int j = 0; j < dataMapLst.size(); j++) {
								for (int k = 0; k < strColList.size(); k++) {
									pstmtExec.setString(k + 1, dataMapLst.get(j).get(strColList.get(k)));
								}

								pstmtExec.addBatch();
								commitCnt++;

								procTotalCnt++; // 전체처리건수
								if (commitCnt % batchCnt == 0) {
									pstmtExec.executeBatch();
									connArgo.commit();
									pstmtExec.clearBatch();
								}
								pstmtExec.clearParameters();
							}
							
							logger.info("FILE PROC SUCCESS >>" + mapFile.get("FILE") + "[처리건수:" + dataMapLst.size() + "]");
							FileManager.moveFile(mapFile.get("FILE"), fileBackupPath + mapFile.get("FILE_NM")); //file 백업경로로 이동
							if(new File(mapFile.get("FILE").replaceAll(".dat", ".chk")).exists()){
								FileManager.moveFile(mapFile.get("FILE").replaceAll(".dat", ".chk"), fileBackupPath + mapFile.get("FILE_NM").replaceAll(".dat", ".chk"));
							}
							
						}catch(Exception e){
							e.printStackTrace();
							mapProcResult.put("RESULT_CD", "F");
							mapProcResult.put("RESULT_MSG", e.getMessage());
							FileManager.moveFile(mapFile.get("FILE"), fileExceptionPath + mapFile.get("FILE_NM"));
							if(new File(mapFile.get("FILE").replaceAll(".dat", ".chk")).exists()){
								FileManager.moveFile(mapFile.get("FILE").replaceAll(".dat", ".chk"), fileExceptionPath + mapFile.get("FILE_NM").replaceAll(".dat", ".chk"));
							}
						}
						
						// 파일 처리가 완료 되면 해당 파일 백업 위치로 이동시킨다. 선 이동 후 처리함.
						/*
						 * if (!FileManager.moveFile( mapFile.get("FILE"),
						 * rowWorkInfo.get("FILE_BACKUP_DIR") +
						 * mapFile.get("FILE_NM"))) {
						 * logger.warn("처리가 종료된 파일의 백업에 실패하였습니다. FILENAME = " +
						 * mapFile.get("FILE")); }
						 */
					}
				}

			} else if ("DB".equals(rowWorkInfo.get("SOURCE_TYP"))) {
				/*
				 * ==============================================================
				 * = 2. 소스데이터 조회 : DB 인 경우
				 * ========================================
				 * =======================
				 */
				connS = DBManager.getConn(rowWorkInfo.get("JDBC_DRIVER"),
						rowWorkInfo.get("JDBC_URL"),
						rowWorkInfo.get("USER_ID"), rowWorkInfo.get("USER_PW"));

				pstmtSel = connS.prepareCall(rowWorkInfo.get("SEL_QUERY")); // 추출쿼리
				rsSel = pstmtSel.executeQuery();
				
				commitCnt = 0;
				String value ="";
				while (rsSel.next()) {

					for (int k = 0; k < strColList.size(); k++) {
						
						if(strColList.get(k).split("_")[0].equals("ENC")){
							if(!"".equals(StringUtil.nullToSpace(rsSel.getString(strColList.get(k))))){
								value = AESUtil.encrypt(rsSel.getString(strColList.get(k)));
							}else{
								value = rsSel.getString(strColList.get(k));	
							}
						}else{
							value = rsSel.getString(strColList.get(k));
						}
						pstmtExec.setString(k + 1, value);
					}

					pstmtExec.addBatch();
					commitCnt++;

					procTotalCnt++; // 전체처리건수
					if (commitCnt % batchCnt == 0) {
						pstmtExec.executeBatch();
						connArgo.commit();
						pstmtExec.clearBatch();
					}
					pstmtExec.clearParameters();
				}

				//logger.info("DB >>" + "[처리건수:" + procTotalCnt + "]");
			}
			/*
			 * ===============================================================
			 * 3. 최종 커밋
			 * ===============================================================
			 */
			pstmtExec.executeBatch();
			connArgo.commit();

			pstmtExec.clearParameters();
			pstmtExec.clearBatch();
			
			//후행 SQL작업이 있는경우
			if(!"".equals(nextStrQuery)){
				nextPstmtExec = connArgo.prepareStatement(nextStrQuery);
				nextPstmtExec.execute();
				connArgo.commit();
				//logger.info("NEXT_EXE_QUERY >>" + nextStrQuery);
			}

		} catch (ClassNotFoundException e) {
			e.printStackTrace();
			mapProcResult.put("RESULT_CD", "F");
			mapProcResult.put("RESULT_MSG", e.getMessage());
			errorHandle(e, connArgo);
		} catch (Exception e) {
			e.printStackTrace();
			mapProcResult.put("RESULT_CD", "F");
			mapProcResult.put("RESULT_MSG", e.getMessage());
		} finally {
			close(prePstmtExec, connArgo);
			close(pstmtExec, connArgo);
			close(nextPstmtExec, connArgo);
			close(pstmtSel, connS, rsSel);
		}

		//logger.info("ARGO BATCH doWorkIn(수신) END>>" + sWorkId + " RESULT>>" + mapProcResult.get("RESULT_CD"));

		return mapProcResult;
	}

	/**
	 * doWorkIn 송신처리
	 * 
	 * @param HashMap
	 *            rowWorkInfo ( 작업정보 맵)
	 * @return Map 처리결과맵
	 * @throws Exception
	 */
	protected Map<String, String> doWorkOut(HashMap<String, String> rowWorkInfo) throws Exception {
		//logger.info("ARGO BATCH doWorkOut(송신) start>>");

		// 리턴 map
		Map<String, String> mapProcResult = new HashMap<String, String>();
		mapProcResult.put("RESULT_CD", "S");
		mapProcResult.put("RESULT_CNT", "0");
		mapProcResult.put("RESULT_MSG", "");
		int procTotalCnt = 0;

		Connection connArgo = null; // ARGO CONNECTION
		PreparedStatement pstmtSel = null;
		ResultSet rsSel = null;

		//FileOutputStream fos = null;
		//FileOutputStream fosChk = null;
		BufferedWriter bw = null;
		BufferedWriter bwChk = null;

		try {
			/*
			 * ===============================================================
			 * 0. 대상 데이터 조회
			 * ===============================================================
			 */
			String strQuery = StringUtil.nullToSpace(rowWorkInfo.get("SEL_QUERY"));

			connArgo = DBManager.getArgoDbConn();
			pstmtSel = connArgo.prepareStatement(strQuery);
			rsSel = pstmtSel.executeQuery();

			/*
			 * ===============================================================
			 * 1. 타겟 파일 생성
			 * ===============================================================
			 */

			String filePath = StringUtil.nullToSpace(rowWorkInfo.get("FILE_PATH"));
			String fileName = StringUtil
					.nullToSpace(rowWorkInfo.get("FILE_NM"));

			// 파일일 경우 파일경로 및 파일명의 날짜 포맷 처리 전 FILE_DAYS 로 날짜 계산
			int iDays = Integer.parseInt(rowWorkInfo.get("FILE_DAYS"));
			String sWorkDate = rowWorkInfo.get("WORK_DT");
			
			if (iDays != 0)
				sWorkDate = DateUtil.addDay(sWorkDate, iDays);
			//logger.info("파일처리일자>>" + sWorkDate);

			// 파일명 패턴에 따라 처리
			filePath = FileInfoParser.getFormatedName(filePath, sWorkDate); // 실행일자로
																			// 파일경로
																			// 처리
																			// "D:/Working/ARGO/배치/TEST/%1$tY%1$tm%1$td/|yyyyMMdd","20170607"
			fileName = FileInfoParser.getFormatedName(fileName, sWorkDate); // 실행일자로
																			// 파일명
																			// 처리

			File desFile = new File(filePath + fileName);
			File desDir = desFile.getParentFile();
			if (!desDir.exists()) {
				desDir.mkdirs();
			}

			String sEncode = StringUtil.nullToSpace(rowWorkInfo.get("FILE_ENCODE"));
			bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(new File(filePath + fileName)), (sEncode ==null ? "EUC-KR" : sEncode)));
			//fos = new FileOutputStream(new File(filePath + fileName));

			ResultSetMetaData rsmd = rsSel.getMetaData();

			// String sDelimiter = "W_8|26|10";
			String sDelimiter = rowWorkInfo.get("FILE_DELIMITER");

			String[] sSplitSize = null;
			String sTemp = "";

			if (sDelimiter.startsWith("W_")) { // 너비로 자를 경우 e.g ) W_8|20 ==>
												// 8Byte 20 Byte
				sDelimiter = sDelimiter.replaceFirst("W_", "");
				sSplitSize = sDelimiter.split("[|]");
			}
			/*
			 * ===============================================================
			 * 2. 데이터 loop to FILE Write
			 * ===============================================================
			 */
			while (rsSel.next()) {
				StringBuilder sb = new StringBuilder("");
				
				for (int i = 0; i < rsmd.getColumnCount(); i++) {
					sTemp =  StringUtil.nullToSpace(rsSel.getString(i + 1));
					
					if(rsmd.getColumnName(i+1).split("_")[0].equals("DEC")){
						sTemp = (CSNcryptUtil.decrypt("", sTemp)==null)? StringUtil.nullToSpace(rsSel.getString(i + 1)) : StringUtil.nullToSpace(CSNcryptUtil.decrypt("", sTemp));
					}else if(rsmd.getColumnName(i+1).split("_")[0].equals("ENC")){
						sTemp = (CSNcryptUtil.encrypt("", sTemp)==null)? StringUtil.nullToSpace(rsSel.getString(i + 1)) : StringUtil.nullToSpace(CSNcryptUtil.encrypt("", sTemp));
					}
					
					if (sSplitSize == null) {
						sTemp = sTemp + sDelimiter; // 구분자이면 구분자로 처리
					} else { // 너비로 자를경우
						if (sTemp.getBytes().length > Integer.parseInt(sSplitSize[i])) { // 데이터가 지정한 너비보다 크면 자른다.
							sTemp = new String(sTemp.getBytes(), 0, Integer.parseInt(sSplitSize[i]));
						} else {
							sTemp = StringUtil.rPadSpace(sTemp, Integer.parseInt(sSplitSize[i])); // 지정한 너비만큼 공백 채운다.

						}
					}
					sb.append(sTemp);
				}

				sb.append("\n");
				bw.write(sb.toString());
				procTotalCnt++; // 전체처리건수
			}
			
			if(bw != null) bw.flush();

			mapProcResult.put("RESULT_CNT", String.valueOf(procTotalCnt));
			//logger.info("FILE >>" + filePath + fileName + "[처리건수:" + String.valueOf(procTotalCnt) + "]");
			
			String sUseChk = rowWorkInfo.get("USE_CHK");
			
			// NH만 쓰는 부분, 추후 체크썸 용도 등으로 활용가능할듯
			if(sUseChk.equals("1")){ //chk파일 생성 
				StringBuilder sb = new StringBuilder("");
				
				String chkMsg = "";
				chkMsg += filePath + fileName + "|";
				chkMsg += new File(filePath + fileName).length() + "|";
				chkMsg += new SimpleDateFormat("HHmmss").format(Calendar.getInstance().getTime()) + "|";
				chkMsg += procTotalCnt + "|";
				
				sb.append(chkMsg);
				sb.append("\n");
				
				String chkFileName = fileName.substring(0, fileName.lastIndexOf(".")) + ".chk";
				
				bwChk = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(new File(filePath + chkFileName)), (sEncode ==null ? "EUC-KR" : sEncode)));
				bwChk.write(sb.toString());
			}
			

		} catch (ClassNotFoundException e) {
			e.printStackTrace();
			mapProcResult.put("RESULT_CD", "F");
			mapProcResult.put("RESULT_MSG", e.getMessage());
			errorHandle(e, connArgo);
		} catch (Exception e) {
			e.printStackTrace();
			mapProcResult.put("RESULT_CD", "F");
			mapProcResult.put("RESULT_MSG", e.getMessage());
			logger.error(e.getMessage());
		} finally {
			if(bw != null) bw.close();
			if(bwChk != null) bwChk.close();
			close(pstmtSel, connArgo, rsSel);
		}

		//logger.info("ARGO BATCH doWorkOut(송신) END>>" + sWorkId + " RESULT>>" + mapProcResult.get("RESULT_CD"));

		return mapProcResult;
	}

	/**
	 * doWorkExeProcedure 쿼리실행
	 * 
	 * @param HashMap
	 *            rowWorkInfo ( 작업정보 맵)
	 * @return Map 처리결과맵
	 * @throws Exception
	 */
	protected Map<String, String> doWorkExeProcedure(HashMap<String, String> rowWorkInfo) throws Exception {
		//logger.info("ARGO BATCH doWorkExeProcedure start>>");

		// 리턴 map
		Map<String, String> mapProcResult = new HashMap<String, String>();
		mapProcResult.put("RESULT_CD", "S");
		mapProcResult.put("RESULT_CNT", "0");
		mapProcResult.put("RESULT_MSG", "");

		Connection connArgo = null; // ARGO CONNECTION
		PreparedStatement pstmtSel = null;
		ResultSet rsSel = null;


		try {
			/*
			 * ===============================================================
			 * 0. 실행쿼리 실행
			 * ===============================================================
			 */
			String strQuery = StringUtil.nullToSpace(rowWorkInfo.get("EXE_QUERY"));

			connArgo = DBManager.getArgoDbConn();
			pstmtSel = connArgo.prepareStatement(strQuery);
			pstmtSel.execute();

			//logger.info("#############################################################");
			//logger.info("다음 실행문이 성공적으로 호출 되었습니다.");
			//logger.info(strQuery);
			//logger.info("#############################################################");

		} catch (ClassNotFoundException e) {
			e.printStackTrace();
			mapProcResult.put("RESULT_CD", "F");
			mapProcResult.put("RESULT_MSG", e.getMessage());
			errorHandle(e, connArgo);
		} catch (Exception e) {
			e.printStackTrace();
			mapProcResult.put("RESULT_CD", "F");
			mapProcResult.put("RESULT_MSG", e.getMessage());
		} finally {
			close(pstmtSel, connArgo, rsSel);
		}

		//logger.info("ARGO BATCH doWorkExeProcedure END>>" + sWorkId + " RESULT>>" + mapProcResult.get("RESULT_CD"));

		return mapProcResult;
	}

	/**
	 * doWorkExeCommand 명령실행
	 * 
	 * @param HashMap
	 *            rowWorkInfo ( 작업정보 맵)
	 * @return Map 처리결과맵
	 * @throws Exception
	 */
	protected Map<String, String> doWorkExeCommand(HashMap<String, String> rowWorkInfo) throws Exception {
		//logger.info("ARGO BATCH doWorkExeCommand start>>");

		// 리턴 map
		Map<String, String> mapProcResult = new HashMap<String, String>();
		mapProcResult.put("RESULT_CD", "S");
		mapProcResult.put("RESULT_CNT", "0");
		mapProcResult.put("RESULT_MSG", "");

		Connection connArgo = null; // ARGO CONNECTION
		PreparedStatement pstmtSel = null;
		ResultSet rsSel = null;

		try {
			/*
			 * ===============================================================
			 * 0. 명령실행
			 * ===============================================================
			 */
			String strQuery = StringUtil.nullToSpace(rowWorkInfo.get("EXE_QUERY"));
			// Process p = Runtime.getRuntime().exec(strQuery);
			Runtime.getRuntime().exec(strQuery);
			//logger.info("#############################################################");
			//logger.info("다음 실행문이 성공적으로 호출 되었습니다.");
			//logger.info(strQuery);
			//logger.info("#############################################################");

		} catch (Exception e) {
			e.printStackTrace();
			mapProcResult.put("RESULT_CD", "F");
			mapProcResult.put("RESULT_MSG", e.getMessage());
		} finally {
			close(pstmtSel, connArgo, rsSel);
		}

		//logger.info("ARGO BATCH doWorkExeCommand END>>" + sWorkId + " RESULT>>" + mapProcResult.get("RESULT_CD"));

		return mapProcResult;
	}

	/**
	 * 작업정보 조회
	 * @param String pTenantId
	 * @param String pWorkId
	 * @return ArrayList
	 * @throws Exception
	 */
	protected ArrayList<HashMap<String, String>> getWorkInfo(String pTenantId, String pWorkId) throws Exception {
		Connection connArgo = null; // ARGO CONNECTION
		PreparedStatement pstmt = null;
		ResultSet rsInfo = null;
		ArrayList<HashMap<String, String>> list = new ArrayList<HashMap<String, String>>();

		try {
			connArgo = DBManager.getArgoDbConn();
			/*
			 * ===============================================================
			 * 0. 작업정보 조회
			 * ===============================================================
			 */
			pstmt = connArgo.prepareStatement(PropManager.getDBStrValue("SQL_SELECT_WORK_INFO"));
			pstmt.setString(1, pTenantId);
			pstmt.setString(2, pWorkId);
			rsInfo = pstmt.executeQuery();

			list = resultSetToArrayList(rsInfo);

		} catch (ClassNotFoundException e) {
			errorHandle(e, connArgo);
		} finally {
			close(pstmt, connArgo);
		}

		return list;
	}

	/**
	 * resultSet to ArrayList
	 */
	public ArrayList<HashMap<String, String>> resultSetToArrayList(ResultSet rs) throws Exception {
		ResultSetMetaData md = rs.getMetaData();
		int columns = md.getColumnCount();
		ArrayList<HashMap<String, String>> list = new ArrayList<HashMap<String, String>>();

		while (rs.next()) {
			HashMap<String, String> row = new HashMap<String, String>(columns);
			for (int i = 1; i <= columns; ++i) {
				row.put(md.getColumnName(i), rs.getString(i));
			}
			list.add(row);
		}

		return list;
	}
	
	/**
	 * exeQuery 쿼리실행
	 * 
	 * @param String strQuery
	 * @return Map 처리결과맵
	 * @throws Exception
	 */
	public Map<String, String> exeQuery(String strQuery) throws Exception {
		EgovStringUtil esu = new EgovStringUtil();
		
		strQuery = esu.getHtmlStrCnvr(strQuery);
		String[] strQueryArr = strQuery.split("\\;");
		int debugLength = strQueryArr.length;
		
		
		// 리턴 map
		Map<String, String> mapProcResult = new HashMap<String, String>();
		mapProcResult.put("RESULT_CD", "S");
		mapProcResult.put("RESULT_CNT", "0");
		mapProcResult.put("RESULT_MSG", "");

		Connection connArgo = null; // ARGO CONNECTION
		PreparedStatement pstmtSel = null;
		Statement stat = null;

		try {
			/*
			 * ===============================================================
			 * 0. 실행쿼리 실행
			 * 
			 * ";"을 구분자로 하여 다중 INSERT기능 추가
			 * 일부만 ISNERT불가 (트랜잭션 처리)
			 * ===============================================================
			 */
			connArgo = DBManager.getArgoDbConn();
			stat = connArgo.createStatement();
			
			
//			String strQueryArry[]  = strQuery.split(";");
			
			connArgo.setAutoCommit(false);
			stat.addBatch(strQuery);
			
//			for(int i =0 ; i<strQueryArry.length; i++){
//				stat.addBatch(strQueryArry[i]);
//			}
			
			stat.executeBatch();
			connArgo.commit();
			stat.clearBatch();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
			mapProcResult.put("RESULT_CD", "F");
			mapProcResult.put("RESULT_MSG", e.getMessage());
			errorHandle(e, connArgo);
		}catch (Exception e) {
			e.printStackTrace();
			connArgo.rollback();
			mapProcResult.put("RESULT_CD", "F");
			mapProcResult.put("RESULT_MSG", e.getMessage());
		} finally {
			close(pstmtSel, connArgo);
			stat.close();
		}

		return mapProcResult;
	}
	
	
	
	
	
	
	
	
	
	/**
	 * exeQuery 쿼리실행
	 * 
	 * @param String strQuery
	 * @return Map 처리결과맵
	 * @throws Exception
	 */
	public Map<String, String> exeQueryInsertUpdate(String strQuery) throws Exception {
		EgovStringUtil esu = new EgovStringUtil();
		
		strQuery = esu.getHtmlStrCnvr(strQuery);
		
		
		String[] strQueryArr = strQuery.split("\\;");
		int debugLength = strQueryArr.length;
		
		
		// 리턴 map
		Map<String, String> mapProcResult = new HashMap<String, String>();
		mapProcResult.put("RESULT_CD", "S");
		mapProcResult.put("RESULT_CNT", "0");
		mapProcResult.put("RESULT_MSG", "");

		Connection connArgo = null; // ARGO CONNECTION
		PreparedStatement pstmtSel = null;
		Statement stat = null;

		try {
			/*
			 * ===============================================================
			 * 0. 실행쿼리 실행
			 * 
			 * ";"을 구분자로 하여 다중 INSERT기능 추가
			 * 일부만 ISNERT불가 (트랜잭션 처리)
			 * ===============================================================
			 */
			connArgo = DBManager.getArgoDbConn();
			stat = connArgo.createStatement();
			String strQueryArry[]  = strQuery.split(";");
			
			connArgo.setAutoCommit(false);
			for(int i =0 ; i<strQueryArry.length; i++){
				stat.addBatch(strQueryArry[i]);
			}
			
			stat.executeBatch();
			connArgo.commit();
			stat.clearBatch();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
			mapProcResult.put("RESULT_CD", "F");
			mapProcResult.put("RESULT_MSG", e.getMessage());
			errorHandle(e, connArgo);
		}catch (Exception e) {
			e.printStackTrace();
			connArgo.rollback();
			mapProcResult.put("RESULT_CD", "F");
			mapProcResult.put("RESULT_MSG", e.getMessage());
		} finally {
			close(pstmtSel, connArgo);
			stat.close();
		}

		return mapProcResult;
	}
	
	
	
	/**
	 * exeQuery 쿼리실행
	 * 
	 * @param String strQuery
	 * @return Map 처리결과맵
	 * @throws Exception
	 */
	public JSONArray exeSelect(String strQuery) throws Exception {
		EgovStringUtil esu = new EgovStringUtil();
		strQuery = esu.getHtmlStrCnvr(strQuery);
//		strQuery = strQuery.replaceAll("&quot;", "\"");
//		strQuery = strQuery.replaceAll("&apos;", "\'");
//		strQuery = strQuery.replaceAll("&gt;", ">'");
//		strQuery = strQuery.replaceAll("&lt;", "<");
		
		Connection connArgo = null; // ARGO CONNECTION
		PreparedStatement pstmtSel = null;
		ResultSet rs = null;
		JSONArray jsonArray = new JSONArray();
			
		try {
			/*
			 * ===============================================================
			 * 0. 실행쿼리 실행
			 * ===============================================================
			 */
			connArgo = DBManager.getArgoDbConn();
			pstmtSel = connArgo.prepareStatement(strQuery);
			rs = pstmtSel.executeQuery();
			jsonArray = resultSetToJsonArray(rs);
			
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
			errorHandle(e, connArgo);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			close(pstmtSel, connArgo, rs);
		}
		
		return jsonArray;
	}
	
//	public JSONArray exeProcedure(String procedure, String jsonStr) throws Exception {
//		EgovStringUtil esu = new EgovStringUtil();
//		jsonStr = esu.getHtmlStrCnvr(jsonStr);
//		
//		Connection connArgo = null; // ARGO CONNECTION
//		CallableStatement pstmt = null;
//		ResultSet rs = null;
//		JSONArray jsonArray  = new JSONArray();
//		   
//		try {
//			/*
//			 * ===============================================================
//			 * 0. 실행쿼리 실행
//			 * ===============================================================
//			 */
//			connArgo = DBManager.getArgoDbConn();
//			pstmt = connArgo.prepareCall(procedure);
//			JSONArray
//			org.codehaus.jettison.json.JSONArray json = new org.codehaus.jettison.json.JSONArray(jsonStr);
//			int outParameter = 0;
//			for(int i =0; i<json.length(); i++){
//				
//				if(json.getJSONObject(i).getString("inOut").equals("IN")){	// 모드 IN or OUT
//					if(json.getJSONObject(i).getString("dataType").equals("NUMBER")){	// 데이터 유형 NUMBER
//						pstmt.setInt((i+1), json.getJSONObject(i).getInt("data"));
//					}else{
//						pstmt.setString((i+1), json.getJSONObject(i).getString("data"));
//					}
//				}else{
//					pstmt.registerOutParameter((i+1), oracle.jdbc.OracleTypes.CURSOR);
//					outParameter = (i+1);
//				}
//			}
//			
//			pstmt.execute();
//			connArgo.commit();
//
//			if(outParameter!=0){
//				rs = (ResultSet) pstmt.getObject(outParameter);
//				jsonArray = resultSetToJsonArray(rs);
//			}
//			pstmt.close();
//			
//		} catch (ClassNotFoundException e) {
//			e.printStackTrace();
//			errorHandle(e, connArgo);
//		} catch (Exception e) {
//			e.printStackTrace();
//		} finally {
//			close(pstmt, connArgo, rs);
//		}
//		
//		return jsonArray;
//	}

	private JSONArray resultSetToJsonArray(ResultSet rs) throws Exception {
	    JSONArray jsonArray =  new JSONArray();
	    String sKey = "";
	    String sValue = "";

	    
	    while (rs.next()){
	    	
		 	JSONObject  jsonObj  = new JSONObject();
            ResultSetMetaData rmd = rs.getMetaData();

            for ( int i=1; i<=rmd.getColumnCount(); i++ )
            {
            	if(rmd.getColumnName(i).split("_")[0].equals("DEC")){
            		sKey = CamelUtil.convert2CamelCase(rmd.getColumnName(i).split("_")[1]);
            		sValue = SecurityUtil.AESDecrypyt(rs.getString(rmd.getColumnName(i)), null);
            		jsonObj.put(sKey, sValue);
            	}else{
            		jsonObj.put(rmd.getColumnName(i), rs.getString(rmd.getColumnName(i)));
            	}
            }

            jsonArray.add(jsonObj);
	    }
	    return jsonArray;
	}
	
}
