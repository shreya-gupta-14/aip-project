/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.checkmate.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
private static final String URL = "jdbc:mysql://localhost:3306/checkmate_db?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String USER = "root";              
    private static final String PASSWORD = "shreya@gupta14"; 

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found. Check pom.xml dependency.", e);
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}