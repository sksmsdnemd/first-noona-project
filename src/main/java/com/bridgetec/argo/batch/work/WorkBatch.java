package com.bridgetec.argo.batch.work;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

//import org.apache.log4j.Logger;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;

import com.bridgetec.argo.batch.util.StringUtil;

public class WorkBatch {

	private static final Logger logger = LogManager.getLogger(WorkBatch.class);

	public static String batchMain(String tenantId, String workId, String workDate) throws Exception {
		String schId = "HAND_"+workId;
		String schSeq = "HAND";
		
		// ****** TB_DB_LOG_BATCH 기록을 위한 변수 ***********************************
		long workdatetime = System.currentTimeMillis();
		long workStartdateTime = System.currentTimeMillis();
		String sussYn = "S";
		String errMsg = "";
		String sPtocCnt = "0";
		Map<String, String> mapProcResult = new HashMap<String, String>();

		// 0.로그기록 START 전체로그 ***********************************************
		workStartdateTime = System.currentTimeMillis();
		sussYn = "S";
		errMsg = "";
		WorkLogic.getInstance().setBatchLog(tenantId, schId, schSeq,
				workdatetime, workStartdateTime, System.currentTimeMillis(),
				workId, "START", "0",
				"TENANT_ID:" + tenantId + " WORK_ID:" + workId);

		try {

			String sInout = null; // INOUT구분
			/*
			 * ===============================================================
			 * 0. 작업정보 조회
			 * ===============================================================
			 */
			ArrayList<HashMap<String, String>> rsWorkInfo = new ArrayList<HashMap<String, String>>();
			rsWorkInfo = WorkLogic.getInstance().getWorkInfo(tenantId, workId);

			/*
			 * ===============================================================
			 * 1.X 작업정보 없을 경우 종료
			 * ===============================================================
			 */
			if (rsWorkInfo.isEmpty()) {
				errMsg = "작업정보가 없거나 정보가 불충분하여 종료합니다.";
				sussYn = "F";
			} else {

				HashMap<String, String> rowWorkInfo = rsWorkInfo.get(0);
				rowWorkInfo.put("WORK_DT", (workDate == null)?new SimpleDateFormat("yyyyMMdd").format(Calendar.getInstance().getTime()):workDate);

				// 작업 실패시 재시도 처리를 위해
				int iExeCnt = 0;
				int iRetryCnt = Integer.parseInt(rowWorkInfo.get("RETRY_CNT"));
				iRetryCnt = (iRetryCnt == 0 ? 1 : iRetryCnt);

				/*
				 * ==============================================================
				 * = 2. 작업정보 존재
				 * ==================================================
				 * =============
				 */
				sInout = rowWorkInfo.get("WORK_GUBUN");

				if (sInout == null) {
					errMsg = "[WORK_GUBUN] 정보가 불충분하여 종료합니다.";
					sussYn = "F";
//					logger.warn(errMsg);

				} else {
					/*
					 * ==========================================================
					 * =====2.1 수신(IN) 일떄
					 * ========================================
					 * =======================
					 */
					if ("IN".equals(sInout)) {
						if (StringUtil.isNullOrSpace(rowWorkInfo.get("EXE_QUERY"))) {
							errMsg = "[EXE_QUERY] 정보가 불충분하여 종료합니다.";
							sussYn = "F";
//							logger.warn(errMsg);
						} else if (StringUtil.isNullOrSpace(rowWorkInfo.get("SOURCE_TYP"))) {
							errMsg = "[SOURCE_TYP] 정보가 불충분하여 종료합니다.";
							sussYn = "F";
							logger.warn(errMsg);
						} else {
							// 소스유형에 따라 필수값 체크
							if ("FILE".equals(rowWorkInfo.get("SOURCE_TYP"))) {
								if (StringUtil.isNullOrSpace(rowWorkInfo.get("FILE_PATH"))
										|| StringUtil.isNullOrSpace(rowWorkInfo.get("FILE_ENCODE"))
										|| StringUtil.isNullOrSpace(rowWorkInfo.get("FILE_DELIMITER"))) {
									errMsg = "[FILE] 정보가 불충분하여 종료합니다.";
									sussYn = "F";
									logger.warn(errMsg);
								} else {
									while (iExeCnt < iRetryCnt) {
										iExeCnt++;

										mapProcResult = WorkLogic.getInstance().doWorkIn(rowWorkInfo);

										if ("S".equals(mapProcResult.get("RESULT_CD"))) {
											sussYn = "S";
											break;
										} else {
											sussYn = "F";
											WorkLogic.getInstance().setBatchLog(
															tenantId,
															schId,
															schSeq,
															workdatetime,
															System.currentTimeMillis(),
															System.currentTimeMillis(),
															workId,
															"F",
															"0",
															"[재시도] ERROR:" + mapProcResult.get("RESULT_MSG"));
										}
									}
								}

							} else if ("DB".equals(rowWorkInfo.get("SOURCE_TYP"))) {
								if (StringUtil.isNullOrSpace(rowWorkInfo.get("JDBC_DRIVER"))
										|| StringUtil.isNullOrSpace(rowWorkInfo.get("JDBC_URL"))
										|| StringUtil.isNullOrSpace(rowWorkInfo.get("USER_ID"))
										|| StringUtil.isNullOrSpace(rowWorkInfo.get("USER_PW"))) {
									errMsg = "[DB] 정보가 불충분하여 종료합니다.";
									sussYn = "F";
									logger.warn(errMsg);
								} else {
									// 재시도 횟수에 따라 반복 처리
									while (iExeCnt < iRetryCnt) {
										iExeCnt++;

										mapProcResult = WorkLogic.getInstance().doWorkIn(rowWorkInfo);

										if ("S".equals(mapProcResult.get("RESULT_CD"))) {
											sussYn = "S";
											break;
										} else {
//											logger.info("############재시도 횟수"
//													+ iExeCnt);
											sussYn = "F";
											WorkLogic.getInstance().setBatchLog(
															tenantId,
															schId,
															schSeq,
															workdatetime,
															System.currentTimeMillis(),
															System.currentTimeMillis(),
															workId,
															"F",
															"0",
															"[재시도] ERROR:" + mapProcResult.get("RESULT_MSG"));
										}
									}
								}
							}
						}
					} else if ("OUT".equals(sInout)) {
						/*
						 * ======================================================
						 * =========2.2 송신(OUT) 일떄 >> ARGO DB TO FILE
						 * ======================================================
						 */
						if (StringUtil.isNullOrSpace(rowWorkInfo.get("SEL_QUERY"))) {
							errMsg = "[SEL_QUERY] 정보가 불충분하여 종료합니다.";
							sussYn = "F";
							logger.warn(errMsg);
						} else if (StringUtil.isNullOrSpace(rowWorkInfo.get("FILE_PATH"))
								|| StringUtil.isNullOrSpace(rowWorkInfo.get("FILE_NM"))
								|| StringUtil.isNullOrSpace(rowWorkInfo.get("FILE_DELIMITER"))) {
							errMsg = "[FILE] 정보가 불충분하여 종료합니다.";
							sussYn = "F";
							logger.warn(errMsg);
						} else {
							// 재시도 횟수에 따라 반복 처리
							while (iExeCnt < iRetryCnt) {
								iExeCnt++;

								mapProcResult = WorkLogic.getInstance().doWorkOut(rowWorkInfo);

								if ("S".equals(mapProcResult.get("RESULT_CD"))) {
									sussYn = "S";
									break;
								} else {
//									logger.info("############재시도 횟수" + iExeCnt);
									sussYn = "F";
									WorkLogic.getInstance().setBatchLog(
											tenantId,
											schId,
											schSeq,
											workdatetime,
											System.currentTimeMillis(),
											System.currentTimeMillis(),
											workId,
											"F",
											"0",
											"[재시도] ERROR:" + mapProcResult.get("RESULT_MSG"));
								}
							}
						}
					} else if ("EXE_SP".equals(sInout)) {
						/*
						 * ======================================================
						 * =========2.3 쿼리실행 일떄
						 * ==================================
						 * =============================
						 */
						if (StringUtil.isNullOrSpace(rowWorkInfo.get("EXE_QUERY"))) {
							errMsg = "[EXE_QUERY] 정보가 불충분하여 종료합니다.";
							sussYn = "F";
							logger.warn(errMsg);
						} else {
							// 재시도 횟수에 따라 반복 처리
							while (iExeCnt < iRetryCnt) {
								iExeCnt++;

								mapProcResult = WorkLogic.getInstance().doWorkExeProcedure(rowWorkInfo);

								if ("S".equals(mapProcResult.get("RESULT_CD"))) {
									sussYn = "S";
									break;
								} else {
//									logger.info("############재시도 횟수" + iExeCnt);
									sussYn = "F";
									WorkLogic.getInstance().setBatchLog(
											tenantId,
											schId,
											schSeq,
											workdatetime,
											System.currentTimeMillis(),
											System.currentTimeMillis(),
											workId,
											"F",
											"0",
											"[재시도] ERROR:" + mapProcResult.get("RESULT_MSG"));
								}
							}

						}
					} else if ("EXE_CMD".equals(sInout)) {
						/*
						 * ======================================================
						 * =========2.3 쿼리실행 일떄
						 * ======================================================
						 */
						if (StringUtil.isNullOrSpace(rowWorkInfo.get("EXE_QUERY"))) {
							errMsg = "[EXE_QUERY] 정보가 불충분하여 종료합니다.";
							sussYn = "F";
							logger.warn(errMsg);
						} else {
							// 재시도 횟수에 따라 반복 처리
							while (iExeCnt < iRetryCnt) {
								iExeCnt++;

								mapProcResult = WorkLogic.getInstance().doWorkExeCommand(rowWorkInfo);

								if ("S".equals(mapProcResult.get("RESULT_CD"))) {
									sussYn = "S";
									break;
								} else {
//									logger.info("############재시도 횟수" + iExeCnt);
									sussYn = "F";
									WorkLogic.getInstance().setBatchLog(
											tenantId,
											schId,
											schSeq,
											workdatetime,
											System.currentTimeMillis(),
											System.currentTimeMillis(),
											workId,
											"F",
											"0",
											"[재시도] ERROR:" + mapProcResult.get("RESULT_MSG"));
								}
							}
						}
					}
				}
			}

			if (!mapProcResult.isEmpty()) {
//				logger.info("처리결과 >>>>>>>작업ID:" + workId + " /처리일자:" + workDate
//						+ " /성공여부:" + mapProcResult.get("RESULT_CD")
//						+ " /처리건수:" + mapProcResult.get("RESULT_CNT"));
				sPtocCnt = mapProcResult.get("RESULT_CNT");
				errMsg = mapProcResult.get("RESULT_MSG");
			}

		} catch (Exception e) {
			sussYn = "F";
			errMsg = e.getMessage();
			if (errMsg.length() > 1500) {
				errMsg = errMsg.substring(0, 1500);
			}
			e.printStackTrace();
			// X.로그기록 END ***********************************************
			WorkLogic.getInstance().setBatchLog(tenantId, schId, schSeq,
					workdatetime, workdatetime, System.currentTimeMillis(),
					workId, sussYn, "0",
					"WORK_ID:" + workId + " ERROR:" + errMsg);

		} finally {
			// X.로그기록 END ***********************************************
			WorkLogic.getInstance().setBatchLog(
					tenantId,
					schId,
					schSeq,
					workdatetime,
					workdatetime,
					System.currentTimeMillis(),
					workId,
					sussYn,
					sPtocCnt,
					"TENANT_ID:" + tenantId + " WORK_ID:" + workId + " " + errMsg);
		}
//		logger.info("=================================================================");
//		logger.info("===========  ARGO BATCH WORK 종료  [SCHE_ID:" + schId
//				+ "/TASK_ID:" + schSeq + "/WORK_ID:" + workId + " /WORK_DT:"
//				+ workDate + "]");
//		logger.info("===========  [" + pInfo + "]");
//		logger.info("=================================================================");
		if(sussYn=="S"){
			return sussYn;
		}else{
			return errMsg;
		}
	}
}
