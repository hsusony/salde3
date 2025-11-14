# 🚀 Sales Management System API
## Professional REST API Documentation v2.0

> **Developed by 9SOFT** - Innovative Software Solutions | حلول برمجية مبتكرة

---

## 📋 Overview

Professional RESTful API built with PHP 8.x and SQL Server 2008 for comprehensive sales management operations.

### ✨ Features

- ✅ **RESTful Architecture** - Clean and intuitive API design
- 🔐 **Advanced Security** - JWT authentication, rate limiting, SQL injection prevention
- 📊 **Comprehensive Reporting** - Sales, profit, inventory, and customer analytics
- 💾 **Automated Backups** - Database backup and restore functionality
- 📝 **Professional Logging** - Request tracking and error monitoring
- ⚡ **High Performance** - Optimized queries and caching system
- 🌐 **CORS Enabled** - Cross-origin resource sharing support
- 🔄 **Transaction Support** - Atomic operations for data integrity

---

## 🛠️ Tech Stack

- **Backend**: PHP 8.x
- **Database**: Microsoft SQL Server 2008
- **Authentication**: JWT (JSON Web Tokens)
- **Architecture**: RESTful API
- **Security**: bcrypt password hashing, rate limiting, input validation

---

## 🚦 Quick Start

### 1. Requirements

- PHP 8.0 or higher
- SQL Server 2008 or higher
- PHP SQL Server extension (sqlsrv)
- Composer (optional for advanced features)

### 2. Installation

```bash
# Clone repository
git clone https://github.com/yourusername/sales-system.git

# Navigate to backend directory
cd sales-system/backend-php

# Start PHP built-in server
php -S localhost:80
```

### 3. Configuration

Edit `config/Database.php`:

```php
private $serverName = ".\\MORABSQLE";
private $database = "SalesManagementDB";
private $username = "sa";
private $password = "your_password";
```

---

## 📡 API Endpoints

### Base URL
```
http://localhost/backend-php/api
```

### 🔐 Authentication

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم تسجيل الدخول بنجاح",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "user": {
      "UserID": 1,
      "Username": "admin",
      "FullName": "System Administrator"
    }
  }
}
```

---

### 👥 Customers

#### Get All Customers
```http
GET /api/customers
Authorization: Bearer {token}
```

#### Get Customer by ID
```http
GET /api/customers/{id}
Authorization: Bearer {token}
```

#### Create Customer
```http
POST /api/customers
Authorization: Bearer {token}
Content-Type: application/json

{
  "CustomerName": "أحمد محمد",
  "Phone": "07701234567",
  "Email": "ahmed@example.com",
  "Address": "بغداد، شارع الرشيد"
}
```

#### Update Customer
```http
PUT /api/customers/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "CustomerName": "أحمد محمد علي",
  "Phone": "07701234567"
}
```

#### Delete Customer
```http
DELETE /api/customers/{id}
Authorization: Bearer {token}
```

---

### 📦 Products

#### Get All Products
```http
GET /api/products
Authorization: Bearer {token}
```

#### Search Products
```http
GET /api/products?search=laptop
Authorization: Bearer {token}
```

#### Get Low Stock Products
```http
GET /api/products?lowStock=true
Authorization: Bearer {token}
```

#### Create Product
```http
POST /api/products
Authorization: Bearer {token}
Content-Type: application/json

{
  "ProductName": "Laptop Dell",
  "CategoryID": 1,
  "UnitID": 1,
  "PurchasePrice": 500.00,
  "SalePrice": 750.00,
  "Stock": 50,
  "MinimumStock": 10,
  "Barcode": "123456789",
  "Description": "Laptop Dell Core i7"
}
```

---

### 💰 Sales

#### Get All Sales
```http
GET /api/sales
Authorization: Bearer {token}
```

#### Get Daily Sales Report
```http
GET /api/sales?date=2025-11-14
Authorization: Bearer {token}
```

#### Create Sale
```http
POST /api/sales
Authorization: Bearer {token}
Content-Type: application/json

{
  "CustomerID": 1,
  "PaymentMethod": "cash",
  "Discount": 0,
  "Tax": 0,
  "Notes": "بيع مباشر",
  "items": [
    {
      "ProductID": 1,
      "Quantity": 2,
      "UnitPrice": 750.00,
      "Discount": 0
    }
  ]
}
```

---

### 📊 Reports

#### Daily Sales Report
```http
GET /api/reports/daily-sales?date=2025-11-14
Authorization: Bearer {token}
```

#### Monthly Sales Report
```http
GET /api/reports/monthly-sales?year=2025&month=11
Authorization: Bearer {token}
```

#### Top Selling Products
```http
GET /api/reports/top-selling?limit=10
Authorization: Bearer {token}
```

#### Top Customers
```http
GET /api/reports/top-customers?limit=10
Authorization: Bearer {token}
```

#### Profit Report
```http
GET /api/reports/profit?startDate=2025-11-01&endDate=2025-11-30
Authorization: Bearer {token}
```

#### Inventory Report
```http
GET /api/reports/inventory
Authorization: Bearer {token}
```

#### Debts Report
```http
GET /api/reports/debts
Authorization: Bearer {token}
```

---

### 💾 Backup & Restore

#### Create Backup
```http
POST /api/backup/create
Authorization: Bearer {token}
```

#### List Backups
```http
GET /api/backup/list
Authorization: Bearer {token}
```

#### Export Data
```http
POST /api/backup/export
Authorization: Bearer {token}
Content-Type: application/json

{
  "tables": ["Customers", "Products", "Sales"]
}
```

---

### 📈 Dashboard Statistics

```http
GET /api/dashboard/stats
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "totalCustomers": 150,
    "totalProducts": 500,
    "totalSales": 1250,
    "todaySales": 25000.00,
    "lowStockProducts": 12,
    "totalDebts": 50000.00
  }
}
```

---

## 🔒 Security Features

### Rate Limiting
- **100 requests per minute** per IP address
- Automatic blocking of abusive IPs

### Input Validation
- SQL injection prevention
- XSS protection
- CSRF token validation
- Request sanitization

### Password Security
- bcrypt hashing with cost factor 12
- Password strength requirements
- Secure token generation

### API Security
- JWT token authentication
- Token expiration (24 hours)
- Refresh token support
- HTTPS recommended for production

---

## 📝 Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": { /* response data */ }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description"
}
```

### HTTP Status Codes
- `200` - OK
- `201` - Created
- `204` - No Content
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `429` - Too Many Requests
- `500` - Internal Server Error

---

## 🧪 Testing

### Health Check
```bash
curl http://localhost/backend-php/api/health
```

### Test API Info
```bash
curl http://localhost/backend-php/api
```

---

## 📊 Performance

- Average response time: **< 100ms**
- Database query optimization
- Connection pooling
- Query result caching
- Automatic log rotation

---

## 🐛 Debugging

### Enable Debug Mode
Edit `index.php`:
```php
define('DEBUG_MODE', true);
```

### View Logs
```
backend-php/logs/app.log       - Application logs
backend-php/logs/error.log     - Error logs
backend-php/logs/security.log  - Security events
backend-php/logs/performance.log - Performance metrics
```

---

## 🤝 Support

- **Email**: support@9soft.com
- **Documentation**: `/api/docs`
- **Issues**: GitHub Issues

---

## 📄 License

Proprietary - Copyright © 2025 9SOFT. All rights reserved.

---

## 🎉 Credits

**Developed with ❤️ by 9SOFT**

*Innovative Software Solutions | حلول برمجية مبتكرة*
