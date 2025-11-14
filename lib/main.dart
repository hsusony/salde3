import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/products_provider.dart';
import 'providers/customers_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/installments_provider.dart';
import 'providers/purchases_provider.dart';
import 'providers/cash_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/quotations_provider.dart';
import 'providers/pending_orders_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/warehouses_provider.dart';
import 'providers/account_masters_provider.dart';
import 'screens/home_screen.dart';
import 'screens/pos_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/sales_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Arabic locale
  await initializeDateFormatting('ar', null);

  // ملاحظة: تم إزالة SQLite - الآن نستخدم SQL Server 2008 فقط
  // للاتصال بـ SQL Server، يجب إنشاء REST API أولاً
  print('النظام معد للعمل مع SQL Server 2008');
  print('تأكد من تشغيل قاعدة البيانات والـ API');

  runApp(const SalesManagementApp());
}

class SalesManagementApp extends StatelessWidget {
  const SalesManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CustomersProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => InstallmentsProvider()),
        ChangeNotifierProvider(create: (_) => PurchasesProvider()),
        ChangeNotifierProvider(create: (_) => QuotationsProvider()),
        ChangeNotifierProvider(create: (_) => PendingOrdersProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => CashProvider()),
        ChangeNotifierProvider(create: (_) => WarehousesProvider()),
        ChangeNotifierProvider(create: (_) => AccountMastersProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'نظام إدارة المبيعات',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
            routes: {
              '/pos': (context) => const POSScreen(),
              '/sales': (context) => const SalesScreen(),
              '/sales-list': (context) => const SalesListScreen(),
            },
          );
        },
      ),
    );
  }
}
