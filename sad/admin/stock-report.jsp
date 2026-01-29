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

<title>Stock Report</title>

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
            <a href="view-product.jsp">
                <i class="fas fa-boxes"></i> View Products
            </a>
            <a href="stock-management.jsp">
                <i class="fas fa-warehouse"></i> Stock Management
            </a>
            <a href="stock-report.jsp" class="active">
                <i class="fas fa-chart-bar"></i> Stock Report
            </a>
            <a href="sales-report.jsp">
                <i class="fas fa-chart-line"></i> Sales Report
            </a>
        </div>
        
        <!-- Main Content -->
        <div class="col-md-10 content-wrapper">
            <h2 class="mb-4">
                <i class="fas fa-chart-bar"></i> Stock Report
            </h2>
            
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5>Stock Movement History</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>Stock ID</th>
                                    <th>Product Name</th>
                                    <th>Stock In</th>
                                    <th>Stock Out</th>
                                    <th>Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    String sql = "SELECT s.stock_id, p.product_name, s.stock_in, s.stock_out, " +
                                               "TO_CHAR(s.stock_date, 'DD-MON-YYYY HH24:MI:SS') as formatted_date " +
                                               "FROM stock s JOIN products p ON s.product_id = p.product_id " +
                                               "ORDER BY s.stock_date DESC";
                                    pstmt = conn.prepareStatement(sql);
                                    rs = pstmt.executeQuery();
                                    
                                    boolean hasRecords = false;
                                    while(rs.next()) {
                                        hasRecords = true;
                                        int stockIn = rs.getInt("stock_in");
                                        int stockOut = rs.getInt("stock_out");
                                %>
                                <tr>
                                    <td><%= rs.getInt("stock_id") %></td>
                                    <td><strong><%= rs.getString("product_name") %></strong></td>
                                    <td>
                                        <% if(stockIn > 0) { %>
                                            <span class="badge bg-success">+<%= stockIn %></span>
                                        <% } else { %>
                                            -
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if(stockOut > 0) { %>
                                            <span class="badge bg-danger">-<%= stockOut %></span>
                                        <% } else { %>
                                            -
                                        <% } %>
                                    </td>
                                    <td><%= rs.getString("formatted_date") %></td>
                                </tr>
                                <%
                                    }
                                    
                                    if(!hasRecords) {
                                        out.println("<tr><td colspan='5' class='text-center'>No stock movements found</td></tr>");
                                    }
                                } catch(Exception e) {
                                    out.println("<tr><td colspan='5' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
                                    e.printStackTrace();
                                } finally {
                                    if(rs != null) try { rs.close(); } catch(Exception e) {}
                                    if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                                }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <!-- Current Stock Status -->
            <div class="card mt-4">
                <div class="card-header bg-success text-white">
                    <h5>Current Stock Status</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead class="table-dark">
                                <tr>
                                    <th>Product Name</th>
                                    <th>Category</th>
                                    <th>Current Stock</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    String sql = "SELECT p.product_name, c.category_name, p.quantity " +
                                               "FROM products p JOIN categories c ON p.category_id = c.category_id " +
                                               "ORDER BY p.quantity";
                                    pstmt = conn.prepareStatement(sql);
                                    rs = pstmt.executeQuery();
                                    
                                    while(rs.next()) {
                                        int qty = rs.getInt("quantity");
                                        String status = "";
                                        String statusClass = "";
                                        
                                        if(qty == 0) {
                                            status = "Out of Stock";
                                            statusClass = "danger";
                                        } else if(qty <= 10) {
                                            status = "Low Stock";
                                            statusClass = "warning";
                                        } else {
                                            status = "In Stock";
                                            statusClass = "success";
                                        }
                                %>
                                <tr>
                                    <td><%= rs.getString("product_name") %></td>
                                    <td><span class="badge bg-secondary"><%= rs.getString("category_name") %></span></td>
                                    <td><strong><%= qty %></strong></td>
                                    <td><span class="badge bg-<%= statusClass %>"><%= status %></span></td>
                                </tr>
                                <%
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
</div>

<%@ include file="../footer.jsp" %>