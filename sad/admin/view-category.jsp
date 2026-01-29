<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../header.jsp" %>
<%@ include file="../dbconnection.jsp" %>

<%
// Check if user is admin
if(!"admin".equals(userRole)) {
    response.sendRedirect(request.getContextPath() + "/user/user-dashboard.jsp");
    return;
}

// Handle category deletion
String message = "";
String messageType = "";

if(request.getParameter("delete") != null) {
    try {
        int categoryId = Integer.parseInt(request.getParameter("delete"));
        
        String deleteSql = "DELETE FROM categories WHERE category_id = ?";
        pstmt = conn.prepareStatement(deleteSql);
        pstmt.setInt(1, categoryId);
        
        int result = pstmt.executeUpdate();
        
        if(result > 0) {
            message = "Category deleted successfully!";
            messageType = "success";
        } else {
            message = "Failed to delete category!";
            messageType = "danger";
        }
        
        pstmt.close();
    } catch(Exception e) {
        message = "Error: Cannot delete category with existing products!";
        messageType = "danger";
        e.printStackTrace();
    }
}
%>

<title>View Categories</title>

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-2 sidebar">
            <h5><i class="fas fa-tachometer-alt"></i> Admin Panel</h5>
            <hr>
            <a href="admin-dashboard.jsp">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <a href="add-category.jsp">
                <i class="fas fa-plus"></i> Add Category
            </a>
            <a href="view-category.jsp" class="active">
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
                <i class="fas fa-list"></i> View Categories
            </h2>
            
            <% if(!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
                    <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5>All Categories</h5>
                </div>
                <div class="card-body">
                    <table class="table table-striped table-hover">
                        <thead class="table-dark">
                            <tr>
                                <th>ID</th>
                                <th>Category Name</th>
                                <th>Created Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try {
                                String sql = "SELECT * FROM categories ORDER BY category_id";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                
                                while(rs.next()) {
                            %>
                            <tr>
                                <td><%= rs.getInt("category_id") %></td>
                                <td><strong><%= rs.getString("category_name") %></strong></td>
                                <td><%= rs.getDate("created_date") %></td>
                                <td>
                                    <a href="view-category.jsp?delete=<%= rs.getInt("category_id") %>" 
                                       class="btn btn-danger btn-sm"
                                       onclick="return confirm('Are you sure you want to delete this category?')">
                                        <i class="fas fa-trash"></i> Delete
                                    </a>
                                </td>
                            </tr>
                            <%
                                }
                                
                                if(!rs.isBeforeFirst()) {
                                    out.println("<tr><td colspan='4' class='text-center'>No categories found</td></tr>");
                                }
                            } catch(Exception e) {
                                out.println("<tr><td colspan='4' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
                                e.printStackTrace();
                            } finally {
                                if(rs != null) try { rs.close(); } catch(Exception e) {}
                                if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                                if(conn != null) try { conn.close(); } catch(Exception e) {}
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="../footer.jsp" %>