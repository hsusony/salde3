import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'screens/home_screen.dart';
import 'screens/pos_screen.dart';
import 'screens/sales_screen.dart';

// Conditional imports for desktop

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Arabic locale
  await initializeDateFormatting('ar', null);

  // Initialize database only for desktop platforms
  if (!kIsWeb) {
    try {
      await initializeDatabase();
    } catch (e) {
      debugPrint('Database initialization skipped on web: $e');
    }
  }

  // Initialize CashProvider and load data BEFORE running app
  final cashProvider = CashProvider();
  print('🚀 بدء تحميل بيانات النقد...');
  await cashProvider.loadData();
  print('✅ اكتمل تحميل بيانات النقد!');

  runApp(SalesManagementApp(cashProvider: cashProvider));
}

Future<void> initializeDatabase() async {
  // This will be implemented in database_helper.dart for desktop
  // and stub for web
  if (!kIsWeb) {
    // Database initialization happens in database_helper.dart
  }
}

class SalesManagementApp extends StatelessWidget {
  final CashProvider cashProvider;

  const SalesManagementApp({super.key, required this.cashProvider});

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
        ChangeNotifierProvider.value(
          value: cashProvider, // Use pre-loaded instance
        ),
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
            },
          );
        },
      ),
    );
  }
}
