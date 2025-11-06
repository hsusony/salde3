const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config();

const { getConnection, closeConnection } = require('./config/database');
const { errorHandler, notFound } = require('./middleware/errorHandler');
const { requestLogger, performanceMonitor } = require('./middleware/logger');
const { sanitizeInput } = require('./middleware/validator');

const app = express();
const PORT = process.env.PORT || 3000;

// ============ MIDDLEWARE ============

// CORS - السماح بالطلبات من أي مصدر
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Body Parser - معالجة JSON والبيانات
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '10mb' }));

// Custom Middleware
app.use(requestLogger);        // تسجيل الطلبات
app.use(performanceMonitor);   // قياس الأداء
app.use(sanitizeInput);        // تنظيف البيانات

// ============ ROUTES ============

const productsRouter = require('./routes/products');
const customersRouter = require('./routes/customers');
const salesRouter = require('./routes/sales');
const backupRouter = require('./routes/backup');
const purchasesRouter = require('./routes/purchases');
const suppliersRouter = require('./routes/suppliers');
const warehousesRouter = require('./routes/warehouses');
const inventoryRouter = require('./routes/inventory');
const installmentsRouter = require('./routes/installments');

app.use('/api/products', productsRouter);
app.use('/api/customers', customersRouter);
app.use('/api/sales', salesRouter);
app.use('/api/backup', backupRouter);
app.use('/api/purchases', purchasesRouter);
app.use('/api/suppliers', suppliersRouter);
app.use('/api/warehouses', warehousesRouter);
app.use('/api/inventory', inventoryRouter);
app.use('/api/installments', installmentsRouter);

// ============ API ENDPOINTS ============

// Health check - فحص صحة الـ API والاتصال بقاعدة البيانات
app.get('/api/health', async (req, res) => {
  try {
    const pool = await getConnection();
    const result = await pool.request().query('SELECT @@VERSION as version, DB_NAME() as dbname');
    
    res.json({ 
      status: 'OK',
      message: 'Connected to SQL Server 2008',
      database: result.recordset[0].dbname,
      timestamp: new Date(),
      uptime: process.uptime()
    });
  } catch (err) {
    res.status(500).json({ 
      status: 'ERROR', 
      message: err.message,
      timestamp: new Date()
    });
  }
});

// API Info - معلومات عن الـ API
app.get('/api', (req, res) => {
  res.json({
    name: 'Sales Management System API',
    version: '2.0.0',
    description: 'Professional REST API for Sales Management with SQL Server 2008',
    endpoints: {
      health: {
        path: '/api/health',
        method: 'GET',
        description: 'Check API and database health'
      },
      products: {
        path: '/api/products',
        methods: ['GET', 'POST', 'PUT', 'DELETE'],
        description: 'Manage products'
      },
      customers: {
        path: '/api/customers',
        methods: ['GET', 'POST', 'PUT', 'DELETE'],
        description: 'Manage customers'
      },
      sales: {
        path: '/api/sales',
        methods: ['GET', 'POST'],
        description: 'Manage sales'
      },
      purchases: {
        path: '/api/purchases',
        methods: ['GET', 'POST', 'PUT', 'DELETE'],
        description: 'Manage purchases'
      },
      suppliers: {
        path: '/api/suppliers',
        methods: ['GET', 'POST', 'PUT', 'DELETE'],
        description: 'Manage suppliers'
      },
      warehouses: {
        path: '/api/warehouses',
        methods: ['GET', 'POST', 'PUT', 'DELETE'],
        description: 'Manage warehouses'
      },
      inventory: {
        path: '/api/inventory',
        methods: ['GET', 'POST'],
        description: 'Manage inventory transactions'
      },
      installments: {
        path: '/api/installments',
        methods: ['GET', 'POST', 'PUT', 'DELETE'],
        description: 'Manage installments and payments'
      },
      backup: {
        path: '/api/backup',
        methods: ['GET', 'POST'],
        description: 'Database backup and restore'
      }
    },
    documentation: 'http://localhost:' + PORT + '/api'
  });
});

// Root endpoint - توجيه للـ API
app.get('/', (req, res) => {
  res.redirect('/api');
});

// ============ ERROR HANDLING ============

// 404 Handler
app.use(notFound);

// Global Error Handler
app.use(errorHandler);

// ============ SERVER START ============

app.listen(PORT, async () => {
  console.log('═'.repeat(60));
  console.log('🚀 Sales Management System API - v2.0');
  console.log('═'.repeat(60));
  console.log(`📡 Server URL: http://localhost:${PORT}`);
  console.log(`� API Docs: http://localhost:${PORT}/api`);
  console.log(`🏥 Health Check: http://localhost:${PORT}/api/health`);
  console.log('═'.repeat(60));
  
  try {
    const pool = await getConnection();
    const result = await pool.request().query('SELECT DB_NAME() as db, @@VERSION as version');
    console.log(`✅ Database: ${result.recordset[0].db}`);
    console.log('✅ SQL Server Connection: SUCCESS');
    console.log('═'.repeat(60));
    console.log('🎯 Server is ready to accept requests!');
    console.log('═'.repeat(60));
  } catch (err) {
    console.log('═'.repeat(60));
    console.error('❌ Database Connection: FAILED');
    console.error('⚠️  Error:', err.message);
    console.log('⚠️  Server is running but database is not connected');
    console.log('═'.repeat(60));
  }
});

// ============ GRACEFUL SHUTDOWN ============

const shutdown = async (signal) => {
  console.log(`\n${'═'.repeat(60)}`);
  console.log(`🛑 Received ${signal} - Shutting down gracefully...`);
  console.log('═'.repeat(60));
  
  try {
    await closeConnection();
    console.log('✅ Database connection closed');
    console.log('✅ Server shut down successfully');
    console.log('═'.repeat(60));
    process.exit(0);
  } catch (err) {
    console.error('❌ Error during shutdown:', err);
    process.exit(1);
  }
};

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

// Handle uncaught errors
process.on('uncaughtException', (err) => {
  console.error('❌ Uncaught Exception:', err);
  shutdown('UNCAUGHT EXCEPTION');
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
});
