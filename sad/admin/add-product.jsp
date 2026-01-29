<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../header.jsp" %>
<%@ include file="../dbconnection.jsp" %>

<%
// Check if user is admin
if(!"admin".equals(userRole)) {
    response.sendRedirect(request.getContextPath() + "/user/user-dashboard.jsp");
    return;
}

// Backend Logic for Adding Product
String message = "";
String messageType = "";

if(request.getMethod().equalsIgnoreCase("POST")) {
    String productName = request.getParameter("productName");
    String categoryId = request.getParameter("categoryId");
    String quantity = request.getParameter("quantity");
    String price = request.getParameter("price");
    String description = request.getParameter("description");
    
    // Validation
    if(productName == null || productName.trim().isEmpty()) {
        message = "Product name is required!";
        messageType = "danger";
    } else if(categoryId == null || categoryId.isEmpty()) {
        message = "Category is required!";
        messageType = "danger";
    } else if(quantity == null || quantity.isEmpty()) {
        message = "Quantity is required!";
        messageType = "danger";
    } else if(price == null || price.isEmpty()) {
        message = "Price is required!";
        messageType = "danger";
    } else {
        try {
            int catId = Integer.parseInt(categoryId);
            int qty = Integer.parseInt(quantity);
            double prc = Double.parseDouble(price);
            
            if(qty < 0) {
                message = "Quantity cannot be negative!";
                messageType = "danger";
            } else if(prc <= 0) {
                message = "Price must be greater than 0!";
                messageType = "danger";
            } else {
                // Insert product
                String insertSql = "INSERT INTO products (product_name, category_id, quantity, price, description) VALUES (?, ?, ?, ?, ?)";
                pstmt = conn.prepareStatement(insertSql, new String[]{"product_id"});
                pstmt.setString(1, productName);
                pstmt.setInt(2, catId);
                pstmt.setInt(3, qty);
                pstmt.setDouble(4, prc);
                pstmt.setString(5, description);
                
                int result = pstmt.executeUpdate();
                
                if(result > 0) {
                    // Get generated product_id
                    rs = pstmt.getGeneratedKeys();
                    if(rs.next()) {
                        int productId = rs.getInt(1);
                        
                        // Insert initial stock entry
                        rs.close();
                        pstmt.close();
                        
                        String stockSql = "INSERT INTO stock (product_id, stock_in, stock_out) VALUES (?, ?, 0)";
                        pstmt = conn.prepareStatement(stockSql);
                        pstmt.setInt(1, productId);
                        pstmt.setInt(2, qty);
                        pstmt.executeUpdate();
                    }
                    
                    message = "Product added successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to add product!";
                    messageType = "danger";
                }
            }
        } catch(NumberFormatException e) {
            message = "Invalid number format!";
            messageType = "danger";
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
%>

<title>Add Product</title>

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
            <a href="add-product.jsp" class="active">
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
                <i class="fas fa-plus-square"></i> Add Product
            </h2>
            
            <% if(!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
                    <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            
            <div class="card">
                <div class="card-body">
                    <form method="POST" action="add-product.jsp">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Product Name</label>
                                <input type="text" class="form-control" name="productName" 
                                       placeholder="Enter product name" required>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Category</label>
                                <select class="form-select" name="categoryId" required>
                                    <option value="">Select Category</option>
                                    <%
                                    try {
                                        String sql = "SELECT * FROM categories ORDER BY category_name";
                                        pstmt = conn.prepareStatement(sql);
                                        rs = pstmt.executeQuery();
                                        
                                        while(rs.next()) {
                                    %>
                                    <option value="<%= rs.getInt("category_id") %>">
                                        <%= rs.getString("category_name") %>
                                    </option>
                                    <%
                                        }
                                    } catch(Exception e) {
                                        e.printStackTrace();
                                    } finally {
                                        if(rs != null) try { rs.close(); } catch(Exception e) {}
                                        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                                    }
                                    %>
                                </select>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Quantity</label>
                                <input type="number" class="form-control" name="quantity" 
                                       placeholder="Enter quantity" min="0" required>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Price (BDT)</label>
                                <input type="number" step="0.01" class="form-control" name="price" 
                                       placeholder="Enter price BDT" min="0.01" required>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Description</label>
                            <textarea class="form-control" name="description" rows="3" 
                                      placeholder="Enter product description"></textarea>
                        </div>
                        
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Add Product
                        </button>
                        <a href="view-product.jsp" class="btn btn-secondary">
                            <i class="fas fa-list"></i> View All Products
                        </a>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<%
if(conn != null) try { conn.close(); } catch(Exception e) {}
%>

<%@ include file="../footer.jsp" %>