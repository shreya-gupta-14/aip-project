package com.checkmate.servlet;

import com.checkmate.dao.AlertDAO;
import com.checkmate.dao.CheckinDAO;
import com.checkmate.dao.UserDAO;
import java.io.IOException;
import java.sql.Timestamp;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Public page for the emergency contact. No login needed: the secret
 * token in the link is what identifies the user.
 */
@WebServlet("/status")
public class StatusServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("t");
        UserDAO userDAO = new UserDAO();
        Integer userId = (token == null) ? null : userDAO.getUserIdByToken(token);

        if (userId == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "This status link is not valid.");
            return;
        }

        CheckinDAO checkinDAO = new CheckinDAO();
        AlertDAO alertDAO = new AlertDAO();

        Timestamp lastCheckin = checkinDAO.getLastCheckin(userId);
        int interval = userDAO.getCheckinInterval(userId);

        // same overdue check as the dashboard: opening this page can raise the alert
        boolean overdue = alertDAO.checkAndRaiseAlert(userId, lastCheckin, interval);

        request.setAttribute("name", userDAO.getUserName(userId));
        request.setAttribute("lastCheckin", lastCheckin);
        request.setAttribute("overdue", overdue);
        request.setAttribute("location", checkinDAO.getLastLocation(userId));
        request.setAttribute("interval", interval);

        request.getRequestDispatcher("status.jsp").forward(request, response);
    }
}