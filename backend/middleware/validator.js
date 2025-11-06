/**
 * Request Validator Middleware
 * التحقق من صحة البيانات المدخلة
 */

const { AppError } = require('./errorHandler');

// Validate Product Data
const validateProduct = (req, res, next) => {
  const { Name, SellingPrice } = req.body;
  
  if (!Name || Name.trim() === '') {
    return next(new AppError('اسم المنتج مطلوب', 400, true));
  }
  
  if (!SellingPrice || SellingPrice <= 0) {
    return next(new AppError('سعر البيع يجب أن يكون أكبر من صفر', 400, true));
  }
  
  next();
};

// Validate Customer Data
const validateCustomer = (req, res, next) => {
  const { Name, Phone } = req.body;
  
  if (!Name || Name.trim() === '') {
    return next(new AppError('اسم العميل مطلوب', 400, true));
  }
  
  if (!Phone || Phone.trim() === '') {
    return next(new AppError('رقم الهاتف مطلوب', 400, true));
  }
  
  // Phone validation (Iraqi numbers)
  const phoneRegex = /^(07[3-9]\d{8}|(\+964|00964)7[3-9]\d{8})$/;
  if (!phoneRegex.test(Phone.replace(/\s/g, ''))) {
    return next(new AppError('رقم الهاتف غير صحيح', 400, true));
  }
  
  next();
};

// Validate Sale Data
const validateSale = (req, res, next) => {
  const { CustomerID, TotalAmount, Items } = req.body;
  
  if (!CustomerID) {
    return next(new AppError('معرف العميل مطلوب', 400, true));
  }
  
  if (!TotalAmount || TotalAmount <= 0) {
    return next(new AppError('المبلغ الإجمالي يجب أن يكون أكبر من صفر', 400, true));
  }
  
  if (!Items || !Array.isArray(Items) || Items.length === 0) {
    return next(new AppError('يجب إضافة منتج واحد على الأقل', 400, true));
  }
  
  // Validate each item
  for (let i = 0; i < Items.length; i++) {
    const item = Items[i];
    if (!item.ProductID || !item.Quantity || item.Quantity <= 0) {
      return next(new AppError(`بيانات المنتج رقم ${i + 1} غير صحيحة`, 400, true));
    }
  }
  
  next();
};

// Validate ID Parameter
const validateId = (paramName = 'id') => {
  return (req, res, next) => {
    const id = parseInt(req.params[paramName]);
    
    if (!id || isNaN(id) || id <= 0) {
      return next(new AppError('المعرف غير صحيح', 400, true));
    }
    
    req.params[paramName] = id;
    next();
  };
};

// Sanitize Input - تنظيف البيانات من أكواد خطيرة
const sanitizeInput = (req, res, next) => {
  if (req.body) {
    Object.keys(req.body).forEach(key => {
      if (typeof req.body[key] === 'string') {
        // Remove SQL injection attempts
        req.body[key] = req.body[key]
          .replace(/(\-\-|;|\/\*|\*\/|xp_|sp_|exec|execute|declare|drop|create|insert|delete|update|union|select)/gi, '')
          .trim();
      }
    });
  }
  next();
};

module.exports = {
  validateProduct,
  validateCustomer,
  validateSale,
  validateId,
  sanitizeInput
};
