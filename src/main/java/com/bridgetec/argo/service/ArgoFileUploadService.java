package com.bridgetec.argo.service;

import java.io.File;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

//import org.apache.log4j.Logger;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.bridgetec.argo.batch.util.DateUtil;
import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.common.MessageException;
import com.bridgetec.argo.common.util.ServerUtils;

import egovframework.com.cmm.service.Globals;
import egovframework.rte.fdl.cmmn.AbstractServiceImpl;
import egovframework.rte.fdl.string.EgovStringUtil;

@Service("argoFileUploadService")
public class ArgoFileUploadService extends AbstractServiceImpl {

    /* 파일명을 SaFileUploadServiceImpl로 할경우 Context-transaction.xml의 포인트컷정보에 의해
     * 트랜잭션 AOP의 대상이 됨. execution(* com.bridgetec..service.*Impl.*(..))
     * 이 서비스는 단순 파일 업로드 기능만 존재하므로 파일명을 Impl를 빼고 AOP 대상에 제외 되도록 함. 
     */
    
    private Logger            loMeLogger = LogManager.getLogger(ArgoFileUploadService.class);

    //@Resource(name = "propertiesService") 
    //protected EgovPropertyService propertiesService;
    
    /**
     * 파일을 업로드 한다.
     * @param request
     * @return List<String> 파일명리스트 
     * @throws Exception
     */
    public List<String> fileuplaod(HttpServletRequest request, Map<String, String> parm , HttpServletResponse response, String globalFilePath) throws Exception{
        
        /*for( String key : parm.keySet() ){
            if(EgovStringUtil.isNotEmpty(key))
                loMeLogger.debug("MAP => "+key+"="+(String)parm.get(key));
        }*/
        
        final MultipartHttpServletRequest multiRequest = (MultipartHttpServletRequest) request;

        // extract files
        final Map<String, MultipartFile> files = multiRequest.getFileMap();

        // process files
        //String uploadLastPath = pService.getString("file.upload.path");
        //String uploadPath = request.getSession().getServletContext().getRealPath("/") + uploadLastPath;
        String userSabun = EgovStringUtil.null2void((String)parm.get("glo_userSabun"));
        //String uploadPath = pService.getString("file.upload.path")+EgovStringUtil.null2void((String)parm.get("ip_MenuId"));
        
        //MODIFIED BY 2016-09-13 다운로드 권한 문제로 was 내 UPLOAD 폴더 생성으로 수정.
        //String uploadPath = Globals.UPLOAD_PATH()+EgovStringUtil.null2void((String)parm.get("ip_MenuId"));
        //String uploadPath = request.getSession().getServletContext().getRealPath("/") + Globals.UPLOAD_PATH()+EgovStringUtil.null2void((String)parm.get("ip_MenuId"));
        //String uploadPath = Globals.UPLOAD_PATH()+EgovStringUtil.null2void((String)parm.get("ip_MenuId"));
        
        // 2020.06.25 파일 동기화를 위해 불필요한 하위 경로 제거
        
//       String uploadPath = Globals.UPLOAD_PATH();
        
        //String uploadPath = Globals.UPLOAD_PATH() +  DateUtil.simpleGetCurrentDate("yyyyMMdd") + "/";
        String uploadPath = globalFilePath +  DateUtil.simpleGetCurrentDate("yyyyMMdd") + "/";
        
        
        loMeLogger.info("uploadPath>>>"+uploadPath);
        
        File saveFolder = new File(uploadPath);
        String fileName = null;
        List<String> result = new ArrayList<String>();
        
        try{
            // 디렉토리 생성
            boolean isDir = false;
            if (!saveFolder.exists() || saveFolder.isFile()) {
                loMeLogger.info("["+userSabun+"] 폴더생성 전 ["+saveFolder+"]");
                saveFolder.mkdirs();
                loMeLogger.info("["+userSabun+"] 폴더생성 완료 ["+saveFolder+"]");
            }

            if (!isDir) {

                Iterator<Entry<String, MultipartFile>> itr = files.entrySet().iterator();
                MultipartFile file;
                String filePath;
                
                while (itr.hasNext()) {

                    Entry<String, MultipartFile> entry = itr.next();
                    file = entry.getValue();
                    fileName = file.getOriginalFilename();
                    /*if(file.getSize() > 0){
                        throw new MessageException(new Exception(), Constant.RESULT_CODE_ERR_FILESIZE);
                    }*/
                    if (!"".equals(fileName)) {
                        // 파일 전송
                        filePath = uploadPath + "/" + fileName;
                        file.transferTo(new File(filePath));
                        
                        loMeLogger.info("["+userSabun+"] UPLOAD FILE ["+fileName+"] SIZE["+file.getSize()+"]");
                        result.add(fileName);
                    }          
                    
                    
//                    String chkExt = fileName.substring(fileName.lastIndexOf(".")+1);
//                    if(!chkExt.equals("doc") && !chkExt.equals("docx") && !chkExt.equals("txt") && !chkExt.equals("rtf") && !chkExt.equals("pdf") &&
//                       !chkExt.equals("ppt") && !chkExt.equals("pptx") && !chkExt.equals("xls") && !chkExt.equals("hwp") && !chkExt.equals("png") &&
//                       !chkExt.equals("gif") && !chkExt.equals("bmp") && !chkExt.equals("gif") && !chkExt.equals("jpeg") && !chkExt.equals("jpg")) 
//                    {
//                    	System.out.println("업로드 시작");
//                    	response.setContentType("text/html;charset=euc-kr");
//                    	PrintWriter out = response.getWriter();
//                    	out.println("<script>argoAlert('확장자를 확인해 주세요. 허용 확장자 : .hwp, .doc , .docx , .txt , .rtf , .pdf ,"
//                    			+ ".ppt , .pptx , .xls , .hwp , .png , .gif , .bmp , .gif , .jpeg , .jpg");
//                    	out.flush();
//                    	System.out.println("alert완료");
//                    
//                    }
//                    else {
//                        if (!"".equals(fileName)) {
//                        	
//                            // 파일 전송
//                            filePath = uploadPath + "/" + fileName;
//                            file.transferTo(new File(filePath));
//                            
//                            
//                            loMeLogger.info("["+userSabun+"] UPLOAD FILE ["+fileName+"] SIZE["+file.getSize()+"]");
//                            result.add(fileName);
//                            
//                        }                    	
//                    }

                }
            }
            
            return result;
            
        }catch(Exception e){
            loMeLogger.error("["+userSabun+"] FILE UPLOAD EXCEPTION 발생 ["+e.toString()+"]");
            throw new MessageException(e, Constant.RESULT_CODE_ERR_UPLOAD); 
        }

    }


    
}
