package com.bridgetec.argo.common.util;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.util.CellRangeAddress;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.PrintSetup;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFFont;
import org.apache.poi.xssf.usermodel.XSSFPrintSetup;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.view.AbstractView;

import com.bridgetec.argo.vo.ArgoDispatchServiceVo;

import egovframework.rte.psl.dataaccess.util.EgovMap;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;


@SuppressWarnings("deprecation")
public class ArgoExcelExport extends AbstractView {
    
    private static final Logger log = LoggerFactory.getLogger(ArgoExcelExport.class);
    private static final String CONTENT_TYPE = "application/vnd.ms-excel";
    private static final DataFormatter FORMATTER = new DataFormatter();         //셀병합 체크 사용

    /*public SaExcelNoDbUse() {
        setContentType(CONTENT_TYPE);
    }*/

    @Override
    protected void renderMergedOutputModel(Map<String, Object> model, HttpServletRequest request, HttpServletResponse response) throws Exception {

        final short ALIGN_LEFT              = CellStyle.ALIGN_LEFT;         //좌우왼쪽정렬
        final short ALIGN_RIGHT             = CellStyle.ALIGN_RIGHT;        //좌우오른쪽정렬
        final short ALIGN_CENTER            = CellStyle.ALIGN_CENTER;       //좌우가운데정렬
        final short VERTICAL_ALIGN_CENTER   = CellStyle.VERTICAL_CENTER;    //상하가운데정렬
        final short SOLID_FOREGROUND        = CellStyle.SOLID_FOREGROUND;    
        final short BORDER_THICK            = HSSFCellStyle.BORDER_THICK;   //Line두껍게
        final short BORDER_THIN             = HSSFCellStyle.BORDER_THIN;    //Line얇게
        final short COLOR_YELLOW            = HSSFColor.YELLOW.index;       //컬러 노란색

        boolean allViewFlag = false;                                        //그리드 전체 여부

        String excelFileNm = "SaLoadExcel";
        String fileName = "";
        
        try {
            
            Workbook workbook = new XSSFWorkbook();
            
            //헤더 폰트 및 스타일 지정
            Font Hfont= workbook.createFont();
            Hfont.setFontHeightInPoints((short)11);
            Hfont.setFontName("맑은 고딕");
            Hfont.setBoldweight(XSSFFont.BOLDWEIGHT_BOLD);
            
            CellStyle Hstyle  = workbook.createCellStyle();
            Hstyle.setAlignment(ALIGN_CENTER);    
            Hstyle.setVerticalAlignment(VERTICAL_ALIGN_CENTER);
            Hstyle.setFillPattern(SOLID_FOREGROUND);
            Hstyle.setFillForegroundColor(COLOR_YELLOW);
            Hstyle.setFillBackgroundColor(COLOR_YELLOW);
            Hstyle.setBorderTop(BORDER_THIN);
            Hstyle.setBorderBottom(BORDER_THIN);
            Hstyle.setBorderLeft(BORDER_THIN);
            Hstyle.setBorderRight(BORDER_THIN);
            Hstyle.setFont(Hfont);
            
            //바디 폰트 및 스타일 지정
            Font Bfont= workbook.createFont();
            Bfont.setFontHeightInPoints((short)10);
            Bfont.setFontName("맑은 고딕");
            
            CellStyle Bstyle = workbook.createCellStyle();
            Bstyle.setFont(Bfont);             

            
            List<ArgoDispatchServiceVo> svcList = (List<ArgoDispatchServiceVo>) model.get("saVoList");
            for(ArgoDispatchServiceVo argoServiceVO : svcList){
                
                int start_row = 0;
                int d_xpos = 0, d_ypos = 0;
                fileName = (String)((Map)argoServiceVO.getReqInput()).get("xlsName");
                
                //XLSX 본문생성
                XSSFRow row = null;
                XSSFCell cell = null;
                XSSFSheet sheet = (XSSFSheet) workbook.createSheet("Sheet1");
                
                JSONObject h_options = null;
                String header_json = (String)argoServiceVO.getReqInput().get("h_options");
                
                //1. DB RecordSet으로만 엑셀문서 작성 (그리드 헤더 값이 없을 경우)
                if(header_json==null){
                    
                    d_xpos = start_row;
                    row = sheet.createRow(d_xpos);
                    d_xpos++;
                    
                    //start header
                    EgovMap  egovMap = (EgovMap)((List)argoServiceVO.getResOut()).get(0);
                    Iterator keys = egovMap.keySet().iterator();
                    while(keys.hasNext()){
                        Cell h_cell = row.createCell(d_ypos);
                        h_cell.setCellValue((String)keys.next());
                        h_cell.setCellStyle(Hstyle);
                        d_ypos++;
                    }//end header while
                    
                    //body start
                    for(int i=0 ; i < ((List)argoServiceVO.getResOut()).size(); i++){
                        row = sheet.createRow(i+d_xpos);
                        EgovMap  egovMap2 = (EgovMap)((List)argoServiceVO.getResOut()).get(i);
                        Iterator keys2 = egovMap2.keySet().iterator();
                        d_ypos=0;
                        while(keys2.hasNext()){
                            Object key = keys2.next();
                            Cell b_cell = row.createCell(d_ypos);
                            //if(egovMap2.get(key) instanceof java.math.BigDecimal){
                            //    b_cell.setCellValue( nullToLong(egovMap2.get(key)) );
                            //}else{
                                b_cell.setCellValue( nullToSpace(egovMap2.get(key)) );
                            //}
                            b_cell.setCellStyle(Bstyle);
                            d_ypos++;
                        }                    
                    }//end data for                        
                    
                //2. 그리드 헤더를 이용하여 엑셀에 그리는 경우. (데이터도 그리드를 사용할지 , 않할지 구분)    
                }else{
                    
                    h_options = JSONObject.fromObject(header_json);
                    JSONArray h_rows = (JSONArray)h_options.getJSONArray("columns");
                    List<String> d_header = (List)((Map)argoServiceVO.getReqInput()).get("d_header");
                    
                    Map<String, Short> d_align = new HashMap();
                    Map<String, Boolean> d_hidden = new HashMap();

                    //그리드 전체여부 체크
                    String allView = (String)returnUtil((String)((Map)argoServiceVO.getReqInput()).get("allViewFlag"), "");
                    if(allView.trim().toLowerCase().equals("true")) allViewFlag = true;
                    else allViewFlag = false;
                    
                    //start grid header
                    int headerRowCount = h_rows.size();
                    for(int i=0; i<headerRowCount; i++){
                        
                        JSONArray h_columns = (JSONArray)h_rows.get(i);
                        int headerColCount = h_columns.size();
                        
                        int h_xpos = start_row+i;   //엑셀row 위치지정
                        int h_ypos = 0;             //엑셀col 위치지정 _ merge때문에 j값을 사용할 수 없음.
                        
                        row = sheet.createRow(h_xpos);
                        d_xpos = h_xpos+1;  //data부가 시작되는 row번호를 지정.
                        
                        for(int j=0; j<headerColCount; j++){
                            JSONObject h_cell = (JSONObject)h_columns.get(j);
                            
                            //body작성시 사용할 데이터 추출
                            if (d_header.contains((String)h_cell.get("field"))){
                              //  String alignValue = (String)returnUtil(h_cell.get("align").toString(), "left");
                                String alignValue = (String)returnUtil(h_cell.get("align"), "left"); /* align 없는 경우 오류발생*/
                                Short align = null;
                                
                                if(alignValue.equals("center")){ align = ALIGN_CENTER; }
                                else if(alignValue.equals("right")){ align = ALIGN_RIGHT; }
                                else{ align = ALIGN_LEFT; }
                                
                                d_align.put((String)h_cell.get("field"), align);
                                d_hidden.put((String)h_cell.get("field"), (boolean)returnUtil(h_cell.get("hidden"), false));
                                
                            }

                            //엑셀 전체 작성여부 체크
                            if(allViewFlag == false && (boolean)returnUtil(h_cell.get("hidden"), false)){
                                continue;
                            }
                            
                            //새로운 행으로 옮겼을 때, 해당 행이 Merge(병합)되어있는지 체크하여, 빈 셀값을 찾는다. 
                            while(true){
                                cell = row.createCell(h_ypos);
                                cell.setCellStyle(Hstyle);

                                if(isMergedRegion(sheet, cell)){
                                    h_ypos++;
                                }else{
                                    break;
                                }
                            }
                            
                            //사용하고자 하는 셀의 정보값을 읽어, Merge여부를 판단하여 처리.
                            int rowSpan = (int)returnUtil(h_cell.get("rowspan"), 0);
                            int colSpan = (int)returnUtil(h_cell.get("colspan"), 0);
                            
                            if(rowSpan>0 || colSpan>0){
                                if(rowSpan>0) { rowSpan-=1; }
                                if(colSpan>0) { colSpan-=1; }
                                
                                @SuppressWarnings("deprecation")
                                CellRangeAddress region = new CellRangeAddress(h_xpos, h_xpos+rowSpan, h_ypos, h_ypos+colSpan); //firstrow, lastrow, firstcol, lastcol
                                sheet.addMergedRegion(region);
                            }

                            //모든 작업을 완료하면, 해당 셀의 값을 적는다.
                            String title = (String)h_cell.get("title");
                            cell.setCellValue(title);
                            
                            //헤더를 기준으로 컬럼싸이즈 조정
                            sheet.autoSizeColumn(h_ypos);
                            sheet.setColumnWidth(h_ypos, sheet.getColumnWidth(h_ypos) + 512);
                            
                            //모든 처리 완료 후, 셀의 위치값 증가.
                            h_ypos++;
                            
                            //별첨. 모두 처리후 다음 셀의 값을 확인하여 merge되어 있다면, 그 부분까지 셀을 적용.
                            if(i==headerRowCount-1){
                                while(true){
                                    cell = row.createCell(h_ypos);
                                    if(isMergedRegion(sheet, cell)){
                                        cell.setCellStyle(Hstyle);
                                        h_ypos++;
                                    }else{
                                        break;
                                    }
                                }
                            }
                        }
                    }//end grid header

                    
                    //start body
                    //2-1. DB의 데이터로 엑셀을 그리는 경우.
                    if(argoServiceVO.getResOut() instanceof List){
                        
                        for(int i=0 ; i < ((List)argoServiceVO.getResOut()).size(); i++){
                            row = sheet.createRow(i+d_xpos);
                            EgovMap  egovMap2 = (EgovMap)((List)argoServiceVO.getResOut()).get(i);
                            
                            d_ypos = 0;
                            for(String header : d_header){
                                if(allViewFlag == false && d_hidden.get(header)){
                                    continue;
                                }else{
                                    Bstyle.setAlignment((short)d_align.get(header));
                                }
                    
                                cell = row.createCell(d_ypos);
                                cell.setCellStyle(Bstyle);
                                cell.setCellValue(nullToSpace(egovMap2.get(header)));
                                d_ypos++;
                            }                            
                        }                       
                    
                    //2-2. 그리드의 데이터로 엑셀을 그리는 경우.
                    }else{
                        List<Map> d_rows = (List)((Map)argoServiceVO.getReqInput()).get("d_rows");
                            
                        for(Map data : d_rows){
                            row = sheet.createRow(d_xpos);
                            d_xpos++;
                            d_ypos=0;
                    
                            for(String header : d_header){
                                if(allViewFlag == false && d_hidden.get(header)){
                                    continue;
                                }else{
                                    Bstyle.setAlignment((short)d_align.get(header));
                                }
                    
                                cell = row.createCell(d_ypos);
                                cell.setCellStyle(Bstyle);
                                cell.setCellValue(nullToSpace(data.get(header)));
                                d_ypos++;
                            }
                        }                        
                    }//end body
                    
                } //

                
                
                //sheet.setDefaultColumnWidth(15);    //default column width
                // ((String)( (Map)argoServiceVO.getReqInput() ).get("scale"))
                
                //Print 설정.
                int iScale = Integer.parseInt(((String)((Map)argoServiceVO.getReqInput()).get("scale")));
                XSSFPrintSetup printsetup = sheet.getPrintSetup();
                printsetup.setFitWidth((short) 1);
                printsetup.setLandscape(true);  //가로출력 false:세로출력
                printsetup.setFitHeight((short) PrintSetup.A4_PAPERSIZE);
                printsetup.setScale((short) iScale);
                sheet.setAutobreaks(true);

                if(((String)((Map)argoServiceVO.getReqInput()).get("widthBasic")).equals("body")){
                  //데이터를 기준으로 컬럼을 조정
                    for (int iCol = 0; iCol < d_ypos; iCol++) {
                        sheet.autoSizeColumn(iCol);
                        sheet.setColumnWidth(iCol, sheet.getColumnWidth(iCol) + 512);
                    }    
                }

            }//end vo for
            
            
            //XLSX 파일생성
            excelFileNm = (String)returnUtil(fileName, excelFileNm);
            /*
            if(model.get("fileName")!=null){
                excelFileNm = model.get("fileName").toString();
            }
            */
            response.setContentType(CONTENT_TYPE);
            response.setHeader("Content-Disposition", "attachment;filename="+excelFileNm.replace("+","%20")+".xlsx");
            
            ServletOutputStream  out = response.getOutputStream();
            workbook.write(out);
            out.flush();
            
            if(out!=null)   
                out.close();            
            
        } catch (IOException ie) {
			log.error("ArgoExcelExport Exception = " + ie.toString());
        } catch (Exception e) {
        	log.error("ArgoExcelExport Exception = " + e.toString());
//        	throw e;
        }       
    }

    /**
     * 객체값을 String으로 변환.
     * @param arg
     * @return
     */
    private String nullToSpace(Object arg){
        if(arg==null)
            return "";
        return arg.toString();
    }
    
    /**
     * 객체값을 long으로 변환.
     * @param arg
     * @return
     */
    private long nullToLong(Object arg){
        if(arg==null)
            return 0;
        return ((BigDecimal)arg).longValue();
    }    
    
    /**
     * 객체값이 Null이면 다른객체값으로 전환하여 Object으로 리턴.
     * @param arg, arg2
     * @return
     */
    private Object returnUtil(Object arg, Object arg2){
        if(arg == null || arg.toString().trim() == "" || arg == "undefined" || arg.equals("undefined")){ arg = arg2; }
        return arg;
    }
    
    /**
     * Client에서 보내온 파라미터를 Map으로 변환하여 리턴.
     * @param arg, arg2
     * @return
     */
    private HashMap ListToMap(List list){
        HashMap map = new HashMap();
        HashMap temp = new HashMap();
        for(int i=0; i<list.size(); i++){
            temp = (HashMap)list.get(i);
            map.put(temp.get("key"), temp.get("value"));
        }
        return map;                    
    }
    
    /**
     * 지정된 셀이 병합되었는지 체크
     * @param sheet, cell
     * @return
     */
    public static boolean isMergedRegion(XSSFSheet sheet, Cell cell) {
         // 하나를 얻기 sheet 중에 몇 개의 셀 병합
         int sheetmergerCount = sheet.getNumMergedRegions();
         for (int i = 0; i <sheetmergerCount; i++) {
             // 구체적인 병합 셀 수
             org.apache.poi.ss.util.CellRangeAddress ca = sheet.getMergedRegion(i);
             // 병합 작업 의 시작 돼, 얻은 끝 좋다, 시작 열, 끝 열
             int firstC = ca.getFirstColumn();
             int lastC = ca.getLastColumn();
             int firstR = ca.getFirstRow();
             int lastR = ca.getLastRow();
             // 이 있는지 여부를 판단할 셀 병합 작업 범위 안에 혹시 않으면 복귀 true
             if (cell.getColumnIndex() <= lastC && cell.getColumnIndex() >= firstC) {
                 if (cell.getRowIndex() <= lastR && cell.getRowIndex() >= firstR) {
                     return true;
                 }
             }
         }
         return false;
    }

    private static String getCellContent(Cell cell) {
                 return FORMATTER.formatCellValue(cell);
             }
    
    /**
     * 병합된 셀의 내용을 리턴
     * @param sheet, cell
     * @return
     */
    public static String getMergedRegionValue(XSSFSheet sheet, Cell cell) {
        int sheetmergerCount = sheet.getNumMergedRegions();
        for (int i = 0; i <sheetmergerCount; i++) {
            org.apache.poi.ss.util.CellRangeAddress ca = sheet.getMergedRegion(i);
            int firstC = ca.getFirstColumn();
            int firstR = ca.getFirstRow();
            
            if (cell.getColumnIndex() == firstC && cell.getRowIndex() == firstR) {
                return getCellContent(cell);
            }
        }
        return "";
    }
}
