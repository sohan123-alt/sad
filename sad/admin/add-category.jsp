<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../header.jsp" %>
<%@ include file="../dbconnection.jsp" %>

<%
// Check if user is admin
if(!"admin".equals(userRole)) {
    response.sendRedirect(request.getContextPath() + "/user/user-dashboard.jsp");
    return;
}

// Backend Logic for Adding Category
String message = "";
String messageType = "";

if(request.getMethod().equalsIgnoreCase("POST")) {
    String categoryName = request.getParameter("categoryName");
    
    if(categoryName == null || categoryName.trim().isEmpty()) {
        message = "Category name is required!";
        messageType = "danger";
    } else {
        try {
            // Check if category already exists
            String checkSql = "SELECT * FROM categories WHERE LOWER(category_name) = LOWER(?)";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, categoryName);
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                message = "Category already exists!";
                messageType = "warning";
            } else {
                rs.close();
                pstmt.close();
                
                // Insert new category
                String insertSql = "INSERT INTO categories (category_name) VALUES (?)";
                pstmt = conn.prepareStatement(insertSql);
                pstmt.setString(1, categoryName);
                
                int result = pstmt.executeUpdate();
                
                if(result > 0) {
                    message = "Category added successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to add category!";
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
        }
    }
}

if(conn != null) try { conn.close(); } catch(Exception e) {}
%>

<title>Add Category</title>

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-2 sidebar">
            <h5><i class="fas fa-tachometer-alt"></i> Admin Panel</h5>
            <hr>
            <a href="admin-dashboard.jsp">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <a href="add-category.jsp" class="active">
                <i class="fas fa-plus"></i> Add Category
            </a>
            <a href="view-category.jsp">
                <i class="fas fa-list"></i> View Categories
            </a>
            <a href="add-product.jsp">
                <i class="fas fa-plus-square"></i> Add Product
            </a>
            <a href="view-product.jsp">
                <i class="fas fa-boxes"></i> View Products
            </a>
            <a href="stock-management.jsp">
                <i class="fas fa-warehouse"></i> Stock Management
            </a>
            <a href="stock-report.jsp">
                <i class="fas fa-chart-bar"></i> Stock Report
            </a>
            <a href="sales-report.jsp">
                <i class="fas fa-chart-line"></i> Sales Report
            </a>
        </div>
        
        <!-- Main Content -->
        <div class="col-md-10 content-wrapper">
            <h2 class="mb-4">
                <i class="fas fa-plus"></i> Add Category
            </h2>
            
            <% if(!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
                    <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            
            <div class="card">
                <div class="card-body">
                    <form method="POST" action="add-category.jsp">
                        <div class="mb-3">
                            <label class="form-label">Category Name</label>
                            <input type="text" class="form-control" name="categoryName" 
                                   placeholder="Enter category name" required>
                        </div>
                        
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Add Category
                        </button>
                        <a href="view-category.jsp" class="btn btn-secondary">
                            <i class="fas fa-list"></i> View All Categories
                        </a>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="../footer.jsp" %>