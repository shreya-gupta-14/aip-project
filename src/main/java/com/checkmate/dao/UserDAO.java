/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.checkmate.dao;
import java.util.UUID;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class UserDAO {

    /** Registers a new user + their emergency contact in one transaction. */
    public boolean registerUser(String name, String email, String password, int intervalHours,
                                 String contactName, String contactEmail) {

        String insertUser = "INSERT INTO users (name, email, password, checkin_interval_hours, share_token) VALUES (?, ?, ?, ?, ?)";
        String insertContact = "INSERT INTO emergency_contacts (user_id, contact_name, contact_email) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(insertUser, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, name);
                ps.setString(2, email);
                ps.setString(3, password);
                ps.setInt(4, intervalHours);
                ps.setString(5, UUID.randomUUID().toString()); // random private link code

                ps.executeUpdate();

                int userId;
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) throw new SQLException("Could not retrieve new user id.");
                    userId = keys.getInt(1);
                }

                try (PreparedStatement ps2 = conn.prepareStatement(insertContact)) {
                    ps2.setInt(1, userId);
                    ps2.setString(2, contactName);
                    ps2.setString(3, contactEmail);
                    ps2.executeUpdate();
                }
                try (PreparedStatement ps3 = conn.prepareStatement(
                    "INSERT INTO checkins (user_id, checkin_time) VALUES (?, NOW())")) {
                    ps3.setInt(1, userId);
                    ps3.executeUpdate();
                }
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Returns the user_id if credentials match, otherwise null. */
    public Integer validateLogin(String email, String password) {
        String sql = "SELECT user_id FROM users WHERE email = ? AND password = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("user_id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public String getUserName(int userId) {
        String sql 
                
                = "SELECT name FROM users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("name");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "User";
    }
        public String getShareToken(int userId) {
        String sql = "SELECT share_token FROM users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("share_token");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Used by the public status page: turns a link code back into a user id (or null if invalid). */
    public Integer getUserIdByToken(String token) {
        String sql = "SELECT user_id FROM users WHERE share_token = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("user_id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public int getCheckinInterval(int userId) {
        String sql = "SELECT checkin_interval_hours FROM users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("checkin_interval_hours");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 48;
    }
}