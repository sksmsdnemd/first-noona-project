package com.bridgetec.common.util.veloce;

import java.io.File;
import java.io.FileOutputStream;
import java.io.Writer;
import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.xssf.streaming.SXSSFSheet;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFDataFormat;
import org.apache.poi.xssf.usermodel.XSSFFont;

import egovframework.com.cmm.EgovWebUtil;
import egovframework.com.utl.fcc.service.EgovStringUtil;

public class ExcelUtility {
	private Logger logger = LoggerFactory.getLogger(ExcelUtility.class);
	private static final String SHEET_PREFIX = "Sheet";		// 0부터 시작

	public void excelDownLoad(Map<String, Object> excelMap) {
		String excelFileNm  = (excelMap.get("FILE_NAME") == null || "".equals(excelMap.get("FILE_NAME"))) ? "Book.xlsx" : EgovStringUtil.isNullToString(excelMap.get("FILE_NAME"));
		String excelSheetNm = (excelMap.get("SHEET_NAME") == null || "".equals(excelMap.get("SHEET_NAME"))) ? SHEET_PREFIX : EgovStringUtil.isNullToString(excelMap.get("SHEET_NAME"));
		// 엑셀 text에 줄내림 여부(true :줄내림)
		boolean wrapTextAt = (excelMap.get("WRAP_TEXT") == null ) ? false : (boolean) excelMap.get("WRAP_TEXT");

		FileOutputStream fos = null;
		FileOutputStream out = null;
		Writer fw = null;

		try {
			// 대용량 처리를 위해 xls로 입력 된 경우 xlsx로 변경			
			if(excelFileNm.indexOf(".") != -1) {
				excelFileNm = excelFileNm.substring(0, excelFileNm.lastIndexOf(".")) + ".xlsx";
			} else {
				excelFileNm = excelFileNm + ".xlsx";
			}
			
			String tempDir = "C:/00_JYS79/00_BT/temp/BT-VELOCE/";
			File folder = new File(EgovWebUtil.filePathBlackList(tempDir));
			if (!folder.exists() ) {
				boolean folderAt = folder.mkdirs();
				if(!folderAt){
					logger.error("Can't Create Folder : " + folder.getAbsolutePath());
					throw new Exception("Can't Create Folder : " + folder.getAbsolutePath());
				}
			}
			
			SXSSFWorkbook wb = new SXSSFWorkbook(100);
			SXSSFSheet sheet = (SXSSFSheet) wb.createSheet(excelSheetNm);

			Map<String, XSSFCellStyle> styles = createStyles(wb, wrapTextAt);
			
//			String sheetRef = sheet.getPackagePart().getPartName().getName();
//			
//			sheet.get
			
			
			


		} catch (IllegalArgumentException iae) {
			logger.error("Exception");
//			EgovStringUtil.exceptionMsg(this.getClass(), e);
		} catch (Exception e) {
			logger.error("Exception");
//			EgovStringUtil.exceptionMsg(this.getClass(), e);
		}

	}

	/** 엑셀 스타일 생성
	 *  http://poi.apache.org/spreadsheet/quick-guide.html#Borders
	 */
	public Map<String, XSSFCellStyle> createStyles(SXSSFWorkbook wb, boolean wrapTextAt) {
		Map<String, XSSFCellStyle> styles = new HashMap<String, XSSFCellStyle>();
		XSSFDataFormat fmt = (XSSFDataFormat) wb.createDataFormat();

		// 기본 스타일 지정
		XSSFCellStyle base = (XSSFCellStyle) wb.createCellStyle();
		base.setAlignment(XSSFCellStyle.ALIGN_CENTER);
		base.setVerticalAlignment(XSSFCellStyle.VERTICAL_CENTER);
		styles.put("base", base);

		// 타이틀
		XSSFCellStyle title = (XSSFCellStyle) wb.createCellStyle();
//		XSSFFont titleFont  = (XSSFFont) wb.createFont();
//		titleFont.setBold(true);
//		title.setFont(titleFont);
		title.setAlignment(XSSFCellStyle.ALIGN_CENTER);
		title.setVerticalAlignment(XSSFCellStyle.VERTICAL_CENTER);
		styles.put("title", title);

		// 테두리, left정렬
		XSSFCellStyle left = (XSSFCellStyle) wb.createCellStyle();
		left.setWrapText(wrapTextAt);
		left.setBorderBottom(XSSFCellStyle.BORDER_THIN);
		left.setBorderLeft(XSSFCellStyle.BORDER_THIN);
		left.setBorderRight(XSSFCellStyle.BORDER_THIN);
		left.setBorderTop(XSSFCellStyle.BORDER_THIN);
		left.setAlignment(XSSFCellStyle.ALIGN_LEFT);
		left.setVerticalAlignment(XSSFCellStyle.VERTICAL_CENTER);
		styles.put("left", left);

		// 헤더
		XSSFCellStyle header = (XSSFCellStyle) wb.createCellStyle();
		header.cloneStyleFrom(left);												// 기본 스타일 복사
		header.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());	// 채우기 색 지정
		header.setFillPattern(XSSFCellStyle.SOLID_FOREGROUND);						// 채우기스타일
		header.setAlignment(XSSFCellStyle.ALIGN_CENTER);							// 가운데 정렬
		XSSFFont headerFont  = (XSSFFont) wb.createFont();
		headerFont.setBold(true);
		header.setFont(headerFont);		// 볼트체
		styles.put("header", header);
		
		// center 정렬
		XSSFCellStyle center = (XSSFCellStyle) wb.createCellStyle();
		center.cloneStyleFrom(left);
		center.setAlignment(XSSFCellStyle.ALIGN_CENTER);
		styles.put("center", center);

		// right 정렬
		XSSFCellStyle right = (XSSFCellStyle) wb.createCellStyle();
		right.cloneStyleFrom(left);
		right.setAlignment(XSSFCellStyle.ALIGN_RIGHT);
		styles.put("right", right);

		// 퍼센트
		XSSFCellStyle percent = (XSSFCellStyle) wb.createCellStyle();
		percent.cloneStyleFrom(left);
		percent.setAlignment(XSSFCellStyle.ALIGN_RIGHT);
		percent.setDataFormat(fmt.getFormat("0.0%"));
		styles.put("percent", percent);

		return styles;
	}





}
