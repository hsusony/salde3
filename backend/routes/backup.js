const express = require('express');
const router = express.Router();
const { getConnection, sql } = require('../config/database');
const path = require('path');
const fs = require('fs');

// Create backup
router.post('/create', async (req, res) => {
  try {
    let { backupPath } = req.body;
    
    if (!backupPath) {
      return res.status(400).json({ error: 'Backup path is required' });
    }

    // التأكد من أن المسار ينتهي بـ .bak
    if (!backupPath.toLowerCase().endsWith('.bak')) {
      backupPath += '.bak';
    }

    const pool = await getConnection();
    
    // خطوة 1: حفظ في TEMP أولاً (له صلاحيات SQL Server)
    const tempPath = `C:\\Windows\\Temp\\${path.basename(backupPath)}`;
    
    // إنشاء النسخة الاحتياطية في TEMP
    const backupQuery = `
      BACKUP DATABASE SalesManagementDB 
      TO DISK = @tempPath
      WITH FORMAT, INIT;
    `;
    
    await pool.request()
      .input('tempPath', sql.NVarChar, tempPath)
      .query(backupQuery);
    
    console.log(`✅ Backup created in temp: ${tempPath}`);
    
    // خطوة 2: نسخ الملف للموقع المطلوب
    try {
      const backupDir = path.dirname(backupPath);
      if (!fs.existsSync(backupDir)) {
        fs.mkdirSync(backupDir, { recursive: true });
      }
      
      fs.copyFileSync(tempPath, backupPath);
      
      // حذف الملف المؤقت
      try {
        fs.unlinkSync(tempPath);
      } catch (e) {
        console.log('⚠️ Could not delete temp file:', e.message);
      }
      
      console.log(`✅ Backup moved to: ${backupPath}`);
      
      res.json({ 
        success: true, 
        message: 'تم إنشاء النسخة الاحتياطية بنجاح',
        path: backupPath 
      });
      
    } catch (copyErr) {
      // إذا فشل النسخ، الملف موجود في TEMP
      console.log('⚠️ Could not copy to target, backup saved in temp');
      res.json({ 
        success: true, 
        message: 'تم إنشاء النسخة الاحتياطية في المجلد المؤقت',
        path: tempPath,
        warning: 'لم يتم النسخ للموقع المطلوب، الملف موجود في: ' + tempPath
      });
    }
    
  } catch (err) {
    console.error('❌ Backup error:', err);
    
    let errorMessage = err.message;
    if (err.message.includes('Access is denied') || err.message.includes('Operating system error 5')) {
      errorMessage = 'فشل إنشاء النسخة الاحتياطية. جرب تشغيل التطبيق كمسؤول (Run as Administrator)';
    } else if (err.message.includes('Cannot open backup device')) {
      errorMessage = 'لا يمكن إنشاء ملف النسخ الاحتياطي';
    }
    
    res.status(500).json({ 
      error: errorMessage,
      originalError: err.message 
    });
  }
});

// Restore backup
router.post('/restore', async (req, res) => {
  try {
    const { backupPath } = req.body;
    
    if (!backupPath) {
      return res.status(400).json({ error: 'Backup path is required' });
    }

    // التحقق من وجود الملف
    if (!fs.existsSync(backupPath)) {
      return res.status(404).json({ error: 'ملف النسخ الاحتياطي غير موجود' });
    }

    const pool = await getConnection();
    
    try {
      // فصل جميع الاتصالات الحالية
      await pool.request().query(`
        USE master;
        ALTER DATABASE SalesManagementDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
      `);
      
      // استعادة النسخة الاحتياطية
      await pool.request()
        .input('backupPath', sql.NVarChar, backupPath)
        .query(`
          RESTORE DATABASE SalesManagementDB 
          FROM DISK = @backupPath
          WITH REPLACE;
        `);
      
      // إعادة السماح بالاتصالات المتعددة
      await pool.request().query(`
        ALTER DATABASE SalesManagementDB SET MULTI_USER;
      `);
      
      console.log(`✅ Backup restored: ${backupPath}`);
      
      res.json({ 
        success: true, 
        message: 'تم استعادة النسخة الاحتياطية بنجاح' 
      });
      
    } catch (restoreErr) {
      // في حالة الخطأ، إعادة تفعيل الاتصالات المتعددة
      try {
        await pool.request().query(`
          USE master;
          ALTER DATABASE SalesManagementDB SET MULTI_USER;
        `);
      } catch (e) {
        console.error('Error resetting multi-user mode:', e);
      }
      throw restoreErr;
    }
    
  } catch (err) {
    console.error('❌ Restore error:', err);
    
    let errorMessage = err.message;
    if (err.message.includes('Access is denied')) {
      errorMessage = 'لا يوجد صلاحية للوصول إلى ملف النسخ الاحتياطي';
    } else if (err.message.includes('is not a valid')) {
      errorMessage = 'ملف النسخ الاحتياطي تالف أو غير صحيح';
    }
    
    res.status(500).json({ 
      error: errorMessage,
      originalError: err.message 
    });
  }
});

// List backups in default directory
router.get('/list', async (req, res) => {
  try {
    const backupDir = path.join(__dirname, '../../backups');
    
    // إنشاء المجلد إذا لم يكن موجود
    if (!fs.existsSync(backupDir)) {
      fs.mkdirSync(backupDir, { recursive: true });
    }
    
    const files = fs.readdirSync(backupDir)
      .filter(file => file.endsWith('.bak'))
      .map(file => {
        const filePath = path.join(backupDir, file);
        const stats = fs.statSync(filePath);
        return {
          name: file,
          path: filePath,
          size: stats.size,
          created: stats.birthtime,
          modified: stats.mtime
        };
      })
      .sort((a, b) => b.created - a.created);
    
    res.json(files);
    
  } catch (err) {
    console.error('❌ List backups error:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
