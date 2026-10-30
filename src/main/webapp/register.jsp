<%-- 
    Document   : register
    Created on : 26 Sept 2026, 10:45:36 pm
    Author     : shrey
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Checkmate — Register</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,wght@0,600;1,500&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="auth-wrapper">
    <div class="auth-card">
        <h1 class="wordmark-lg">checkmate</h1>
        <p class="subtitle">Create your account</p>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("error") %></div>
        <% } %>

        <form action="register" method="post" class="form">
            <label>Full Name</label>
            <input type="text" name="name" required placeholder="Your name">

            <label>Email</label>
            <input type="email" name="email" required placeholder="you@example.com">

            <label>Password</label>
            <input type="password" name="password" required placeholder="Choose a password">

            <label>Check-in interval (hours)</label>
            <input type="number" name="interval" required value="48" min="1">

            <label>Emergency contact name</label>
            <input type="text" name="contactName" required placeholder="Who should be alerted">

            <label>Emergency contact email</label>
            <input type="email" name="contactEmail" required placeholder="their-email@example.com">

            <button type="submit" class="btn-primary">Create Account</button>
        </form>

        <p class="switch-link">Already registered? <a href="login.jsp">Log in</a></p>
    </div>
</div>
</body>
</html>
