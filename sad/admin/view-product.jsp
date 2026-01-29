<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../header.jsp" %>
<%@ include file="../dbconnection.jsp" %>

<%
// Check if user is admin
if(!"admin".equals(userRole)) {
    response.sendRedirect(request.getContextPath() + "/user/user-dashboard.jsp");
    return;
}
%>

<title>View Products</title>

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
            <a href="view-category.jsp">
                <i class="fas fa-list"></i> View Categories
            </a>
            <a href="add-product.jsp">
                <i class="fas fa-plus-square"></i> Add Product
            </a>
            <a href="view-product.jsp" class="active">
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
                <i class="fas fa-boxes"></i> View Products
            </h2>
            
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5>All Products</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>ID</th>
                                    <th>Product Name</th>
                                    <th>Category</th>
                                    <th>Quantity</th>
                                    <th>Price (BDT)</th>
                                    <th>Description</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    String sql = "SELECT p.product_id, p.product_name, c.category_name, " +
                                               "p.quantity, p.price, p.description " +
                                               "FROM products p JOIN categories c ON p.category_id = c.category_id " +
                                               "ORDER BY p.product_id";
                                    pstmt = conn.prepareStatement(sql);
                                    rs = pstmt.executeQuery();
                                    
                                    boolean hasRecords = false;
                                    while(rs.next()) {
                                        hasRecords = true;
                                        int qty = rs.getInt("quantity");
                                        String stockClass = qty > 10 ? "success" : (qty > 0 ? "warning" : "danger");
                                %>
                                <tr>
                                    <td><%= rs.getInt("product_id") %></td>
                                    <td><strong><%= rs.getString("product_name") %></strong></td>
                                    <td><span class="badge bg-secondary"><%= rs.getString("category_name") %></span></td>
                                    <td><span class="badge bg-<%= stockClass %>"><%= qty %></span></td>
                                    <td>BDT<%= String.format("%.2f", rs.getDouble("price")) %></td>
                                    <td><%= rs.getString("description") != null ? rs.getString("description") : "-" %></td>
                                    <td>
                                        <a href="update-product.jsp?id=<%= rs.getInt("product_id") %>" 
                                           class="btn btn-warning btn-sm">
                                            <i class="fas fa-edit"></i> Edit
                                        </a>
                                        <a href="delete-product.jsp?id=<%= rs.getInt("product_id") %>" 
                                           class="btn btn-danger btn-sm"
                                           onclick="return confirm('Are you sure you want to delete this product?')">
                                            <i class="fas fa-trash"></i> Delete
                                        </a>
                                    </td>
                                </tr>
                                <%
                                    }
                                    
                                    if(!hasRecords) {
                                        out.println("<tr><td colspan='7' class='text-center'>No products found</td></tr>");
                                    }
                                } catch(Exception e) {
                                    out.println("<tr><td colspan='7' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
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
</div>

<%@ include file="../footer.jsp" %>