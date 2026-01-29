<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../header.jsp" %>
<%@ include file="../dbconnection.jsp" %>

<%
// Fetch dashboard statistics
int totalProducts = 0;
int totalCategories = 0;

try {
    pstmt = conn.prepareStatement("SELECT COUNT(*) FROM products");
    rs = pstmt.executeQuery();
    if(rs.next()) totalProducts = rs.getInt(1);
    rs.close();
    pstmt.close();
    
    pstmt = conn.prepareStatement("SELECT COUNT(*) FROM categories");
    rs = pstmt.executeQuery();
    if(rs.next()) totalCategories = rs.getInt(1);
    
} catch(Exception e) {
    e.printStackTrace();
} finally {
    if(rs != null) try { rs.close(); } catch(Exception e) {}
    if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
}
%>

<title>User Dashboard</title>

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-2 sidebar">
            <h5><i class="fas fa-user"></i> User Panel</h5>
            <hr>
            <a href="user-dashboard.jsp" class="active">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <a href="product-list.jsp">
                <i class="fas fa-boxes"></i> Products
            </a>
            <a href="search-product.jsp">
                <i class="fas fa-search"></i> Search Products
            </a>
        </div>
        
        <!-- Main Content -->
        <div class="col-md-10 content-wrapper">
            <h2 class="mb-4">
                <i class="fas fa-home"></i> User Dashboard
            </h2>
            
            <div class="alert alert-info">
                <i class="fas fa-info-circle"></i> Welcome, <strong><%= userName %></strong>! 
                You can browse products and search for items.
            </div>
            
            <!-- Statistics Cards -->
            <div class="row">
                <div class="col-md-6 mb-4">
                    <div class="card bg-primary text-white">
                        <div class="card-body">
                            <h5 class="card-title">
                                <i class="fas fa-box"></i> Total Products
                            </h5>
                            <h2><%= totalProducts %></h2>
                            <a href="product-list.jsp" class="btn btn-light btn-sm mt-2">
                                View All Products
                            </a>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-6 mb-4">
                    <div class="card bg-success text-white">
                        <div class="card-body">
                            <h5 class="card-title">
                                <i class="fas fa-tags"></i> Categories Available
                            </h5>
                            <h2><%= totalCategories %></h2>
                            <a href="product-list.jsp" class="btn btn-light btn-sm mt-2">
                                Browse Categories
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Available Products by Category -->
            <div class="card mt-4">
                <div class="card-header bg-primary text-white">
                    <h5><i class="fas fa-chart-pie"></i> Products by Category</h5>
                </div>
                <div class="card-body">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Category</th>
                                <th>Number of Products</th>
                                <th>Total Stock</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try {
                                conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "oracle");
                                String sql = "SELECT c.category_name, COUNT(p.product_id) as product_count, " +
                                           "NVL(SUM(p.quantity), 0) as total_stock " +
                                           "FROM categories c LEFT JOIN products p ON c.category_id = p.category_id " +
                                           "GROUP BY c.category_name ORDER BY product_count DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                
                                while(rs.next()) {
                            %>
                            <tr>
                                <td><strong><%= rs.getString("category_name") %></strong></td>
                                <td><span class="badge bg-primary"><%= rs.getInt("product_count") %></span></td>
                                <td><span class="badge bg-success"><%= rs.getInt("total_stock") %></span></td>
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