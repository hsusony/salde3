import 'package:flutter/foundation.dart';
import '../models/account_master.dart';

class AccountMastersProvider with ChangeNotifier {
  List<AccountMaster> _accountMasters = [];
  bool _isLoading = false;

  List<AccountMaster> get accountMasters => [..._accountMasters];
  bool get isLoading => _isLoading;

  // الحسابات الافتراضية من القائمة المرفقة
  final List<Map<String, dynamic>> _defaultAccounts = [
    {'number': '1121', 'name': 'مباني', 'category': 'أصول ثابتة'},
    {'number': '1130', 'name': 'الات ومعدات', 'category': 'أصول ثابتة'},
    {'number': '1141', 'name': 'وسائل نقل وانتقال', 'category': 'أصول ثابتة'},
    {'number': '1143', 'name': 'عربات نقل اخرى', 'category': 'أصول ثابتة'},
    {'number': '1161', 'name': 'اثاث', 'category': 'أصول ثابتة'},
    {'number': '1162', 'name': 'اجهزة تكييف وتبريد', 'category': 'أصول ثابتة'},
    {'number': '1163', 'name': 'حاسبات الكترونية', 'category': 'أصول ثابتة'},
    {
      'number': '1164',
      'name': 'الات حاسبة وكاتبة واستنساخ',
      'category': 'أصول ثابتة'
    },
    {'number': '1165', 'name': 'ادوات واجهزة مكاتب', 'category': 'أصول ثابتة'},
    {'number': '1166', 'name': 'ستائر ومفروشات', 'category': 'أصول ثابتة'},
    {
      'number': '1168',
      'name': 'الخزائن الحديدية والقاصات',
      'category': 'أصول ثابتة'
    },
    {'number': '1169', 'name': 'اجهزة ومطافى حديد', 'category': 'أصول ثابتة'},
    {'number': '1182', 'name': 'نفقات قبل التشغيل', 'category': 'أصول ثابتة'},
    {
      'number': '1186',
      'name': 'ديكورات وتركيبات وقواطع',
      'category': 'أصول ثابتة'
    },
    {
      'number': '1286',
      'name': 'ديكورات وتركيبات وقواطع غير مستخدمة',
      'category': 'أصول ثابتة'
    },
    {
      'number': '1292',
      'name': 'اعتمادات مستندية لموجودات ثابتة',
      'category': 'أصول ثابتة'
    },
    {'number': '1310', 'name': 'بضاعة اول المدة', 'category': 'أصول متداولة'},
    {'number': '1320', 'name': 'بضاعة اخر المدة', 'category': 'أصول متداولة'},
    {
      'number': '1340',
      'name': 'مخزون البضاعة بالكلفة',
      'category': 'أصول متداولة'
    },
    {'number': '1350', 'name': 'تلف المواد', 'category': 'أصول متداولة'},
    {
      'number': '1371',
      'name': 'مخزون البضائع بغرض البيع',
      'category': 'أصول متداولة'
    },
    {'number': '1610', 'name': 'زبون نقدي', 'category': 'مدينون'},
    {'number': '1611', 'name': 'مدينون/قطاع حكومي', 'category': 'مدينون'},
    {
      'number': '1612',
      'name': 'مدينون/قطاع اشتراكي انتاجي',
      'category': 'مدينون'
    },
    {'number': '1811', 'name': 'نقد في صناديق الفروع', 'category': 'نقدية'},
    {'number': '1812', 'name': 'نقد في الخزينة', 'category': 'نقدية'},
    {'number': '2100', 'name': 'حساب راسمال', 'category': 'حقوق الملكية'},
    {'number': '2110', 'name': 'رأس المال المدفوع', 'category': 'حقوق الملكية'},
    {'number': '2610', 'name': 'مورد نقدي', 'category': 'دائنون'},
    {
      'number': '2810',
      'name': 'حساب الارباح والخسائر',
      'category': 'حقوق الملكية'
    },
    {
      'number': '2811',
      'name': 'ارباح وخسائر مدورة',
      'category': 'حقوق الملكية'
    },
    {'number': '3110', 'name': 'المشتريات', 'category': 'مصروفات'},
    {'number': '3120', 'name': 'مردودات المشتريات', 'category': 'مصروفات'},
    {'number': '3121', 'name': 'اجور العاملين', 'category': 'مصروفات'},
    {'number': '3220', 'name': 'الوقود والزيوت', 'category': 'مصروفات'},
    {'number': '3271', 'name': 'المياه', 'category': 'مصروفات'},
    {'number': '3272', 'name': 'الكهرباء', 'category': 'مصروفات'},
    {'number': '3312', 'name': 'صيانة مباني', 'category': 'مصروفات'},
    {'number': '3313', 'name': 'صيانة الات ومعدات', 'category': 'مصروفات'},
    {'number': '3331', 'name': 'دعاية واعلان', 'category': 'مصروفات'},
    {'number': '3332', 'name': 'نشر وطبع', 'category': 'مصروفات'},
    {'number': '3333', 'name': 'ضيافة', 'category': 'مصروفات'},
    {'number': '4110', 'name': 'ايرادات المبيعات', 'category': 'إيرادات'},
    {'number': '4120', 'name': 'مردودات المبيعات', 'category': 'إيرادات'},
    {'number': '4130', 'name': 'الخصم المكتسب', 'category': 'إيرادات'},
    {'number': '4910', 'name': 'ايرادات سنوات سابقة', 'category': 'إيرادات'},
    {'number': '4920', 'name': 'ايرادات عرضية', 'category': 'إيرادات'},
    {'number': '9000', 'name': 'حساب الفروقات', 'category': 'حسابات خاصة'},
  ];

  Future<void> loadAccountMasters() async {
    _isLoading = true;
    notifyListeners();

    try {
      // محاكاة تحميل البيانات - في المستقبل سيكون من قاعدة البيانات
      await Future.delayed(const Duration(milliseconds: 500));

      // تحميل الحسابات الافتراضية إذا كانت القائمة فارغة
      if (_accountMasters.isEmpty) {
        _accountMasters = _defaultAccounts.map((acc) {
          return AccountMaster(
            accountNumber: acc['number'],
            accountName: acc['name'],
            category: acc['category'],
            canUse: true,
            canDelete: false,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error loading account masters: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAccountMaster(AccountMaster accountMaster) async {
    try {
      final newAccountMaster = accountMaster.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now(),
      );
      _accountMasters.add(newAccountMaster);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding account master: $e');
      rethrow;
    }
  }

  Future<void> updateAccountMaster(AccountMaster accountMaster) async {
    try {
      final index = _accountMasters.indexWhere((a) => a.id == accountMaster.id);
      if (index != -1) {
        _accountMasters[index] = accountMaster.copyWith(
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating account master: $e');
      rethrow;
    }
  }

  Future<void> deleteAccountMaster(int id) async {
    try {
      _accountMasters.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting account master: $e');
      rethrow;
    }
  }

  // البحث في الحسابات
  List<AccountMaster> searchAccounts(String query) {
    if (query.isEmpty) return accountMasters;

    final lowerQuery = query.toLowerCase();
    return _accountMasters.where((account) {
      return account.accountNumber.contains(lowerQuery) ||
          account.accountName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // الحصول على حساب برقمه
  AccountMaster? getAccountByNumber(String accountNumber) {
    try {
      return _accountMasters.firstWhere(
        (account) => account.accountNumber == accountNumber,
      );
    } catch (e) {
      return null;
    }
  }

  // الحسابات حسب التصنيف
  List<AccountMaster> getAccountsByCategory(String category) {
    return _accountMasters
        .where((account) => account.category == category)
        .toList();
  }
}
