package com.bridgetec.argo.common;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ConnextionDBInfo {
private static final Logger logger = LoggerFactory.getLogger(ConnextionDBInfo.class);
	
 public static Connection getConn(
			String drvName, String jdbcPath, String user, String pw) throws SQLException, ClassNotFoundException {
		Connection conn = null;
		Class.forName(drvName);
		conn = DriverManager.getConnection(jdbcPath, user, pw);
		return conn;
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
}
