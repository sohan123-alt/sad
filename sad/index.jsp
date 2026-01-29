<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .welcome-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 40px;
            max-width: 600px;
            text-align: center;
        }
        .welcome-card h1 {
            color: #667eea;
            margin-bottom: 20px;
        }
        .btn-custom {
            margin: 10px;
            padding: 12px 30px;
            font-size: 16px;
            border-radius: 25px;
        }
    </style>
</head>
<body>
    <div class="welcome-card">
        <i class="fas fa-warehouse fa-5x text-primary mb-4"></i>
        <h1>Inventory Management System</h1>
        <p class="lead">Manage your inventory efficiently with our comprehensive system</p>
        <hr>
        <div class="mt-4">
            <a href="login.jsp" class="btn btn-primary btn-custom">
                <i class="fas fa-sign-in-alt"></i> Login
            </a>
            <a href="register.jsp" class="btn btn-success btn-custom">
                <i class="fas fa-user-plus"></i> Register
            </a>
        </div>
        <div class="mt-4">
            <p class="text-muted">
                <small>
                    <i class="fas fa-info-circle"></i> 
                </small>
            </p>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>