<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
// Backend Logic for Registration
String message = "";
String messageType = "";

if(request.getMethod().equalsIgnoreCase("POST")) {
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirmPassword");
    
    // Backend Validation
    if(name == null || name.trim().isEmpty()) {
        message = "Name is required!";
        messageType = "danger";
    } else if(email == null || email.trim().isEmpty()) {
        message = "Email is required!";
        messageType = "danger";
    } else if(!email.toLowerCase().endsWith("@gmail.com")) {
        message = "Only Gmail IDs (@gmail.com) are allowed!";
        messageType = "danger";
    } else if(password == null || password.length() < 6) {
        message = "Password must be at least 6 characters!";
        messageType = "danger";
    } else if(!password.equals(confirmPassword)) {
        message = "Passwords do not match!";
        messageType = "danger";
    } 
    else {
        // Check if email already exists
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:XE", "system", "sohan1");
            
            // Check duplicate email
            String checkSql = "SELECT * FROM users2 WHERE email = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, email.toLowerCase());
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                message = "Email already registered! Please use a different Gmail ID.";
                messageType = "warning";
            } else {
                // Insert new user
                rs.close();
                pstmt.close();
                
                String insertSql = "INSERT INTO users2 (name, email, password, role) VALUES (?, ?, ?, 'user')";
                pstmt = conn.prepareStatement(insertSql);
                pstmt.setString(1, name);
                pstmt.setString(2, email.toLowerCase());
                pstmt.setString(3, password);
                
                int result = pstmt.executeUpdate();
                
                if(result > 0) {
                    message = "Registration successful! You can now login.";
                    messageType = "success";
                } else {
                    message = "Registration failed! Please try again.";
                    messageType = "danger";
                }
            }
        } catch(Exception e) {
            message = "Error: " + e.getMessage();
            messageType = "danger";
            e.printStackTrace();
        } finally {
            if(rs != null) try { rs.close(); } catch(Exception e) {}
            if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if(conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .register-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 40px;
            max-width: 500px;
            width: 100%;
        }
    </style>
</head>
<body>
    <div class="register-card">
        <h2 class="text-center mb-4">
            <i class="fas fa-user-plus text-primary"></i> Register
        </h2>
        
        <% if(!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
                <%= message %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
        
        <form method="POST" action="register.jsp">
            <div class="mb-3">
                <label class="form-label"><i class="fas fa-user"></i> Full Name</label>
                <input type="text" class="form-control" name="name" required>
            </div>
            
            <div class="mb-3">
                <label class="form-label"><i class="fas fa-envelope"></i> Email (Gmail only)</label>
                <input type="email" class="form-control" name="email" placeholder="example@gmail.com" required>
                <small class="text-muted">Only @gmail.com addresses are allowed</small>
            </div>
            
            <div class="mb-3">
                <label class="form-label"><i class="fas fa-lock"></i> Password</label>
                <input type="password" class="form-control" name="password" minlength="6" required>
                <small class="text-muted">Minimum 6 characters</small>
            </div>
            
            <div class="mb-3">
                <label class="form-label"><i class="fas fa-lock"></i> Confirm Password</label>
                <input type="password" class="form-control" name="confirmPassword" required>
            </div>
            
            <button type="submit" class="btn btn-primary w-100">
                <i class="fas fa-user-plus"></i> Register
            </button>
        </form>
        
        <hr>
        <div class="text-center">
            <p>Already have an account? <a href="login.jsp">Login here</a></p>
            <a href="index.jsp" class="text-muted">
                <i class="fas fa-home"></i> Back to Home
            </a>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>