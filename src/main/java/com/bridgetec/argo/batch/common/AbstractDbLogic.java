package com.bridgetec.argo.batch.common;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.List;

//import org.apache.log4j.Logger;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;



import com.bridgetec.argo.batch.util.DBManager;
import com.bridgetec.argo.batch.util.PropManager;
import com.bridgetec.argo.common.ConnextionDBInfo;

import egovframework.com.cmm.service.EgovProperties;

/**
 * =======================================================
 * 설명 : 저장 및 기타DB 접속용 공통처리
 * =======================================================
 */
public abstract class AbstractDbLogic extends ConnextionDBInfo{
	private static final Logger logger = LogManager.getLogger(AbstractDbLogic.class);
	
	public void setBatchLog(String tenantId, String schNo, String schSeq, long batchTime, long workStart, long workEnd, String workId, String result, String count, String bigo) throws Exception, SQLException {
		Connection conn = null;
		CallableStatement cstmt = null;		
		
		long nCount = 0;
		String strBigo = bigo ;
		
		try {
			
			if(isNumber(count)==true) {
				nCount = Integer.parseInt(count) ;
			} else {
				strBigo = count ;
			}
			
			conn =  DBManager.getArgoDbConn();
			cstmt = conn.prepareCall(PropManager.getDBStrValue( "SP_INSET_LOG_BATCH"));

			cstmt.setString(1, tenantId); // in_sch_No
			cstmt.setString(2, schNo); // in_sch_No
			cstmt.setString(3, schSeq); // in_sch_Seq
			cstmt.setTimestamp(4, new Timestamp(batchTime));
			cstmt.setTimestamp(5, new Timestamp(workStart));
			cstmt.setTimestamp(6, new Timestamp(workEnd)); 
			cstmt.setString(7, workId); // in_work_id
			cstmt.setString(8, result); // in_work_result
			cstmt.setLong(9, nCount); // in_work_count
			cstmt.setString(10, strBigo); // in_work_bigo
			cstmt.execute();
		} catch (ClassNotFoundException e) {
			errorHandle(e, conn);
		} finally {
			close(cstmt, conn);
		}
	}
	
	
	protected int typeCheck(List<? extends Object[]> paramList) {
		if (paramList != null && paramList.size() > 0) {
			Object[] params = paramList.get(0); // 처리 성능 및 복잡도를 줄이기 위해 params의 0번지 데이터가 반드시 존재한다고 전제함
			if (params[0] instanceof String) {
				return 1;
			}
		}
		return 0;
	}

/**
 * SQL처리 중 발생한 에러처리
 * @param e
 * @param conn
 * @throws Exception 
 */
protected void errorHandle(Exception e, Connection ... conns) throws Exception {
	if (e instanceof ClassNotFoundException) {
		logger.error("DB처리 중 예외가 발생하였습니다. (SQL드라이버 관련오류)", e);
	} else if (e instanceof SQLException) {
		logger.error("DB처리 중 예외가 발생하였습니다. (SQL실행오류)", e);
		if (conns != null) {
			for (Connection conn : conns) {
				rollback(conn);
			}
		}
	}
	throw e;
}

/**
 * 롤백을 위한 공통처리
 * @param conn
 */
protected void rollback(Connection conn) {
	try {
		if (conn != null) conn.rollback();
	} catch (SQLException e1) {
		logger.error("롤백 처리중 예외가 발생하였습니다.", e1);
	}
}

/**
 * PreparedStatement 및 Connection Close를 위한 공통처리
 * @param pstmt
 * @param conn
 */
protected void close(PreparedStatement pstmt, Connection conn) {
	close(pstmt, conn, null);
}

/**
 * PreparedStatement 및 Connection Close를 위한 공통처리
 * pstmt 복수건 처리가능
 * @param pstmts 
 * @param conn
 */
protected void close(Connection conn, PreparedStatement ... pstmts) {
	try {
		for (PreparedStatement pstmt : pstmts) {
			if (pstmt != null) pstmt.close();
		}
		if (conn != null) conn.close();
	} catch (SQLException e) {
		logger.error("PreparedStatement 혹은 Connection Close처리중 예외가 발생하였습니다.", e);
	}
}
	
/**
 * PreparedStatement 및 ResultSet, Connection Close를 위한 공통처리
 * @param pstmt
 * @param conn
 * @param rs
 */
protected void close(PreparedStatement pstmt, Connection conn, ResultSet rs) {
	try {
		if (rs != null) rs.close();
		if (pstmt != null) pstmt.close();
		if (conn != null) conn.close();
	} catch (SQLException e) {
		logger.error("PreparedStatement 혹은 Connection Close처리중 예외가 발생하였습니다.", e);
	}
}

public void close (    Connection conn    )                                   // Connection 객체
{
    if (conn != null){
        try{
            conn.close();
        }catch (SQLException sqle){
        }
    }
}

public void close (    Statement stmt )                                       // Statement 객체
{
    if (stmt != null){
        try{
            stmt.close();
        }catch (SQLException sqle){
        }
    }
}

public void close (    ResultSet rs   )                                       // ResultSet 객체
{
    if (rs != null){
        try{
            rs.close();
        }catch (SQLException sqle){
        }
    }
}

public static boolean isNumber(String str){
    boolean result = false;         
     
    try{
        Double.parseDouble(str) ;
        result = true ;
    }catch(Exception e){
    	
    }
     
     
    return result ;
}
}
