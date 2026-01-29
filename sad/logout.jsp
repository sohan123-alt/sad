<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
/**
 * Logout JSP
 * Destroys user session and redirects to login page
 */

// Invalidate session
session.invalidate();

// Redirect to login page with success message
response.sendRedirect("login.jsp");
%>