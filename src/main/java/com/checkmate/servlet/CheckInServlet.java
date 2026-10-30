package com.checkmate.servlet;

import com.checkmate.dao.AlertDAO;
import com.checkmate.dao.CheckinDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/checkin")
public class CheckInServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        // location is optional: the browser sends it only if the user allowed it
        Double lat = null, lng = null;
        try {
            String latStr = request.getParameter("lat");
            String lngStr = request.getParameter("lng");
            if (latStr != null && !latStr.isEmpty() && lngStr != null && !lngStr.isEmpty()) {
                lat = Double.parseDouble(latStr);
                lng = Double.parseDouble(lngStr);
                // sanity check: real coordinates only
                if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
                    lat = null;
                    lng = null;
                }
            }
        } catch (NumberFormatException e) {
            lat = null;
            lng = null;
        }

        new CheckinDAO().recordCheckin(userId, lat, lng);
        new AlertDAO().resolveAlerts(userId);

        response.sendRedirect("dashboard?checked=true");
    }
}