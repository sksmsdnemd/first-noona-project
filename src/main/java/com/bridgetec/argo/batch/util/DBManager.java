package com.bridgetec.argo.batch.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

import com.bridgetec.common.SecurityUtil;
import com.tmax.tibero.jdbc.TbDriver;

import egovframework.com.cmm.service.EgovProperties;

/**
 * =======================================================
 * 설명 : DB접속 처리용 유틸
 * =======================================================
 */
public class DBManager {
	public static Connection getArgoDbConn() throws SQLException, ClassNotFoundException,Exception {
		return getConn(
				EgovProperties.getProperty("Globals.ARGO.RDB.Driver"),
				EgovProperties.getProperty("Globals.ARGO.RDB.Url"),
				EgovProperties.getProperty("Globals.ARGO.RDB.Account"),
				EgovProperties.getProperty("Globals.ARGO.RDB.Password"));
	}
	
	public static Connection getConn(String drvName, String jdbcPath, String user, String pw) throws SQLException, ClassNotFoundException,Exception {
		Connection conn = null;
		Class.forName(drvName);
		conn = DriverManager.getConnection(jdbcPath, SecurityUtil.AESDecrypyt(user,null), SecurityUtil.AESDecrypyt(pw,null));
		
		// JNDI 컨텍스트 설정
//	    Context ctx = new InitialContext();
//	    String jndiName = EgovProperties.getProperty("Globals.ARGO.RDB.JndName");
//	    DataSource dataSource = (DataSource) ctx.lookup(jndiName);
//	    Connection conn = null;
//	    conn = dataSource.getConnection();
		
		return conn;
	}	

}
