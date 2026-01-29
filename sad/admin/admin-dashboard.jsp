<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../header.jsp" %>
<%@ include file="../dbconnection.jsp" %>

<%
// Check if user is admin
if(!"admin".equals(userRole)) {
    response.sendRedirect(request.getContextPath() + "/user/user-dashboard.jsp");
    return;
}

// Fetch dashboard statistics
int totalProducts = 0;
int totalStock = 0;
int totalSales = 0;
int totalCategories = 0;

try {
    // Total Products
    pstmt = conn.prepareStatement("SELECT COUNT(*) FROM products");
    rs = pstmt.executeQuery();
    if(rs.next()) totalProducts = rs.getInt(1);
    rs.close();
    pstmt.close();
    
    // Total Stock
    pstmt = conn.prepareStatement("SELECT NVL(SUM(quantity), 0) FROM products");
    rs = pstmt.executeQuery();
    if(rs.next()) totalStock = rs.getInt(1);
    rs.close();
    pstmt.close();
    
    // Total Sales
    pstmt = conn.prepareStatement("SELECT NVL(SUM(quantity_sold), 0) FROM sales");
    rs = pstmt.executeQuery();
    if(rs.next()) totalSales = rs.getInt(1);
    rs.close();
    pstmt.close();
    
    // Total Categories
    pstmt = conn.prepareStatement("SELECT COUNT(*) FROM categories");
    rs = pstmt.executeQuery();
    if(rs.next()) totalCategories = rs.getInt(1);
    
} catch(Exception e) {
    e.printStackTrace();
} finally {
    if(rs != null) try { rs.close(); } catch(Exception e) {}
    if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
    if(conn != null) try { conn.close(); } catch(Exception e) {}
}
%>

<title>Admin Dashboard</title>

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-2 sidebar">
            <h5><i class="fas fa-tachometer-alt"></i> Admin Panel</h5>
            <hr>
            <a href="admin-dashboard.jsp" class="active">
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
            <a href="sales-report.jsp">
                <i class="fas fa-chart-line"></i> Sales Report
            </a>
        </div>
        
        <!-- Main Content -->
        <div class="col-md-10 content-wrapper">
            <h2 class="mb-4">
                <i class="fas fa-tachometer-alt"></i> Admin Dashboard
            </h2>
            
            <!-- Statistics Cards -->
            <div class="row">
                <div class="col-md-3 mb-4">
                    <div class="card bg-primary text-white">
                        <div class="card-body">
                            <h5 class="card-title">
                                <i class="fas fa-box"></i> Total Products
                            </h5>
                            <h2><%= totalProducts %></h2>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-3 mb-4">
                    <div class="card bg-success text-white">
                        <div class="card-body">
                            <h5 class="card-title">
                                <i class="fas fa-cubes"></i> Available Stock
                            </h5>
                            <h2><%= totalStock %></h2>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-3 mb-4">
                    <div class="card bg-warning text-white">
                        <div class="card-body">
                            <h5 class="card-title">
                                <i class="fas fa-shopping-cart"></i> Total Sales
                            </h5>
                            <h2><%= totalSales %></h2>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-3 mb-4">
                    <div class="card bg-info text-white">
                        <div class="card-body">
                            <h5 class="card-title">
                                <i class="fas fa-tags"></i> Categories
                            </h5>
                            <h2><%= totalCategories %></h2>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Recent Products -->
            <div class="card mt-4">
                <div class="card-header bg-primary text-white">
                    <h5><i class="fas fa-clock"></i> Recent Products</h5>
                </div>
                <div class="card-body">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Product Name</th>
                                <th>Category</th>
                                <th>Quantity</th>
                                <th>Price</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try {
                                conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "sohan1");
                                String sql = "SELECT p.product_name, c.category_name, p.quantity, p.price " +
                                           "FROM products p JOIN categories c ON p.category_id = c.category_id " +
                                           "ORDER BY p.created_date DESC FETCH FIRST 5 ROWS ONLY";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                
                                while(rs.next()) {
                            %>
                            <tr>
                                <td><%= rs.getString("product_name") %></td>
                                <td><span class="badge bg-secondary"><%= rs.getString("category_name") %></span></td>
                                <td><%= rs.getInt("quantity") %></td>
                                <td>BDT<%= rs.getDouble("price") %></td>
                            </tr>
                            <%
                                }
                            } catch(Exception e) {
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