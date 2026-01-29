<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../header.jsp" %>
<%@ include file="../dbconnection.jsp" %>

<%
String searchTerm = request.getParameter("search");
boolean isSearching = (searchTerm != null && !searchTerm.trim().isEmpty());
%>

<title>Search Products</title>

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-2 sidebar">
            <h5><i class="fas fa-user"></i> User Panel</h5>
            <hr>
            <a href="user-dashboard.jsp">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <a href="product-list.jsp">
                <i class="fas fa-boxes"></i> Products
            </a>
            <a href="search-product.jsp" class="active">
                <i class="fas fa-search"></i> Search Products
            </a>
        </div>
        
        <!-- Main Content -->
        <div class="col-md-10 content-wrapper">
            <h2 class="mb-4">
                <i class="fas fa-search"></i> Search Products
            </h2>
            
            <!-- Search Form -->
            <div class="card mb-4">
                <div class="card-body">
                    <form method="GET" action="search-product.jsp">
                        <div class="input-group">
                            <input type="text" class="form-control" name="search" 
                                   placeholder="Search by product name or category..." 
                                   value="<%= searchTerm != null ? searchTerm : "" %>" required>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-search"></i> Search
                            </button>
                            <% if(isSearching) { %>
                            <a href="search-product.jsp" class="btn btn-secondary">
                                <i class="fas fa-times"></i> Clear
                            </a>
                            <% } %>
                        </div>
                    </form>
                </div>
            </div>
            
            <!-- Search Results -->
            <% if(isSearching) { %>
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5>Search Results for: "<%= searchTerm %>"</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>Product Name</th>
                                    <th>Category</th>
                                    <th>Price (BDT)</th>
                                    <th>Quantity</th>
                                    <th>Description</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    String sql = "SELECT p.product_name, c.category_name, p.price, p.quantity, p.description " +
                                               "FROM products p JOIN categories c ON p.category_id = c.category_id " +
                                               "WHERE LOWER(p.product_name) LIKE LOWER(?) OR LOWER(c.category_name) LIKE LOWER(?) " +
                                               "ORDER BY p.product_name";
                                    pstmt = conn.prepareStatement(sql);
                                    String searchPattern = "%" + searchTerm + "%";
                                    pstmt.setString(1, searchPattern);
                                    pstmt.setString(2, searchPattern);
                                    rs = pstmt.executeQuery();
                                    
                                    boolean hasResults = false;
                                    while(rs.next()) {
                                        hasResults = true;
                                        int qty = rs.getInt("quantity");
                                        String status = qty > 0 ? "Available" : "Out of Stock";
                                        String statusClass = qty > 0 ? "success" : "danger";
                                %>
                                <tr>
                                    <td><strong><%= rs.getString("product_name") %></strong></td>
                                    <td><span class="badge bg-secondary"><%= rs.getString("category_name") %></span></td>
                                    <td>₹<%= String.format("%.2f", rs.getDouble("price")) %></td>
                                    <td><%= qty %></td>
                                    <td><%= rs.getString("description") != null ? rs.getString("description") : "-" %></td>
                                    <td><span class="badge bg-<%= statusClass %>"><%= status %></span></td>
                                </tr>
                                <%
                                    }
                                    
                                    if(!hasResults) {
                                %>
                                <tr>
                                    <td colspan="6" class="text-center text-muted">
                                        <i class="fas fa-exclamation-circle"></i> 
                                        No products found matching "<%= searchTerm %>"
                                    </td>
                                </tr>
                                <%
                                    }
                                } catch(Exception e) {
                                    out.println("<tr><td colspan='6' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
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
            <% } else { %>
            <div class="card">
                <div class="card-body text-center py-5">
                    <i class="fas fa-search fa-5x text-muted mb-3"></i>
                    <h4>Search for Products</h4>
                    <p class="text-muted">
                        Enter a product name or category in the search box above to find products.
                    </p>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</div>

<%@ include file="../footer.jsp" %>