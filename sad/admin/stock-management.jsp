<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../header.jsp" %>
<%@ include file="../dbconnection.jsp" %>

<%
// Check if user is admin
if(!"admin".equals(userRole)) {
    response.sendRedirect(request.getContextPath() + "/user/user-dashboard.jsp");
    return;
}

String message = "";
String messageType = "";

// Handle stock update
if(request.getMethod().equalsIgnoreCase("POST")) {
    String productId = request.getParameter("productId");
    String action = request.getParameter("action");
    String quantityStr = request.getParameter("quantity");
    
    if(productId != null && action != null && quantityStr != null) {
        try {
            int prodId = Integer.parseInt(productId);
            int qty = Integer.parseInt(quantityStr);
            
            if(qty <= 0) {
                message = "Quantity must be greater than 0!";
                messageType = "danger";
            } else {
                // Get current stock
                String selectSql = "SELECT quantity FROM products WHERE product_id = ?";
                pstmt = conn.prepareStatement(selectSql);
                pstmt.setInt(1, prodId);
                rs = pstmt.executeQuery();
                
                if(rs.next()) {
                    int currentStock = rs.getInt("quantity");
                    int newStock = currentStock;
                    int stockIn = 0;
                    int stockOut = 0;
                    
                    if("add".equals(action)) {
                        newStock = currentStock + qty;
                        stockIn = qty;
                    } else if("remove".equals(action)) {
                        if(qty > currentStock) {
                            message = "Cannot remove more than available stock!";
                            messageType = "danger";
                        } else {
                            newStock = currentStock - qty;
                            stockOut = qty;
                            
                            // Also add to sales
                            rs.close();
                            pstmt.close();
                            
                            String salesSql = "INSERT INTO sales (product_id, quantity_sold) VALUES (?, ?)";
                            pstmt = conn.prepareStatement(salesSql);
                            pstmt.setInt(1, prodId);
                            pstmt.setInt(2, qty);
                            pstmt.executeUpdate();
                        }
                    }
                    
                    if(message.isEmpty()) {
                        // Update product quantity
                        rs.close();
                        pstmt.close();
                        
                        String updateSql = "UPDATE products SET quantity = ? WHERE product_id = ?";
                        pstmt = conn.prepareStatement(updateSql);
                        pstmt.setInt(1, newStock);
                        pstmt.setInt(2, prodId);
                        pstmt.executeUpdate();
                        pstmt.close();
                        
                        // Insert stock record
                        String stockSql = "INSERT INTO stock (product_id, stock_in, stock_out) VALUES (?, ?, ?)";
                        pstmt = conn.prepareStatement(stockSql);
                        pstmt.setInt(1, prodId);
                        pstmt.setInt(2, stockIn);
                        pstmt.setInt(3, stockOut);
                        pstmt.executeUpdate();
                        
                        message = "Stock updated successfully!";
                        messageType = "success";
                    }
                }
                
                rs.close();
                pstmt.close();
            }
        } catch(Exception e) {
            message = "Error: " + e.getMessage();
            messageType = "danger";
            e.printStackTrace();
        }
    }
}
%>

<title>Stock Management</title>

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
            <a href="stock-management.jsp" class="active">
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
                <i class="fas fa-warehouse"></i> Stock Management
            </h2>
            
            <% if(!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
                    <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5>Manage Product Stock</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>Product ID</th>
                                    <th>Product Name</th>
                                    <th>Category</th>
                                    <th>Current Stock</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    String sql = "SELECT p.product_id, p.product_name, c.category_name, p.quantity " +
                                               "FROM products p JOIN categories c ON p.category_id = c.category_id " +
                                               "ORDER BY p.product_name";
                                    pstmt = conn.prepareStatement(sql);
                                    rs = pstmt.executeQuery();
                                    
                                    while(rs.next()) {
                                        int prodId = rs.getInt("product_id");
                                        int qty = rs.getInt("quantity");
                                        String stockClass = qty > 10 ? "success" : (qty > 0 ? "warning" : "danger");
                                %>
                                <tr>
                                    <td><%= prodId %></td>
                                    <td><strong><%= rs.getString("product_name") %></strong></td>
                                    <td><span class="badge bg-secondary"><%= rs.getString("category_name") %></span></td>
                                    <td><span class="badge bg-<%= stockClass %>"><%= qty %></span></td>
                                    <td>
                                        <!-- Add Stock Form -->
                                        <form method="POST" action="stock-management.jsp" class="d-inline">
                                            <input type="hidden" name="productId" value="<%= prodId %>">
                                            <input type="hidden" name="action" value="add">
                                            <div class="input-group input-group-sm" style="width: 200px; display: inline-flex;">
                                                <input type="number" name="quantity" class="form-control" 
                                                       placeholder="Qty" min="1" required>
                                                <button type="submit" class="btn btn-success">
                                                    <i class="fas fa-plus"></i> Add
                                                </button>
                                            </div>
                                        </form>
                                        
                                        <!-- Remove Stock Form -->
                                        <form method="POST" action="stock-management.jsp" class="d-inline ms-2">
                                            <input type="hidden" name="productId" value="<%= prodId %>">
                                            <input type="hidden" name="action" value="remove">
                                            <div class="input-group input-group-sm" style="width: 200px; display: inline-flex;">
                                                <input type="number" name="quantity" class="form-control" 
                                                       placeholder="Qty" min="1" max="<%= qty %>" required>
                                                <button type="submit" class="btn btn-danger">
                                                    <i class="fas fa-minus"></i> Remove
                                                </button>
                                            </div>
                                        </form>
                                    </td>
                                </tr>
                                <%
                                    }
                                } catch(Exception e) {
                                    out.println("<tr><td colspan='5' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
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