import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/products_provider.dart';
import '../providers/theme_provider.dart';
import '../models/product.dart';
import '../widgets/product_form_dialog.dart';
import '../services/user_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  final _currencyFormat =
      NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Load products after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إدارة المنتجات',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 4),
                      Consumer<ProductsProvider>(
                        builder: (context, provider, _) => Text(
                          'إجمالي المنتجات: ${provider.products.length}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      hintText: 'بحث عن منتج...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                Provider.of<ProductsProvider>(context,
                                        listen: false)
                                    .searchProducts('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      Provider.of<ProductsProvider>(context, listen: false)
                          .searchProducts(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showProductDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('إضافة منتج جديد'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: Consumer<ProductsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد منتجات',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ابدأ بإضافة منتج جديد',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    final product = provider.products[index];
                    return _buildProductCard(context, product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showProductDialog(context, product: product),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Product Image/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ThemeProvider.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.inventory_2_rounded,
                            color: ThemeProvider.primaryColor,
                            size: 40,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.inventory_2_rounded,
                        color: ThemeProvider.primaryColor,
                        size: 40,
                      ),
              ),
              const SizedBox(width: 20),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if (product.isLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                                  ThemeProvider.warningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  color: ThemeProvider.warningColor,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'مخزون منخفض',
                                  style: TextStyle(
                                    color: ThemeProvider.warningColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.category_rounded,
                          product.category,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.qr_code_rounded,
                          product.barcode,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.inventory_rounded,
                          '${product.quantity} قطعة',
                          color: product.isLowStock
                              ? ThemeProvider.errorColor
                              : ThemeProvider.successColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Pricing & Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'سعر البيع',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  Text(
                    _currencyFormat.format(product.sellingPrice),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: ThemeProvider.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'سعر الشراء: ${_currencyFormat.format(product.purchasePrice)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ThemeProvider.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ربح: ${product.profitMargin.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: ThemeProvider.successColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () =>
                            _showProductDialog(context, product: product),
                        icon: const Icon(Icons.edit_rounded),
                        tooltip: 'تعديل',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              ThemeProvider.primaryColor.withOpacity(0.1),
                          foregroundColor: ThemeProvider.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _deleteProduct(context, product),
                        icon: const Icon(Icons.delete_rounded),
                        tooltip: 'حذف',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              ThemeProvider.errorColor.withOpacity(0.1),
                          foregroundColor: ThemeProvider.errorColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDialog(BuildContext context, {Product? product}) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );
  }

  void _deleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المنتج "${product.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final userName = UserService.instance.currentUserName;
                await Provider.of<ProductsProvider>(context, listen: false)
                    .deleteProduct(product.id!, userName: userName);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف المنتج بنجاح')),
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
