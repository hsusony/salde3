# إعداد SQL Server 2008 لنظام إدارة المبيعات

## 📋 المتطلبات الأساسية

1. **SQL Server 2008 أو أحدث** مثبت على Windows
2. **SQL Server Management Studio (SSMS)** للإدارة
3. تفعيل **TCP/IP Protocol** في SQL Server Configuration Manager

---

## 🔧 خطوات الإعداد

### 1. تثبيت قاعدة البيانات

قم بتشغيل السكريبت التالي من مجلد `database`:

```cmd
cd database
setup_database_2008.bat
```

أو يدوياً من خلال SSMS:

```cmd
sqlcmd -S localhost -E -i "database\00_setup_complete_2008.sql"
```

### 2. التحقق من تفعيل TCP/IP

1. افتح **SQL Server Configuration Manager**
2. انتقل إلى **SQL Server Network Configuration** > **Protocols for MSSQLSERVER**
3. تأكد من تفعيل **TCP/IP**
4. انقر بزر الماوس الأيمن على TCP/IP واختر **Properties**
5. في تبويب **IP Addresses**، تأكد من:
   - `IP1` > `Enabled = Yes`
   - `IPAll` > `TCP Port = 1433`
6. أعد تشغيل خدمة SQL Server

### 3. تفعيل SQL Server Authentication (اختياري)

إذا كنت تريد استخدام SQL Server Authentication بدلاً من Windows Authentication:

1. افتح SSMS
2. انقر بزر الماوس الأيمن على اسم السيرفر > **Properties**
3. اذهب إلى **Security**
4. اختر **SQL Server and Windows Authentication mode**
5. أعد تشغيل SQL Server

### 4. إنشاء مستخدم SQL (اختياري)

```sql
USE master;
GO

CREATE LOGIN sales_user WITH PASSWORD = 'YourStrongPassword123!';
GO

USE SalesManagementDB;
GO

CREATE USER sales_user FOR LOGIN sales_user;
GO

ALTER ROLE db_owner ADD MEMBER sales_user;
GO
```

---

## 🔌 طرق الاتصال من Flutter

### الطريقة 1: REST API (موصى بها) ⭐

إنشاء Web API بلغة C# للاتصال بـ SQL Server:

```csharp
// ASP.NET Core Web API
// Controllers/ProductsController.cs

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly string connectionString = 
        "Server=localhost;Database=SalesManagementDB;Trusted_Connection=True;";

    [HttpGet]
    public async Task<IActionResult> GetProducts()
    {
        using var connection = new SqlConnection(connectionString);
        using var command = new SqlCommand("SELECT * FROM Products", connection);
        
        await connection.OpenAsync();
        var reader = await command.ExecuteReaderAsync();
        
        var products = new List<Product>();
        while (await reader.ReadAsync())
        {
            products.Add(new Product 
            {
                Id = reader.GetInt32(0),
                Name = reader.GetString(1),
                // ... باقي الحقول
            });
        }
        
        return Ok(products);
    }
}
```

ثم من Flutter:

```dart
// lib/services/api_service.dart
class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }
    throw Exception('Failed to load products');
  }
}
```

### الطريقة 2: ODBC Driver (متقدم)

استخدام `ffi` للاتصال المباشر بـ SQL Server عبر ODBC:

```yaml
# pubspec.yaml
dependencies:
  ffi: ^2.0.1
  win32: ^5.0.0
```

---

## 📊 هيكل قاعدة البيانات

### الجداول الرئيسية:

- ✅ `Products` - المنتجات
- ✅ `Customers` - العملاء
- ✅ `Sales` - المبيعات
- ✅ `SaleItems` - تفاصيل المبيعات
- ✅ `Purchases` - المشتريات
- ✅ `PurchaseItems` - تفاصيل المشتريات
- ✅ `Installments` - الأقساط
- ✅ `Quotations` - عروض الأسعار
- ✅ `PendingOrders` - قوائم الانتظار

### الإجراءات المخزنة:

- `sp_AddSale` - إضافة عملية بيع
- `sp_UpdateStock` - تحديث المخزون
- `sp_GetCustomerBalance` - الحصول على رصيد العميل
- وغيرها...

---

## 🔐 بيانات الدخول الافتراضية

```
Username: admin
Password: admin123
```

⚠️ **تحذير:** قم بتغيير كلمة المرور فوراً بعد أول تسجيل دخول!

---

## 🛠️ استكشاف الأخطاء

### خطأ: لا يمكن الاتصال بـ SQL Server

**الحل:**
1. تأكد من تشغيل خدمة SQL Server
2. تحقق من تفعيل TCP/IP
3. تأكد من فتح Port 1433 في الجدار الناري

```cmd
# تحقق من الخدمة
net start MSSQLSERVER

# فتح Port في Windows Firewall
netsh advfirewall firewall add rule name="SQL Server" dir=in action=allow protocol=TCP localport=1433
```

### خطأ: فشل المصادقة

**الحل:**
1. تأكد من تفعيل SQL Server Authentication
2. تحقق من اسم المستخدم وكلمة المرور
3. تحقق من صلاحيات المستخدم على قاعدة البيانات

---

## 📝 ملاحظات مهمة

1. **النسخ الاحتياطي:** قم بإنشاء نسخ احتياطية دورية لقاعدة البيانات:
   ```sql
   BACKUP DATABASE SalesManagementDB 
   TO DISK = 'C:\Backup\SalesManagementDB.bak'
   WITH FORMAT;
   ```

2. **الأداء:** استخدم الفهارس (Indexes) على الأعمدة المستخدمة في البحث

3. **الأمان:** لا تخزن كلمات المرور بنص واضح في الكود

---

## 📞 الدعم الفني

للمزيد من المعلومات، راجع:
- `database/README_SQL_2008.md`
- `database/QUICK_REFERENCE.md`

---

**تم إعداد الدليل بواسطة: فريق تطوير نظام إدارة المبيعات**  
**التاريخ: نوفمبر 2025**
