/**
 * Error Handler Middleware
 * معالج الأخطاء المركزي
 */

// Custom Error Class
class AppError extends Error {
  constructor(message, statusCode, isArabic = false) {
    super(message);
    this.statusCode = statusCode;
    this.isArabic = isArabic;
    this.isOperational = true;
    
    Error.captureStackTrace(this, this.constructor);
  }
}

// Async Handler - لتجنب try/catch في كل route
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

// Database Error Handler
const handleDatabaseError = (err) => {
  // SQL Server errors
  if (err.code === 'EREQUEST') {
    return new AppError('خطأ في قاعدة البيانات: ' + err.message, 500, true);
  }
  
  if (err.code === 'ELOGIN') {
    return new AppError('فشل الاتصال بقاعدة البيانات', 500, true);
  }
  
  if (err.code === 'ETIMEOUT') {
    return new AppError('انتهت مهلة الاتصال بقاعدة البيانات', 504, true);
  }
  
  if (err.code === 'ECONNREFUSED') {
    return new AppError('تعذر الاتصال بقاعدة البيانات', 503, true);
  }
  
  return new AppError('خطأ في قاعدة البيانات', 500, true);
};

// Main Error Handler
const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;
  
  // Log error for debugging
  console.error('═'.repeat(60));
  console.error('❌ ERROR DETAILS:');
  console.error('Path:', req.path);
  console.error('Method:', req.method);
  console.error('Message:', err.message);
  console.error('Stack:', err.stack);
  console.error('═'.repeat(60));
  
  // Database errors
  if (err.code && (err.code.startsWith('E') || err.number)) {
    error = handleDatabaseError(err);
  }
  
  // Validation errors
  if (err.name === 'ValidationError') {
    error = new AppError('خطأ في البيانات المدخلة', 400, true);
  }
  
  // Not found errors
  if (err.name === 'NotFoundError') {
    error = new AppError('العنصر المطلوب غير موجود', 404, true);
  }
  
  // Send error response
  res.status(error.statusCode || 500).json({
    success: false,
    error: error.isArabic ? error.message : 'حدث خطأ في الخادم',
    message: error.message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    timestamp: new Date().toISOString()
  });
};

// Not Found Handler
const notFound = (req, res, next) => {
  const error = new AppError(`المسار ${req.originalUrl} غير موجود`, 404, true);
  next(error);
};

module.exports = {
  AppError,
  asyncHandler,
  errorHandler,
  notFound,
  handleDatabaseError
};
