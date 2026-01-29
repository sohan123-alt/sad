<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
// Backend Login Logic
String message = "";
String messageType = "";

if(request.getMethod().equalsIgnoreCase("POST")) {
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    
    // Backend Validation
    if(email == null || email.trim().isEmpty()) {
        message = "Email is required!";
        messageType = "danger";
    } else if(password == null || password.trim().isEmpty()) {
        message = "Password is required!";
        messageType = "danger";
    } else if(!email.toLowerCase().endsWith("@gmail.com")) {
        message = "Only Gmail IDs are allowed!";
        messageType = "danger";
    } else {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "sohan1");
            
            String sql = "SELECT * FROM users2 WHERE email = ? AND password = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email.toLowerCase());
            pstmt.setString(2, password);
            
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                // Login successful - Create session
                session.setAttribute("userId", rs.getInt("user_id"));
                session.setAttribute("userName", rs.getString("name"));
                session.setAttribute("userEmail", rs.getString("email"));
                session.setAttribute("userRole", rs.getString("role"));
                
                // Redirect based on role
                String role = rs.getString("role");
                if("admin".equals(role)) {
                    response.sendRedirect("admin/admin-dashboard.jsp");
                } else {
                    response.sendRedirect("user/user-dashboard.jsp");
                }
                return;
            } else {
                message = "Invalid email or password!";
                messageType = "danger";
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
    <title>Login</title>
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
        .login-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 40px;
            max-width: 450px;
            width: 100%;
        }
    </style>
</head>
<body>
    <div class="login-card">
        <h2 class="text-center mb-4">
            <i class="fas fa-sign-in-alt text-primary"></i> Login
        </h2>
        
        <% if(!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
                <%= message %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
        
        <form method="POST" action="login.jsp">
            <div class="mb-3">
                <label class="form-label"><i class="fas fa-envelope"></i> Email</label>
                <input type="email" class="form-control" name="email" placeholder="example@gmail.com" required>
            </div>
            
            <div class="mb-3">
                <label class="form-label"><i class="fas fa-lock"></i> Password</label>
                <input type="password" class="form-control" name="password" required>
            </div>
            
            <button type="submit" class="btn btn-primary w-100">
                <i class="fas fa-sign-in-alt"></i> Login
            </button>
        </form>
        
        <hr>
        <div class="text-center">
            <p>Don't have an account? <a href="register.jsp">Register here</a></p>
            <a href="index.jsp" class="text-muted">
                <i class="fas fa-home"></i> Back to Home
            </a>
        </div>
        
        <div class="mt-4 text-center">
            <small class="text-muted">
                <i class="fas fa-info-circle"></i> Test Credentials<br>
                Admin: admin@gmail.com / admin123
            </small>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>