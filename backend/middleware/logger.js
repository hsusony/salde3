/**
 * Request Logger Middleware
 * تسجيل جميع الطلبات بشكل احترافي
 */

const fs = require('fs');
const path = require('path');

// Create logs directory if it doesn't exist
const logsDir = path.join(__dirname, '../logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

// Get log file path for today
const getLogFilePath = () => {
  const today = new Date().toISOString().split('T')[0];
  return path.join(logsDir, `${today}.log`);
};

// Format log message
const formatLog = (req, res, duration) => {
  const timestamp = new Date().toISOString();
  const method = req.method;
  const url = req.originalUrl || req.url;
  const status = res.statusCode;
  const ip = req.ip || req.connection.remoteAddress;
  
  return `[${timestamp}] ${method} ${url} ${status} ${duration}ms - IP: ${ip}\n`;
};

// Request Logger
const requestLogger = (req, res, next) => {
  const startTime = Date.now();
  
  // Log to console
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} ${req.path}`);
  
  // Capture response
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    const logMessage = formatLog(req, res, duration);
    
    // Log to file
    try {
      fs.appendFileSync(getLogFilePath(), logMessage);
    } catch (err) {
      console.error('Error writing to log file:', err);
    }
    
    // Log slow requests
    if (duration > 1000) {
      console.warn(`⚠️  SLOW REQUEST: ${req.method} ${req.path} took ${duration}ms`);
    }
  });
  
  next();
};

// Performance Monitor
const performanceMonitor = (req, res, next) => {
  const start = process.hrtime();
  
  const originalSend = res.send;
  res.send = function(data) {
    const [seconds, nanoseconds] = process.hrtime(start);
    const duration = (seconds * 1000 + nanoseconds / 1000000).toFixed(2);
    
    if (!res.headersSent) {
      res.setHeader('X-Response-Time', `${duration}ms`);
    }
    
    originalSend.call(this, data);
  };
  
  next();
};

// Get logs (for admin)
const getLogs = async (req, res) => {
  try {
    const { date } = req.query;
    const logFile = date 
      ? path.join(logsDir, `${date}.log`)
      : getLogFilePath();
    
    if (!fs.existsSync(logFile)) {
      return res.status(404).json({ 
        error: 'Log file not found',
        message: 'لا توجد سجلات لهذا التاريخ'
      });
    }
    
    const logs = fs.readFileSync(logFile, 'utf8');
    const lines = logs.split('\n').filter(line => line.trim());
    
    res.json({
      date: date || new Date().toISOString().split('T')[0],
      totalRequests: lines.length,
      logs: lines
    });
  } catch (err) {
    res.status(500).json({ 
      error: err.message,
      message: 'خطأ في قراءة السجلات'
    });
  }
};

module.exports = {
  requestLogger,
  performanceMonitor,
  getLogs
};
