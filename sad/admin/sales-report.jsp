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

<title>Sales Report</title>

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
            <a href="stock-report.jsp">
                <i class="fas fa-chart-bar"></i> Stock Report
            </a>
            <a href="sales-report.jsp" class="active">
                <i class="fas fa-chart-line"></i> Sales Report
            </a>
        </div>
        
        <!-- Main Content -->
        <div class="col-md-10 content-wrapper">
            <h2 class="mb-4">
                <i class="fas fa-chart-line"></i> Sales Report
            </h2>
            
            <!-- Sales Statistics -->
            <div class="row mb-4">
                <%
                int totalSalesCount = 0;
                int totalItemsSold = 0;
                double totalRevenue = 0;
                
                try {
                    // Total sales transactions
                    pstmt = conn.prepareStatement("SELECT COUNT(*) FROM sales");
                    rs = pstmt.executeQuery();
                    if(rs.next()) totalSalesCount = rs.getInt(1);
                    rs.close();
                    pstmt.close();
                    
                    // Total items sold
                    pstmt = conn.prepareStatement("SELECT NVL(SUM(quantity_sold), 0) FROM sales");
                    rs = pstmt.executeQuery();
                    if(rs.next()) totalItemsSold = rs.getInt(1);
                    rs.close();
                    pstmt.close();
                    
                    // Total revenue
                    String revenueSql = "SELECT NVL(SUM(s.quantity_sold * p.price), 0) " +
                                      "FROM sales s JOIN products p ON s.product_id = p.product_id";
                    pstmt = conn.prepareStatement(revenueSql);
                    rs = pstmt.executeQuery();
                    if(rs.next()) totalRevenue = rs.getDouble(1);
                    rs.close();
                    pstmt.close();
                } catch(Exception e) {
                    e.printStackTrace();
                }
                %>
                
                <div class="col-md-4">
                    <div class="card bg-info text-white">
                        <div class="card-body">
                            <h5>Total Sales</h5>
                            <h2><%= totalSalesCount %></h2>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-4">
                    <div class="card bg-warning text-white">
                        <div class="card-body">
                            <h5>Items Sold</h5>
                            <h2><%= totalItemsSold %></h2>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-4">
                    <div class="card bg-success text-white">
                        <div class="card-body">
                            <h5>Total Revenue</h5>
                            <h2>BDT<%= String.format("%.2f", totalRevenue) %></h2>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Sales History -->
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5>Sales History</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>Sale ID</th>
                                    <th>Product Name</th>
                                    <th>Quantity Sold</th>
                                    <th>Unit Price</th>
                                    <th>Total Amount</th>
                                    <th>Sale Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    String sql = "SELECT s.sale_id, p.product_name, s.quantity_sold, p.price, " +
                                               "(s.quantity_sold * p.price) as total_amount, " +
                                               "TO_CHAR(s.sale_date, 'DD-MON-YYYY HH24:MI:SS') as formatted_date " +
                                               "FROM sales s JOIN products p ON s.product_id = p.product_id " +
                                               "ORDER BY s.sale_date DESC";
                                    pstmt = conn.prepareStatement(sql);
                                    rs = pstmt.executeQuery();
                                    
                                    boolean hasRecords = false;
                                    while(rs.next()) {
                                        hasRecords = true;
                                %>
                                <tr>
                                    <td><%= rs.getInt("sale_id") %></td>
                                    <td><strong><%= rs.getString("product_name") %></strong></td>
                                    <td><span class="badge bg-primary"><%= rs.getInt("quantity_sold") %></span></td>
                                    <td>BDT<%= String.format("%.2f", rs.getDouble("price")) %></td>
                                    <td><strong>BDT<%= String.format("%.2f", rs.getDouble("total_amount")) %></strong></td>
                                    <td><%= rs.getString("formatted_date") %></td>
                                </tr>
                                <%
                                    }
                                    
                                    if(!hasRecords) {
                                        out.println("<tr><td colspan='6' class='text-center'>No sales records found</td></tr>");
                                    }
                                } catch(Exception e) {
                                    out.println("<tr><td colspan='6' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
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
            
            <!-- Top Selling Products -->
            <div class="card mt-4">
                <div class="card-header bg-success text-white">
                    <h5>Top Selling Products</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead class="table-dark">
                                <tr>
                                    <th>Product Name</th>
                                    <th>Total Quantity Sold</th>
                                    <th>Total Revenue</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    String sql = "SELECT p.product_name, SUM(s.quantity_sold) as total_sold, " +
                                               "SUM(s.quantity_sold * p.price) as total_revenue " +
                                               "FROM sales s JOIN products p ON s.product_id = p.product_id " +
                                               "GROUP BY p.product_name " +
                                               "ORDER BY total_sold DESC";
                                    pstmt = conn.prepareStatement(sql);
                                    rs = pstmt.executeQuery();
                                    
                                    while(rs.next()) {
                                %>
                                <tr>
                                    <td><strong><%= rs.getString("product_name") %></strong></td>
                                    <td><span class="badge bg-primary"><%= rs.getInt("total_sold") %></span></td>
                                    <td><strong>BDT<%= String.format("%.2f", rs.getDouble("total_revenue")) %></strong></td>
                                </tr>
                                <%
                                    }
                                } catch(Exception e) {
                                    out.println("<tr><td colspan='3' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
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