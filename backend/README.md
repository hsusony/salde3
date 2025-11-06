# 🚀 Sales Management System API v2.0

## نظام إدارة المبيعات - واجهة برمجية احترافية

---

## ✨ المميزات الاحترافية

### 🔒 الأمان
- ✅ SQL Injection Protection
- ✅ Input Sanitization  
- ✅ Error Handling
- ✅ Request Validation

### ⚡ الأداء
- ✅ Connection Pooling
- ✅ Performance Monitoring
- ✅ Response Time Tracking
- ✅ Slow Query Detection

### 📊 التسجيل
- ✅ Request Logging
- ✅ Error Logging
- ✅ Daily Log Files
- ✅ Performance Logs

---

## 🚀 التشغيل السريع

```bash
cd backend
npm install
npm start
```

**Server URL:** http://localhost:3000  
**Health Check:** http://localhost:3000/api/health

---

## 📡 API Endpoints

### Products
- `GET /api/products` - جميع المنتجات
- `GET /api/products/:id` - منتج معين
- `POST /api/products` - إضافة منتج
- `PUT /api/products/:id` - تحديث منتج
- `DELETE /api/products/:id` - حذف منتج

### Customers
- `GET /api/customers` - جميع العملاء
- `POST /api/customers` - إضافة عميل
- Validation: رقم هاتف عراقي صحيح

### Sales
- `GET /api/sales` - جميع المبيعات
- `POST /api/sales` - إضافة عملية بيع

### Backup
- `POST /api/backup/create` - إنشاء نسخة احتياطية
- `POST /api/backup/restore` - استعادة نسخة
- `GET /api/backup/list` - قائمة النسخ

---

## 🛠️ البنية الاحترافية

```
backend/
├── server.js              # Server احترافي
├── middleware/
│   ├── errorHandler.js    # معالجة الأخطاء
│   ├── validator.js       # التحقق من البيانات
│   └── logger.js         # التسجيل والمراقبة
├── routes/               # مسارات منظمة
├── logs/                 # سجلات يومية
└── config/              # إعدادات
```

---

## ✅ جاهز للإنتاج!

**Version:** 2.0.0  
**Status:** Production Ready 🚀
