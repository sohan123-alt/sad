<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../header.jsp" %>
<%@ include file="../dbconnection.jsp" %>

<title>Product List</title>

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-2 sidebar">
            <h5><i class="fas fa-user"></i> User Panel</h5>
            <hr>
            <a href="user-dashboard.jsp">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <a href="product-list.jsp" class="active">
                <i class="fas fa-boxes"></i> Products
            </a>
            <a href="search-product.jsp">
                <i class="fas fa-search"></i> Search Products
            </a>
        </div>
        
        <!-- Main Content -->
        <div class="col-md-10 content-wrapper">
            <h2 class="mb-4">
                <i class="fas fa-boxes"></i> Product List
            </h2>
            
            <!-- Products Grid -->
            <div class="row">
                <%
                try {
                    String sql = "SELECT p.product_id, p.product_name, c.category_name, " +
                               "p.quantity, p.price, p.description " +
                               "FROM products p JOIN categories c ON p.category_id = c.category_id " +
                               "ORDER BY p.product_name";
                    pstmt = conn.prepareStatement(sql);
                    rs = pstmt.executeQuery();
                    
                    boolean hasProducts = false;
                    while(rs.next()) {
                        hasProducts = true;
                        int qty = rs.getInt("quantity");
                        String availability = qty > 0 ? "In Stock" : "Out of Stock";
                        String availClass = qty > 0 ? "success" : "danger";
                %>
                <div class="col-md-4 mb-4">
                    <div class="card h-100">
                        <div class="card-header bg-primary text-white">
                            <h5 class="card-title mb-0">
                                <%= rs.getString("product_name") %>
                            </h5>
                        </div>
                        <div class="card-body">
                            <p class="card-text">
                                <strong>Category:</strong> 
                                <span class="badge bg-secondary"><%= rs.getString("category_name") %></span>
                            </p>
                            <p class="card-text">
                                <strong>Price:</strong> 
                                <span class="text-success">BDT<%= String.format("%.2f", rs.getDouble("price")) %></span>
                            </p>
                            <p class="card-text">
                                <strong>Availability:</strong> 
                                <span class="badge bg-<%= availClass %>"><%= availability %></span>
                            </p>
                            <p class="card-text">
                                <strong>Quantity:</strong> <%= qty %>
                            </p>
                            <% if(rs.getString("description") != null && !rs.getString("description").isEmpty()) { %>
                            <p class="card-text">
                                <small class="text-muted"><%= rs.getString("description") %></small>
                            </p>
                            <% } %>
                        </div>
                        <div class="card-footer">
                            <small class="text-muted">Product ID: <%= rs.getInt("product_id") %></small>
                        </div>
                    </div>
                </div>
                <%
                    }
                    
                    if(!hasProducts) {
                %>
                <div class="col-12">
                    <div class="alert alert-warning text-center">
                        <i class="fas fa-exclamation-triangle"></i> No products available at the moment.
                    </div>
                </div>
                <%
                    }
                } catch(Exception e) {
                %>
                <div class="col-12">
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-circle"></i> Error loading products: <%= e.getMessage() %>
                    </div>
                </div>
                <%
                    e.printStackTrace();
                } finally {
                    if(rs != null) try { rs.close(); } catch(Exception e) {}
                    if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                    if(conn != null) try { conn.close(); } catch(Exception e) {}
                }
                %>
            </div>
        </div>
    </div>
</div>

<%@ include file="../footer.jsp" %>