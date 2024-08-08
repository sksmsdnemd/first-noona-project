package com.bridgetec.argo.common.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.context.support.WebApplicationContextUtils;

import com.bridgetec.argo.common.Constant;

public class HttpUtil {

    
    private static final Logger log  = LoggerFactory.getLogger(HttpUtil.class);
    
    
    public static boolean isAjax(HttpServletRequest request) throws Exception {

        String sXRequestWith, sOrigin;

        sXRequestWith = request.getHeader("X-Requested-With");
        sOrigin = request.getHeader("ORIGIN");

        if ((sXRequestWith != null && sXRequestWith.toLowerCase().equals("xmlhttprequest") == true) || sOrigin != null)
            return true;

        return false;

    }
    
    public static boolean sendMessage(HttpServletRequest request, HttpServletResponse response, String sMessage, String sResultCode, String sJsonString) {

        PrintWriter writer;
        String sSendMessage, sContentType;
        boolean bResult;

        sSendMessage = null;

        try {

            sContentType = request.getContentType() == null ? "" : request.getContentType();

            if (sMessage != null)
                sMessage = sMessage.replaceAll("'", "\'");

            if (HttpUtil.isAjax(request) == true || (sContentType != null && (sContentType.toLowerCase().indexOf("multipart/form-data") >= 0) || sContentType.toLowerCase().indexOf("application/json") >= 0)) {
                if (sResultCode == null) {
                    if (sMessage != null && sMessage.equals("") == false) {
                        sSendMessage = "{'message':'" + sMessage + "'";
                        if (sJsonString != null && sJsonString.equals("") == false) {
                            sSendMessage = sSendMessage + "," + sJsonString + "}";
                        }
                    } else {
                        if (sJsonString != null && sJsonString.equals("") == false) {
                            sSendMessage = "{" + sJsonString + "}";
                        }
                    }
                } else {
                    sSendMessage = "{";
                    if (sResultCode.equals("0000") == true) {
                        sSendMessage = sSendMessage + "'result':'success','resultCode':'0000'";
                        if (sMessage != null && sMessage.equals("") == false) {
                            sSendMessage = sSendMessage + ",'message':'" + sMessage + "'";
                        }
                    } else {
                        sSendMessage = sSendMessage + "'result':'failure','resultCode':'" + sResultCode + "'";
                        if (sMessage != null && sMessage.equals("") == false) {
                            sSendMessage = sSendMessage + ",'message':'" + sMessage + "'";
                        } else {
                            sSendMessage = sSendMessage + ",'message':'서버에서 알수 없는 오류가 발생하였습니다.'";
                        }
                    }
                    if (sJsonString != null && sJsonString.equals("") == false)
                        sSendMessage = sSendMessage + "," + sJsonString.replaceAll("\"", "'");
                    sSendMessage = sSendMessage + "}";
                }

            } else {
                sSendMessage = "<script>alert('" + sMessage + "');history.back();</script>";
            }

            if (sSendMessage != null) {
                response.setContentType("text/html; charset=UTF-8");

                writer = response.getWriter();
                writer.write(sSendMessage);
                writer.flush();
                writer.close();
            }

            bResult = true;

        } catch (IOException ie) {
        	bResult = false;
        	log.info(ie.toString());
        } catch (Exception e) {
            bResult = false;
            log.info(e.toString());
        }

        return bResult;

    }

    public static void sendText(HttpServletResponse response, String sString) throws Exception {

        PrintWriter writer;

        response.setContentType("text/html; charset=UTF-8");

        writer = response.getWriter();
        writer.write(sString);
        writer.flush();
        writer.close();

    }

    public static void sendScript(HttpServletResponse response, String sScript) throws Exception {

        PrintWriter writer;

        response.setContentType("text/html; charset=UTF-8");

        writer = response.getWriter();
        writer.write("<script>" + sScript + "</script>");
        writer.flush();
        writer.close();

    }

    public static void sendJson(HttpServletResponse response, String sJsonString) throws Exception {

        PrintWriter writer;

        response.setContentType("text/html; charset=UTF-8");

        writer = response.getWriter();
        writer.write("{" + sJsonString.replaceAll("\"", "'") + "}");
        writer.flush();
        writer.close();

    }    
    
    public static Object getService(ServletContext context, String sService) throws Exception {

        Object oService;

        oService = WebApplicationContextUtils.getRequiredWebApplicationContext(context).getBean(sService);

        return oService;

    }


    public static String getProgramNo(HttpServletRequest request) throws Exception {

        String sResult, jaPath[];

        // /BT-EMS/login.do
        jaPath = request.getRequestURI().split("/");
        if (jaPath.length >= 5 && jaPath[1].equals(Constant.getRootPath().replaceAll("/", "")) == true && jaPath[2].indexOf("ipr") == 0 && jaPath[3].indexOf("p") == 0 && jaPath[4].indexOf("IPR") == 0) {
            sResult = jaPath[jaPath.length - 1].replace(".do", "");
        } else {
            sResult = "";
        }

        return sResult;

    }    
    


    public static String specialToCode(String sString) {

        String sResult;

        if (sString == null)
            return null;

        sResult = sString.replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("&", "&amp;").replaceAll("\"", "&#34;").replaceAll("'", "&#39;").replaceAll(":", "&#58;");

        return sResult;

    }



    public static String codeToSpecial(String sString) {

        String sResult;

        if (sString == null)
            return null;

        sResult = sString.replaceAll("&lt;", "<").replaceAll("&gt;", ">").replaceAll("&amp;", "&").replaceAll("&#34;", "\"").replaceAll("&#39;", "'").replaceAll("&#58;", ":");

        return sResult;

    }


    // upload 시 발생한 임시화일과 upload 화일을 지우는 함수
    // @sFileUploadPath : 지워야할 file 이 있는 정대 경로
    // @pliFileNameList : FileItem이 들어있는 ArrayList
    @SuppressWarnings("unused")
    private static void deleteUploadFile(String sFileUploadPath, List<FileItem> liFileNameList) throws Exception {

        FileItem fiFileItem;
        Iterator<FileItem> itFileItem;
        File fiDelete;

        if (liFileNameList == null)
            return;

        itFileItem = liFileNameList.iterator();
        while (itFileItem.hasNext() == true) {
            fiFileItem = (FileItem) itFileItem.next();

            if (fiFileItem.getName() == null)
                continue;
            //
            fiFileItem.delete();

            fiDelete = new File(sFileUploadPath, fiFileItem.getName());
            if (fiDelete.exists() == true)
                fiDelete.delete();
        }
    }

 
    public static void splitKeyValuePair(String menuStatCategoryString, Map<String, String> map) {
        for (String pair : menuStatCategoryString.split("\"[\\s]")) {
            String[] parts = pair.split("=");
            if (parts.length < 2)
                continue;
            if (parts[0].length() == 0)
                continue;
            // 아래 문자는 웹 ajax 통신시 문제 됨
            String value = StringUtils.remove(parts[1], '\"');
            value = StringUtils.remove(value, ':');
            value = StringUtils.remove(value, '\'');
            value = StringUtils.remove(value, '(');
            value = StringUtils.remove(value, ')');
            value = StringUtils.remove(value, '{');
            value = StringUtils.remove(value, '}');
            value = StringUtils.remove(value, '[');
            value = StringUtils.remove(value, ']');
            
            map.put(StringUtils.lowerCase(parts[0]), value);
        }
    }

    //
    public static String getFileString(String fileName, String encType) throws Exception {
        String returnValue = "";
        File inFile = null;
        BufferedReader inBuffer = null;
        char[] sContents = null;

        try {
            //
            fileName = fileName.replaceAll("\\\\", "/");
            if (encType == null || encType.isEmpty())
                encType = getFileEncodingType(fileName);
            //
            inFile = new File(fileName);
            //
            if (!inFile.exists() || !inFile.isFile() || inFile.length() <= 0) {
                throw new Exception("File can not be found or an error occurred.");
            }

            inBuffer = new BufferedReader(new InputStreamReader(new FileInputStream(inFile), encType));
            sContents = new char[(int) inFile.length()];
            inBuffer.read(sContents);
            returnValue = new String(sContents);

        } catch (IOException ie) {
        	log.error("IOException : " + ie.toString());
        } catch (Exception e) {
        	log.error("Exception : " + e.toString());
//        	throw e;
        } finally {
            if (inBuffer != null)
                inBuffer.close();
            if (inFile != null)
                inFile = null;
        }

        return returnValue;
    }

    public static String getFileEncodingType(String fileName) throws Exception {
        String returnValue = "euc-kr";
        FileInputStream fis = null;
        byte[] BOM = null;

        try {
            if (fileName == "")
                throw new Exception("There is no file name.");

            // 1. 파일 열기
            fis = new FileInputStream(fileName);

            // 2. 파일 읽기 (4Byte)
            BOM = new byte[4];

            fis.read(BOM, 0, 4);

            // 3. 파일 인코딩 확인하기
            if ((BOM[0] & 0xFF) == 0xEF && (BOM[1] & 0xFF) == 0xBB && (BOM[2] & 0xFF) == 0xBF)
                returnValue = "utf-8";
            else if ((BOM[0] & 0xFF) == 0xFE && (BOM[1] & 0xFF) == 0xFF)
                returnValue = "utf-16be";
            else if ((BOM[0] & 0xFF) == 0xFF && (BOM[1] & 0xFF) == 0xFE)
                returnValue = "utf-16le";
            else if ((BOM[0] & 0xFF) == 0x00 && (BOM[1] & 0xFF) == 0x00 && (BOM[0] & 0xFF) == 0xFE && (BOM[1] & 0xFF) == 0xFF)
                returnValue = "utf-32be";
            else if ((BOM[0] & 0xFF) == 0xFF && (BOM[1] & 0xFF) == 0xFE && (BOM[0] & 0xFF) == 0x00 && (BOM[1] & 0xFF) == 0x00)
                returnValue = "utf-32le";
            else
                returnValue = "euc-kr";
        } catch (IOException ie) {
            returnValue = "";
        } catch (Exception e) {
        	returnValue = "";
        } finally {
            if (fis != null)
                fis.close();
        }

        return returnValue;
    }

    // pad with " " to the right to the given length (n)
    public static String padRight(String s, int n) {
        return String.format("%1$-" + n + "s", s);
    }

    // pad with " " to the left to the given length (n)
    public static String padLeft(String s, int n) {
        return String.format("%1$" + n + "s", s);
    }
    
    public static String filter(String value) {
		if (value == null) {
			return null;
		}
		StringBuffer result = new StringBuffer(value.length());
		for (int i = 0; i < value.length(); ++i) {
			switch (value.charAt(i)) {
			case '<':
				result.append("&lt;");
				break;
			case '>':
				result.append("&gt;");
				break;
			case '"':
				result.append("&quot;");
				break;
			case '\'':
				result.append("&#39;");
				break;
			case '%':
				result.append("&#37;");
				break;
			case ';':
				result.append("&#59;");
				break;
			case '(':
				result.append("&#40;");
				break;
			case ')':
				result.append("&#41;");
				break;
			case '&':
				result.append("&amp;");
				break;
			case '+':
				result.append("&#43;");
				break;
			default:
				result.append(value.charAt(i));
				break;
			}
		}
		return result.toString();
	}
}