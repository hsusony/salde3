import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/purchases_provider.dart';
import '../providers/theme_provider.dart';
import '../models/purchase.dart';
import '../models/purchase_return.dart';
import '../widgets/purchase_form_dialog.dart';
import '../widgets/purchase_return_form_dialog.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _currencyFormat =
      NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);
  final _dateFormat = DateFormat('yyyy/MM/dd - HH:mm', 'ar');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PurchasesProvider>(context, listen: false).loadPurchases();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إدارة المشتريات',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 4),
                          Consumer<PurchasesProvider>(
                            builder: (context, provider, _) => Text(
                              'إجمالي المشتريات: ${provider.purchases.length} | الإرجاعات: ${provider.returns.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Search
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'بحث...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    Provider.of<PurchasesProvider>(context,
                                            listen: false)
                                        .searchPurchases('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          Provider.of<PurchasesProvider>(context, listen: false)
                              .searchPurchases(value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tabs
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: ThemeProvider.primaryColor,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[700],
                    tabs: const [
                      Tab(text: 'قائمة المشتريات'),
                      Tab(text: 'قائمة الإرجاعات'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPurchasesList(),
                _buildReturnsList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tabController.index == 0
            ? _showPurchaseDialog(context)
            : _showReturnDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(_tabController.index == 0 ? 'إضافة شراء' : 'إضافة إرجاع'),
        backgroundColor: ThemeProvider.primaryColor,
      ),
    );
  }

  Widget _buildPurchasesList() {
    return Consumer<PurchasesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.purchases.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد مشتريات',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'اضغط على زر "إضافة شراء" لإضافة فاتورة جديدة',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: provider.purchases.length,
          itemBuilder: (context, index) {
            final purchase = provider.purchases[index];
            return _buildPurchaseCard(context, purchase);
          },
        );
      },
    );
  }

  Widget _buildReturnsList() {
    return Consumer<PurchasesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.returns.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_return_outlined,
                    size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد إرجاعات',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'اضغط على زر "إضافة إرجاع" لإضافة إرجاع جديد',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: provider.returns.length,
          itemBuilder: (context, index) {
            final returnItem = provider.returns[index];
            return _buildReturnCard(context, returnItem);
          },
        );
      },
    );
  }

  Widget _buildPurchaseCard(BuildContext context, Purchase purchase) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showPurchaseDialog(context, purchase: purchase),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: ThemeProvider.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_rounded,
                      color: ThemeProvider.primaryColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'فاتورة #${purchase.invoiceNumber}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: purchase.status == 'completed'
                                    ? ThemeProvider.successColor
                                        .withOpacity(0.1)
                                    : ThemeProvider.warningColor
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                purchase.status == 'completed'
                                    ? 'مكتملة'
                                    : 'معلقة',
                                style: TextStyle(
                                  color: purchase.status == 'completed'
                                      ? ThemeProvider.successColor
                                      : ThemeProvider.warningColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (purchase.supplierName != null)
                          Text(
                            'المورد: ${purchase.supplierName}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          _dateFormat.format(purchase.createdAt),
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'عدد المنتجات',
                      '${purchase.items.length}',
                      Icons.inventory_rounded,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'الإجمالي',
                      _currencyFormat.format(purchase.finalAmount),
                      Icons.attach_money_rounded,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'طريقة الدفع',
                      purchase.paymentMethod,
                      Icons.payment_rounded,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        _showPurchaseDialog(context, purchase: purchase),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('تعديل'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _deletePurchase(context, purchase),
                    icon: const Icon(Icons.delete_rounded),
                    label: const Text('حذف'),
                    style: TextButton.styleFrom(
                      foregroundColor: ThemeProvider.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReturnCard(BuildContext context, PurchaseReturn returnItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showReturnDialog(context, returnItem: returnItem),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.assignment_return_rounded,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إرجاع #${returnItem.returnNumber}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        if (returnItem.purchaseInvoiceNumber != null)
                          Text(
                            'فاتورة الشراء: ${returnItem.purchaseInvoiceNumber}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        if (returnItem.supplierName != null)
                          Text(
                            'المورد: ${returnItem.supplierName}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          _dateFormat.format(returnItem.createdAt),
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'عدد المنتجات',
                      '${returnItem.items.length}',
                      Icons.inventory_rounded,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'المبلغ',
                      _currencyFormat.format(returnItem.totalAmount),
                      Icons.attach_money_rounded,
                      Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'السبب',
                      returnItem.reason,
                      Icons.info_rounded,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        _showReturnDialog(context, returnItem: returnItem),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('تعديل'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _deleteReturn(context, returnItem),
                    icon: const Icon(Icons.delete_rounded),
                    label: const Text('حذف'),
                    style: TextButton.styleFrom(
                      foregroundColor: ThemeProvider.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showPurchaseDialog(BuildContext context, {Purchase? purchase}) {
    showDialog(
      context: context,
      builder: (context) => PurchaseFormDialog(purchase: purchase),
    );
  }

  void _showReturnDialog(BuildContext context, {PurchaseReturn? returnItem}) {
    showDialog(
      context: context,
      builder: (context) =>
          PurchaseReturnFormDialog(purchaseReturn: returnItem),
    );
  }

  void _deletePurchase(BuildContext context, Purchase purchase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
            'هل أنت متأكد من حذف فاتورة الشراء "${purchase.invoiceNumber}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<PurchasesProvider>(context, listen: false)
                    .deletePurchase(purchase.id!);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف الفاتورة بنجاح')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في الحذف: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeProvider.errorColor,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _deleteReturn(BuildContext context, PurchaseReturn returnItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content:
            Text('هل أنت متأكد من حذف الإرجاع "${returnItem.returnNumber}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<PurchasesProvider>(context, listen: false)
                    .deleteReturn(returnItem.id!);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف الإرجاع بنجاح')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في الحذف: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeProvider.errorColor,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
