<%@ page import="java.sql.*" %>
<%
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    
    Class.forName("oracle.jdbc.driver.OracleDriver");
    
    // Database credentials
    String dbURL = "jdbc:oracle:thin:@localhost:1521:XE";
    String dbUser = "system"; 
    String dbPassword = "sohan1"; 
    
    // Establish connection
    conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
} catch(Exception e) {
    e.printStackTrace();
}
%>