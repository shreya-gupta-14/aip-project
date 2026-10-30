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
import jakarta.servlet.http.HttpSession;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");

        UserDAO userDAO = new UserDAO();
        CheckinDAO checkinDAO = new CheckinDAO();
        AlertDAO alertDAO = new AlertDAO();

        Timestamp lastCheckin = checkinDAO.getLastCheckin(userId);
        int interval = userDAO.getCheckinInterval(userId);

        boolean overdue = alertDAO.checkAndRaiseAlert(userId, lastCheckin, interval);

        request.setAttribute("lastCheckin", lastCheckin);
        request.setAttribute("interval", interval);
        request.setAttribute("overdue", overdue);
        request.setAttribute("alerts", alertDAO.getAlertHistory(userId));
        request.setAttribute("location", checkinDAO.getLastLocation(userId));
        request.setAttribute("shareToken", userDAO.getShareToken(userId));

        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }
}