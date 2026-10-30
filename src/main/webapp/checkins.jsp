<%@ page contentType="text/html;charset=UTF-8" language="java"
    import="java.sql.Timestamp, java.util.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Checkmate — Check-in History</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,wght@0,600;1,500&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%
    List<Timestamp> checkins = (List<Timestamp>) request.getAttribute("checkins");
    String userName = (String) session.getAttribute("userName");
    SimpleDateFormat fmt = new SimpleDateFormat("MMM d, yyyy, h:mm a");
%>
<div class="topbar">
    <div class="wordmark">checkmate</div>
    <div class="topbar-right"><%= userName %> &middot; <a href="logout">sign out</a></div>
</div>

<div class="page">

    <a href="dashboard" class="back-link">&larr; back to dashboard</a>

    <section class="history" style="margin-top: 16px;">
        <h2>All check-ins</h2>
        <% if (checkins == null || checkins.isEmpty()) { %>
            <p class="muted">No check-ins recorded yet.</p>
        <% } else { %>
            <table>
                <thead>
                <tr><th>#</th><th>Checked in at</th></tr>
                </thead>
                <tbody>
                <% int n = checkins.size();
                   for (Timestamp t : checkins) { %>
                <tr>
                    <td class="muted"><%= n-- %></td>
                    <td><%= fmt.format(t) %></td>
                </tr>
                <% } %>
                </tbody>
            </table>
        <% } %>
    </section>

</div>
</body>
</html>