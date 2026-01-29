<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
// Check if user is logged in and is admin
if(session.getAttribute("userId") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

String userRole = (String) session.getAttribute("userRole");
if(!"admin".equals(userRole)) {
    response.sendRedirect(request.getContextPath() + "/user/user-dashboard.jsp");
    return;
}

// Delete product logic
int productId = Integer.parseInt(request.getParameter("id"));

Connection conn = null;
PreparedStatement pstmt = null;

try {
    Class.forName("oracle.jdbc.driver.OracleDriver");
    conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "oracle");
    
    // Delete product (cascade will delete related stock and sales)
    String deleteSql = "DELETE FROM products WHERE product_id = ?";
    pstmt = conn.prepareStatement(deleteSql);
    pstmt.setInt(1, productId);
    
    int result = pstmt.executeUpdate();
    
    if(result > 0) {
        session.setAttribute("message", "Product deleted successfully!");
        session.setAttribute("messageType", "success");
    } else {
        session.setAttribute("message", "Failed to delete product!");
        session.setAttribute("messageType", "danger");
    }
} catch(Exception e) {
    session.setAttribute("message", "Error: " + e.getMessage());
    session.setAttribute("messageType", "danger");
    e.printStackTrace();
} finally {
    if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
    if(conn != null) try { conn.close(); } catch(Exception e) {}
}

// Redirect back to view products
response.sendRedirect("view-product.jsp");
%>