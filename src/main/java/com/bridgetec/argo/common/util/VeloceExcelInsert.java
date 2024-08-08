package com.bridgetec.argo.common.util;

import org.apache.commons.io.FilenameUtils;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.poifs.filesystem.OfficeXmlFileException;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.web.multipart.MultipartFile;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.bnk.crypto.CSNcrypt;
import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.service.ArgoDispatchServiceImpl;
import com.bridgetec.argo.vo.ArgoDispatchServiceVo;
import com.bridgetec.common.util.security.AESUtil;
import com.bridgetec.common.util.veloce.StringUtility;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.RequestParam;

public class VeloceExcelInsert {

	private static final Logger log = LoggerFactory.getLogger(VeloceExcelInsert.class);
	
	
	
	public Map<String,Object> excelDataInsertNew(@RequestParam("excelFile") MultipartFile excelFile ,
			List<ArgoDispatchServiceVo> reqUserInfoSvcList, ArgoDispatchServiceImpl argoDispatchServiceImpl,int insColNum,int insSeedNum){
		Map<String,Object> result = new HashMap<String, Object>();
		try {
			String extension = FilenameUtils.getExtension(excelFile.getOriginalFilename()) == null ? "" : FilenameUtils.getExtension(excelFile.getOriginalFilename()); // 3
		    if (!extension.equals("xlsx") && !extension.equals("xls")) {
		      throw new IOException("엑셀파일만 업로드 해주세요.");
		    }
		    Workbook workBook = null;
	    	if(excelFile.getOriginalFilename().endsWith("xlsx")) {
			    workBook = new XSSFWorkbook(excelFile.getInputStream());
		    }else if(excelFile.getOriginalFilename().endsWith("xls")) {
		    	workBook = new HSSFWorkbook(excelFile.getInputStream());
		    }
	        
	        Sheet curSheet;
	        Row curRow;
	        Cell curCell; // 행
	        
            int numberOfSheets = workBook.getNumberOfSheets(); // 시트의 갯수 추출
            //getStrCrypt(); 매소드 관련
    		ArgoDispatchServiceVo companyKindVO = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
    		companyKindVO.getReqInput().put("section", "COMPANY");
    		companyKindVO.getReqInput().put("keyCode", "SITE_PAGE_KIND");
    		String sitePageKind = argoDispatchServiceImpl.selectParam(companyKindVO, "menu.getSelectParam");
            List<Integer> listEncColumn = new ArrayList<Integer>();
            
            reqUserInfoSvcList.get(0).setSvcName("recSearchNew");
            reqUserInfoSvcList.get(0).setMethodName("getRecSearchCustExcelUpdateNew");
            
            // 시트
            for (int i = 0; i < numberOfSheets; i++) {
            	curSheet =  workBook.getSheetAt(i);
        		curRow = curSheet.getRow(1);
        		for(int j=0;j<curRow.getLastCellNum();j++) {
        			curCell = curRow.getCell(j);
        			if(curCell.toString().indexOf("Eencrypt")>-1) {
        				listEncColumn.add(j);
        			}
        		}
            	for(int j=2;j<=curSheet.getLastRowNum();j++) {
            		Map<String, Object> reqInput = new HashMap<String,Object>(); 
//                	reqInput = argoDispatchServiceVo.getReqInput();
            		boolean instType = true;
            		String strSeed = "";
            		curRow = curSheet.getRow(j);
            		
            		// 첫번째 셀(key 값 없을 때 )
            		if(curRow.getCell(0).getCellType() == 3) { 
            			instType = false;
            			continue;
            		}
            		
            		// seed 복호화
            		if(insSeedNum >-1) {
        				strSeed = String.valueOf(curRow.getCell(insSeedNum));
            			strSeed = AESUtil.decrypt(strSeed);
        			}
            		
            		// 숫자형이 실수로 나옴 1.0 -> 정수형으로 수정
            		curCell = curRow.getCell(0);
        			cellNumberTypeChange(curCell); // 숫자형이 실수로 나옴 1.0
        			String strCell = String.valueOf(curCell);
        			if(strCell.indexOf("||") > 0) {
        				String[] arrCell = strCell.split("\\|\\|");
        				for(int k=0;k<arrCell.length;k++) {
        					reqInput.put("updateInfo0"+k, arrCell[k]);
        				}
        			}else {
        				reqInput.put("updateInfo0", strCell);
        			}
        			
        			int upColNum = 1;
        			
        			
            		for(int k=insColNum;k<curRow.getLastCellNum();k++){
            			curCell = curRow.getCell(k);
            			if(curCell != null) {
            				cellNumberTypeChange(curCell); // 숫자형이 실수로 나옴 1.0
            				String decValue = curCell.toString();
            				if(listEncColumn.indexOf(k)>-1) {
            					if(!decValue.equals("")) {decValue = getStrCrypt(sitePageKind, "enc", "custNo", (String) decValue,strSeed);}
            				}
            				reqInput.put("custData", decValue);
            				reqInput.put("colId", String.valueOf("CUST_ETCS"+upColNum));
            				if(instType) {
                    			System.out.println("reqInputexecuteparam : " + reqInput.toString());
                    			reqUserInfoSvcList.get(0).setReqInput(reqInput);
                    			argoDispatchServiceImpl.execute(reqUserInfoSvcList);
                    		}         
            			}
            			upColNum++;
            		}
            	}
            }
            result.put("result", true);
            result.put("message",  "고객정보 수정이 완료하였습니다.<br/>정보를 확인해주세요.");
		} catch(OfficeXmlFileException oe) {
			result.put("result", false);
			result.put("message",  "엑셀파일 확장자를 수정해주세요. xlsx > xls");
			oe.printStackTrace();
	    }catch (Exception e) {
			result.put("result", false);
			result.put("message",  "고객정보 수정이 완료하였습니다.<br/>정보를 확인해주세요.");
			log.error("Exception=" + e);
		}
		return result;
	}
	
	
	public Map<String,Object> excelDataInsert(@RequestParam("excelFile") MultipartFile excelFile ,
			List<ArgoDispatchServiceVo> reqUserInfoSvcList, ArgoDispatchServiceImpl argoDispatchServiceImpl,int insColNum,int insSeedNum){
		Map<String,Object> result = new HashMap<String, Object>();
		try {
			String extension = FilenameUtils.getExtension(excelFile.getOriginalFilename()) == null ? "" : FilenameUtils.getExtension(excelFile.getOriginalFilename()); // 3
		    if (!extension.equals("xlsx") && !extension.equals("xls")) {
		      throw new IOException("엑셀파일만 업로드 해주세요.");
		    }
		    Workbook workBook = null;
	    	if(excelFile.getOriginalFilename().endsWith("xlsx")) {
			    workBook = new XSSFWorkbook(excelFile.getInputStream());
		    }else if(excelFile.getOriginalFilename().endsWith("xls")) {
		    	workBook = new HSSFWorkbook(excelFile.getInputStream());
		    }
	        
	        Sheet curSheet;
	        Row curRow;
	        Cell curCell; // 행
	        
            int numberOfSheets = workBook.getNumberOfSheets(); // 시트의 갯수 추출
            //getStrCrypt(); 매소드 관련
    		ArgoDispatchServiceVo companyKindVO = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
    		companyKindVO.getReqInput().put("section", "COMPANY");
    		companyKindVO.getReqInput().put("keyCode", "SITE_PAGE_KIND");
    		String sitePageKind = argoDispatchServiceImpl.selectParam(companyKindVO, "menu.getSelectParam");
            List<Integer> listEncColumn = new ArrayList<Integer>();
            // 시트
            for (int i = 0; i < numberOfSheets; i++) {
            	curSheet =  workBook.getSheetAt(i);
        		curRow = curSheet.getRow(1);
        		for(int j=0;j<curRow.getLastCellNum();j++) {
        			curCell = curRow.getCell(j);
        			if(curCell.toString().indexOf("Eencrypt")>-1) {
        				listEncColumn.add(j);
        			}
        		}
            	for(int j=2;j<=curSheet.getLastRowNum();j++) {
            		Map<String, Object> reqInput = new HashMap<String,Object>(); 
//                	reqInput = argoDispatchServiceVo.getReqInput();
            		boolean instType = true;
            		String strSeed = "";
            		curRow = curSheet.getRow(j);
            		
            		// 첫번째 셀(key 값 없을 때 )
            		if(curRow.getCell(0).getCellType() == 3) { 
            			instType = false;
            			continue;
            		}
            		
            		// seed 복호화
					/*
					 * if(insSeedNum >-1) { strSeed = String.valueOf(curRow.getCell(insSeedNum));
					 * strSeed = AESUtil.decrypt(strSeed); }
					 */
            		
            		// 숫자형이 실수로 나옴 1.0 -> 정수형으로 수정
            		curCell = curRow.getCell(0);
        			cellNumberTypeChange(curCell); // 숫자형이 실수로 나옴 1.0
        			String strCell = String.valueOf(curCell);
        			if(strCell.indexOf("||") > 0) {
        				String[] arrCell = strCell.split("\\|\\|");
        				for(int k=0;k<arrCell.length;k++) {
        					reqInput.put("updateInfo0"+k, arrCell[k]);
        				}
        			}else {
        				reqInput.put("updateInfo0", strCell);
        			}
        			
        			int upColNum = 1;
        			
        			
            		for(int k=insColNum;k<curRow.getLastCellNum();k++){
            			curCell = curRow.getCell(k);
            			if(curCell != null) {
            				cellNumberTypeChange(curCell); // 숫자형이 실수로 나옴 1.0
            				String decValue = curCell.toString();
            				if(listEncColumn.indexOf(k)>-1) {
            					if(!decValue.equals("")) {decValue = getStrCrypt(sitePageKind, "enc", "custNo", (String) decValue,strSeed);}
            				}
            				reqInput.put(String.valueOf("updateInfo"+upColNum), decValue);
            			}
            			upColNum++;
            		}
            		
            		if(instType) {
            			//insert 자리
            			reqUserInfoSvcList.get(0).setReqInput(reqInput);
            			argoDispatchServiceImpl.execute(reqUserInfoSvcList);
            		}            		
            	}
            }
            result.put("result", true);
            result.put("message",  "고객정보 수정이 완료하였습니다.<br/>정보를 확인해주세요.");
		} catch(OfficeXmlFileException oe) {
			result.put("result", false);
			result.put("message",  "엑셀파일 확장자를 수정해주세요. xlsx > xls");
			oe.printStackTrace();
	    }catch (Exception e) {
			result.put("result", false);
			result.put("message",  "고객정보 수정이 완료하였습니다.<br/>정보를 확인해주세요.");
			log.error("Exception=" + e);
		}
		return result;
	}
	
	public Cell cellNumberTypeChange(Cell curCell) {
		if(curCell.getCellType() == 0) {
			curCell.setCellType(Cell.CELL_TYPE_STRING ); 
		}
		return curCell;
	}
	
	// 암복호화 (회사, 암복호구분, 고객번호(전화)구분, 변환문자)
		private String getStrCrypt(String strSiteKind, String strType, String strFlag, String strText, String seed) {
			String strValue = "";
			AESUtil aesUtil = new AESUtil();
			
			try {
				if(strText == null || strText.equals("") ){
					strValue = "";
				}else if(seed == null || seed.equals("null")){
					if ("enc".equals(strType)) {
						strValue = aesUtil.encrypt(strText);
					}else {
						strValue = aesUtil.decrypt(strText);
					}
				}else{
//					aesUtil.setKey("BRIDGETEC_VELOCE", Constant.ME_SHARED_BIT);
					String deSeed = aesUtil.decrypt(seed);
					aesUtil.setKey(deSeed, Constant.ME_SHARED_BIT);
					if ("BNK".equals(strSiteKind)) { // 부산은행 암복호화
						if ("enc".equals(strType)) {
							if ("custNo".equals(strFlag)) {
								strValue = CSNcrypt.Encrypt(StringUtility.nvl(strText, ""));
							} else if ("custTel".equals(strFlag)) {
								strValue = CSNcrypt.TELcrypt(CSNcrypt.ENCRYPT, StringUtility.nvl(strText, ""));
							} else {
								strValue = strText;
							}
						} else {
							if ("custNo".equals(strFlag)) {
								strValue = CSNcrypt.Decrypt(StringUtility.nvl(strText, ""));
							} else if ("custTel".equals(strFlag) || "custEtc1".equals(strFlag)) {
								strValue = CSNcrypt.TELcrypt(CSNcrypt.DECRYPT, StringUtility.nvl(strText, ""));
							} else {
								strValue = strText;
							}
						}
					} else { // 일반 암복호화
						if ("enc".equals(strType)) {
							if ("custNo".equals(strFlag) || "custTel".equals(strFlag)) {
								strValue = aesUtil.encrypt(strText.trim());
							} else{
								strValue = strText;
							}
						} else {
							if ("custNo".equals(strFlag) || "custTel".equals(strFlag)) {
								strValue = aesUtil.decrypt(strText);
							} else {
								strValue = strText;
							}
						}
					}
					aesUtil.setKey("BRIDGETEC_VELOCE", Constant.ME_SHARED_BIT);
				}
			} catch (UnsupportedOperationException ex) {
				return strText;
			} catch (Exception ex) {
				return strText;
			}
			return strValue;
		}
}
