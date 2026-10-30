package com.checkmate.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AlertDAO {

    /**
     * The core "Checkmate" logic. Runs every time the dashboard loads (the "lazy check").
     * Compares now() against the user's last check-in + their allowed interval.
     * If they're overdue and don't already have a pending alert, raises one.
     * Returns true if the user is currently overdue.
     */
    public boolean checkAndRaiseAlert(int userId, Timestamp lastCheckin, int intervalHours) {
        boolean overdue;

        if (lastCheckin == null) {
            overdue = true; // never checked in at all
        } else {
            long diffMillis = System.currentTimeMillis() - lastCheckin.getTime();
            long diffHours = diffMillis / (1000 * 60 * 60);
            overdue = diffHours >= intervalHours;
        }

        if (overdue && !hasPendingAlert(userId)) {
            String sql = "INSERT INTO alerts (user_id, triggered_time, status, message) "
                       + "VALUES (?, NOW(), 'PENDING', 'Missed scheduled check-in')";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return overdue;
    }

    private boolean hasPendingAlert(int userId) {
        String sql = "SELECT COUNT(*) FROM alerts WHERE user_id = ? AND status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Called whenever the user checks in again — clears any pending alert on their account. */
    public void resolveAlerts(int userId) {
        String sql = "UPDATE alerts SET status = 'RESOLVED' WHERE user_id = ? AND status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Map<String, String>> getAlertHistory(int userId) {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT triggered_time, status, message FROM alerts WHERE user_id = ? ORDER BY triggered_time DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> row = new HashMap<>();
                    row.put("time", rs.getTimestamp("triggered_time").toString());
                    row.put("status", rs.getString("status"));
                    row.put("message", rs.getString("message"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}