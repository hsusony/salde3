const sql = require('mssql');
require('dotenv').config();

// Check if using Windows Authentication
const useWindowsAuth = !process.env.DB_USER || process.env.DB_USER.trim() === '';

const config = {
  server: process.env.DB_SERVER || 'localhost',
  database: process.env.DB_DATABASE || 'SalesManagementDB',
  options: {
    encrypt: process.env.DB_ENCRYPT === 'true',
    trustServerCertificate: process.env.DB_TRUST_CERTIFICATE === 'true',
    enableArithAbort: true,
    // تحسينات إضافية للسرعة
    useUTC: false,           // استخدام التوقيت المحلي بدلاً من UTC لتوفير التحويل
    abortTransactionOnError: true,  // إيقاف التعاملات عند الخطأ مباشرة
  },
  pool: {
    max: 50,        // زيادة الاتصالات المتزامنة للسرعة القصوى
    min: 5,         // حد أدنى أكبر من الاتصالات الجاهزة دائماً
    idleTimeoutMillis: 30000,  // إبقاء الاتصالات أطول لتقليل إعادة الإنشاء
    acquireTimeoutMillis: 15000, // وقت أطول للحصول على اتصال من الـ pool
  },
  connectionTimeout: 15000,  // timeout أطول للاتصال بالداتابيس
  requestTimeout: 15000      // timeout أطول لتنفيذ الاستعلامات المعقدة
};

// Add authentication based on mode
if (useWindowsAuth) {
  // Windows Authentication
  config.authentication = {
    type: 'ntlm',
    options: {
      domain: '',
      userName: '',
      password: ''
    }
  };
  console.log('🔐 Using Windows Authentication');
} else {
  // SQL Server Authentication
  config.user = process.env.DB_USER;
  config.password = process.env.DB_PASSWORD || '';
  config.port = parseInt(process.env.DB_PORT || '1433');
  console.log('🔐 Using SQL Server Authentication');
}

let pool = null;

async function getConnection() {
  try {
    if (pool && pool.connected) {
      return pool;
    }
    pool = await sql.connect(config);
    console.log('✅ Connected to SQL Server 2008');
    return pool;
  } catch (err) {
    console.error('❌ Database connection failed:', err.message);
    throw err;
  }
}

async function closeConnection() {
  try {
    if (pool) {
      await pool.close();
      pool = null;
      console.log('Database connection closed');
    }
  } catch (err) {
    console.error('Error closing database connection:', err);
  }
}

module.exports = {
  sql,
  getConnection,
  closeConnection
};
