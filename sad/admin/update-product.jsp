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
int productId = 0;

// Get product ID from URL
if(request.getParameter("id") != null) {
    productId = Integer.parseInt(request.getParameter("id"));
}

// Update logic
if(request.getMethod().equalsIgnoreCase("POST")) {
    String productName = request.getParameter("productName");
    String categoryId = request.getParameter("categoryId");
    String quantity = request.getParameter("quantity");
    String price = request.getParameter("price");
    String description = request.getParameter("description");
    
    try {
        int catId = Integer.parseInt(categoryId);
        int qty = Integer.parseInt(quantity);
        double prc = Double.parseDouble(price);
        
        String updateSql = "UPDATE products SET product_name=?, category_id=?, quantity=?, price=?, description=? WHERE product_id=?";
        pstmt = conn.prepareStatement(updateSql);
        pstmt.setString(1, productName);
        pstmt.setInt(2, catId);
        pstmt.setInt(3, qty);
        pstmt.setDouble(4, prc);
        pstmt.setString(5, description);
        pstmt.setInt(6, productId);
        
        int result = pstmt.executeUpdate();
        
        if(result > 0) {
            message = "Product updated successfully!";
            messageType = "success";
        } else {
            message = "Failed to update product!";
            messageType = "danger";
        }
        
        pstmt.close();
    } catch(Exception e) {
        message = "Error: " + e.getMessage();
        messageType = "danger";
        e.printStackTrace();
    }
}

// Fetch product details
String productName = "";
int categoryId = 0;
int quantity = 0;
double price = 0;
String description = "";

try {
    String sql = "SELECT * FROM products WHERE product_id = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, productId);
    rs = pstmt.executeQuery();
    
    if(rs.next()) {
        productName = rs.getString("product_name");
        categoryId = rs.getInt("category_id");
        quantity = rs.getInt("quantity");
        price = rs.getDouble("price");
        description = rs.getString("description");
    }
    
    rs.close();
    pstmt.close();
} catch(Exception e) {
    e.printStackTrace();
}
%>

<title>Update Product - IMS</title>

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
                <i class="fas fa-edit"></i> Update Product
            </h2>
            
            <% if(!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %> alert-dismissible fade show" role="alert">
                    <%= message %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            
            <div class="card">
                <div class="card-body">
                    <form method="POST" action="update-product.jsp?id=<%= productId %>">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Product Name</label>
                                <input type="text" class="form-control" name="productName" 
                                       value="<%= productName %>" required>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Category</label>
                                <select class="form-select" name="categoryId" required>
                                    <%
                                    try {
                                        String sql = "SELECT * FROM categories ORDER BY category_name";
                                        pstmt = conn.prepareStatement(sql);
                                        rs = pstmt.executeQuery();
                                        
                                        while(rs.next()) {
                                            int catId = rs.getInt("category_id");
                                            String selected = (catId == categoryId) ? "selected" : "";
                                    %>
                                    <option value="<%= catId %>" <%= selected %>>
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
                                       value="<%= quantity %>" min="0" required>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Price (BDT)</label>
                                <input type="number" step="0.01" class="form-control" name="price" 
                                       value="<%= price %>" min="0.01" required>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Description</label>
                            <textarea class="form-control" name="description" rows="3"><%= description %></textarea>
                        </div>
                        
                        <button type="submit" class="btn btn-success">
                            <i class="fas fa-save"></i> Update Product
                        </button>
                        <a href="view-product.jsp" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Back to Products
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