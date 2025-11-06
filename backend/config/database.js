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
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
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
