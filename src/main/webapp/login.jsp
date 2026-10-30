<%-- 
    Document   : login
    Created on : 26 Sept 2026, 10:44:56 pm
    Author     : shrey
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Checkmate — Login</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,wght@0,600;1,500&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="auth-wrapper">
    <div class="auth-card">
        <h1 class="wordmark-lg">checkmate</h1>
        <p class="subtitle">Automated check-in & alert system</p>

        <% if (request.getParameter("registered") != null) { %>
            <div class="alert alert-success">Registration successful. Please log in.</div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>

        <form action="login" method="post" class="form">
            <label>Email</label>
            <input type="email" name="email" required placeholder="you@example.com">

            <label>Password</label>
            <input type="password" name="password" required placeholder="********">

            <button type="submit" class="btn-primary">Log In</button>
        </form>

        <p class="switch-link">New here? <a href="register.jsp">Create an account</a></p>
    </div>
</div>
</body>
</html>