package com.bridgetec.common;

import java.sql.Connection;
import java.sql.SQLException;

import javax.sql.DataSource;

import org.apache.commons.dbcp.BasicDataSource;

public class SecurityDBCPBasicDataSource extends BasicDataSource {

    @Override
    public void setUsername(String username) {
        try {
            super.setUsername(SecurityUtil.AESDecrypyt(username, null));
        } catch (IllegalArgumentException iae) {
            System.out.println("Exception : " + iae.toString());
        } catch (Exception e) {
        	System.out.println("Exception : " + e.toString());
        }
    }

    @Override
    public void setPassword(String password) {
        try {
            super.setPassword(SecurityUtil.AESDecrypyt(password, null));
        } catch (IllegalArgumentException iae) {
            System.out.println("Exception : " + iae.toString());
        } catch (Exception e) {
        	System.out.println("Exception : " + e.toString());
        }
    }

    
    public void saveUsername(String username) {
        SortProperties.setProperty("Globals.Oracle.Account", username, true, null);
        super.setUsername(username);
    }

    public void savePassword(String password) {
        SortProperties.setProperty("Globals.Oracle.Password", password, true, null);
        super.setPassword(password);
    }
    
    
    public void setUsernameText(String username) {
        super.setUsername(username);
    }
    
    public void setPasswordText(String password) {
        super.setPassword(password);
    }    
    
    private DataSource dataSourceFromJNDI;

    public void setDataSourceFromJNDI(DataSource dataSourceFromJNDI) {
        this.dataSourceFromJNDI = dataSourceFromJNDI;
    }
    
    @Override
    public Connection getConnection() throws SQLException {
        if (dataSourceFromJNDI != null) {
            return dataSourceFromJNDI.getConnection();
        }
        return super.getConnection();
    }

    
}
