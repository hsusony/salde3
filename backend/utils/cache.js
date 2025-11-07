/**
 * ===================================================
 * نظام الـ Cache لتسريع البيانات المستخدمة بكثرة
 * ===================================================
 * 
 * يخزن البيانات في الذاكرة لمدة محددة لتقليل استعلامات قاعدة البيانات
 */

class Cache {
  constructor() {
    this.store = new Map();
    this.ttl = 5 * 60 * 1000; // 5 دقائق افتراضي
  }

  /**
   * تخزين بيانات في الـ cache
   * @param {string} key - المفتاح
   * @param {any} data - البيانات
   * @param {number} ttl - وقت الانتهاء بالميلي ثانية (اختياري)
   */
  set(key, data, ttl = null) {
    const expiresAt = Date.now() + (ttl || this.ttl);
    this.store.set(key, {
      data,
      expiresAt
    });
  }

  /**
   * استرجاع بيانات من الـ cache
   * @param {string} key - المفتاح
   * @returns {any|null} البيانات أو null إذا انتهت الصلاحية
   */
  get(key) {
    const item = this.store.get(key);
    
    if (!item) {
      return null;
    }

    // فحص انتهاء الصلاحية
    if (Date.now() > item.expiresAt) {
      this.store.delete(key);
      return null;
    }

    return item.data;
  }

  /**
   * حذف بيانات من الـ cache
   * @param {string} key - المفتاح
   */
  delete(key) {
    this.store.delete(key);
  }

  /**
   * حذف جميع البيانات من الـ cache
   */
  clear() {
    this.store.clear();
  }

  /**
   * حذف البيانات المنتهية الصلاحية
   */
  cleanup() {
    const now = Date.now();
    for (const [key, item] of this.store.entries()) {
      if (now > item.expiresAt) {
        this.store.delete(key);
      }
    }
  }

  /**
   * إضافة أو استرجاع من الـ cache
   * @param {string} key - المفتاح
   * @param {Function} fetchFn - دالة لجلب البيانات إذا لم تكن موجودة
   * @param {number} ttl - وقت الانتهاء (اختياري)
   * @returns {Promise<any>} البيانات
   */
  async getOrFetch(key, fetchFn, ttl = null) {
    // محاولة الحصول من الـ cache أولاً
    const cached = this.get(key);
    if (cached !== null) {
      console.log(`✅ Cache HIT: ${key}`);
      return cached;
    }

    // جلب البيانات من قاعدة البيانات
    console.log(`❌ Cache MISS: ${key} - جلب من قاعدة البيانات`);
    const data = await fetchFn();
    
    // تخزين في الـ cache
    this.set(key, data, ttl);
    
    return data;
  }
}

// إنشاء instance واحد للـ cache
const cache = new Cache();

// تنظيف الـ cache كل 10 دقائق
setInterval(() => {
  cache.cleanup();
  console.log('🧹 تم تنظيف الـ Cache');
}, 10 * 60 * 1000);

module.exports = cache;
