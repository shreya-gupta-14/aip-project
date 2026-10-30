package com.checkmate.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class CheckinDAO {

    /** Saves a check-in. lat/lng can be null if the user didn't share location. */
    public void recordCheckin(int userId, Double lat, Double lng) {
        String sql = "INSERT INTO checkins (user_id, checkin_time, latitude, longitude) VALUES (?, NOW(), ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            if (lat == null || lng == null) {
                ps.setNull(2, Types.DOUBLE);
                ps.setNull(3, Types.DOUBLE);
            } else {
                ps.setDouble(2, lat);
                ps.setDouble(3, lng);
            }
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public Timestamp getLastCheckin(int userId) {
        String sql = "SELECT MAX(checkin_time) AS last_time FROM checkins WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getTimestamp("last_time");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Timestamp> getCheckinHistory(int userId) {
        List<Timestamp> list = new ArrayList<>();
        String sql = "SELECT checkin_time FROM checkins WHERE user_id = ? ORDER BY checkin_time DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getTimestamp("checkin_time"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Returns {latitude, longitude} from the most recent check-in that shared a location, or null. */
    public double[] getLastLocation(int userId) {
        String sql = "SELECT latitude, longitude FROM checkins "
                   + "WHERE user_id = ? AND latitude IS NOT NULL "
                   + "ORDER BY checkin_time DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new double[]{rs.getDouble("latitude"), rs.getDouble("longitude")};
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}