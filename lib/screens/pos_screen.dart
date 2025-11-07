import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../providers/products_provider.dart';
import '../providers/customers_provider.dart';
import '../providers/sales_provider.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class CartItem {
  final Product product;
  int quantity;
  double discount;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.discount = 0,
  });

  double get subtotal => product.sellingPrice * quantity;
  double get total => subtotal - discount;
}

class _POSScreenState extends State<POSScreen> {
  final _barcodeController = TextEditingController();
  final _customerController = TextEditingController();
  final _discountController = TextEditingController();
  final _currencyFormat =
      NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);

  final List<CartItem> _cart = [];
  Customer? _selectedCustomer;
  String _paymentMethod = 'نقدي';
  double _totalDiscount = 0;

  @override
  void dispose() {
    _barcodeController.dispose();
    _customerController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    setState(() {
      final existingIndex =
          _cart.indexWhere((item) => item.product.id == product.id);
      if (existingIndex != -1) {
        _cart[existingIndex].quantity++;
      } else {
        _cart.add(CartItem(product: product));
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  void _updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      _removeFromCart(index);
    } else {
      setState(() {
        _cart[index].quantity = quantity;
      });
    }
  }

  void _updateItemDiscount(int index, double discount) {
    setState(() {
      _cart[index].discount = discount;
    });
  }

  double get _subtotal {
    return _cart.fold(0, (sum, item) => sum + item.subtotal);
  }

  double get _totalItemDiscounts {
    return _cart.fold(0, (sum, item) => sum + item.discount);
  }

  double get _grandTotal {
    return _subtotal - _totalDiscount - _totalItemDiscounts;
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
      _selectedCustomer = null;
      _totalDiscount = 0;
      _discountController.clear();
      _customerController.clear();
    });
  }

  Future<void> _openBarcodeScanner() async {
    final barcodeInputController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.qr_code_scanner,
                color: Theme.of(context).primaryColor, size: 32),
            const SizedBox(width: 12),
            const Text('مسح الباركود'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'امسح الباركود باستخدام قارئ الباركود USB أو أدخل الرقم يدوياً',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Theme.of(context).primaryColor, width: 2),
              ),
              child: TextField(
                controller: barcodeInputController,
                autofocus: true,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'ادخل أو امسح الباركود',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    Navigator.pop(context);
                    _searchProductByBarcode(value);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (barcodeInputController.text.isNotEmpty) {
                Navigator.pop(context);
                _searchProductByBarcode(barcodeInputController.text);
              }
            },
            icon: const Icon(Icons.search),
            label: const Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _searchProductByBarcode(String barcode) {
    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);

    try {
      final product = productsProvider.products.firstWhere(
        (p) => p.barcode == barcode,
      );

      _addToCart(product);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة ${product.name} إلى السلة'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('المنتج غير موجود - الباركود: $barcode'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _completeSale() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('السلة فارغة - الرجاء إضافة منتجات'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final salesProvider = Provider.of<SalesProvider>(context, listen: false);

    // Create invoice number
    final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';

    // Convert cart items to sale items
    final saleItems = _cart.map((cartItem) {
      return SaleItem(
        productId: cartItem.product.id!,
        productName: cartItem.product.name,
        productBarcode: cartItem.product.barcode,
        quantity: cartItem.quantity,
        unitPrice: cartItem.product.sellingPrice,
        totalPrice: cartItem.total,
        discount: cartItem.discount,
      );
    }).toList();

    final sale = Sale(
      invoiceNumber: invoiceNumber,
      customerId: _selectedCustomer?.id,
      customerName: _selectedCustomer?.name ?? 'زبون نقدي',
      totalAmount: _subtotal,
      discount: _totalDiscount + _totalItemDiscounts,
      tax: 0,
      finalAmount: _grandTotal,
      paidAmount: _paymentMethod == 'آجل' ? 0 : _grandTotal,
      remainingAmount: _paymentMethod == 'آجل' ? _grandTotal : 0,
      paymentMethod: _paymentMethod,
      status: _paymentMethod == 'آجل' ? 'pending' : 'completed',
      items: saleItems,
    );

    try {
      await salesProvider.addSale(sale);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('✅ تم إتمام البيع بنجاح - فاتورة رقم: $invoiceNumber'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'طباعة',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Print invoice
              },
            ),
          ),
        );

        _clearCart();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ حدث خطأ: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // Right Panel - Products & Search
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1A237E), const Color(0xFF0D47A1)]
                      : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
                ),
              ),
              child: Column(
                children: [
                  _buildSearchBar(theme, isDark),
                  _buildCategoryTabs(theme, isDark),
                  Expanded(child: _buildProductGrid()),
                ],
              ),
            ),
          ),

          // Left Panel - Cart & Payment
          Expanded(
            flex: 2,
            child: Container(
              color: theme.cardColor,
              child: Column(
                children: [
                  _buildCartHeader(theme),
                  Expanded(child: _buildCartList()),
                  _buildCartSummary(theme, isDark),
                  _buildPaymentButtons(theme, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.2)
            : Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر الرجوع
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              foregroundColor: theme.primaryColor,
              padding: const EdgeInsets.all(12),
            ),
            tooltip: 'رجوع',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: TextField(
                controller: _barcodeController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'ابحث عن منتج بالاسم أو الباركود...',
                  hintStyle: TextStyle(color: theme.hintColor),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: theme.primaryColor, size: 28),
                  suffixIcon: _barcodeController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            setState(() {
                              _barcodeController.clear();
                            });
                          },
                        )
                      : null,
                ),
                onSubmitted: (value) {
                  final productsProvider =
                      Provider.of<ProductsProvider>(context, listen: false);
                  final product = productsProvider.products.firstWhere(
                    (p) => p.barcode == value || p.name.contains(value),
                    orElse: () => productsProvider.products.first,
                  );
                  _addToCart(product);
                  _barcodeController.clear();
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.7)
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _openBarcodeScanner,
              icon: const Icon(Icons.qr_code_scanner_rounded,
                  color: Colors.white, size: 32),
              padding: const EdgeInsets.all(16),
              tooltip: 'مسح الباركود',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(ThemeData theme, bool isDark) {
    final categories = [
      'الكل',
      'إلكترونيات',
      'موبايلات',
      'حواسيب',
      'إكسسوارات'
    ];

    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isActive = index == 0;
          return Padding(
            padding: const EdgeInsets.only(left: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.deepOrange.shade500
                        ],
                      )
                    : null,
                color: isActive
                    ? null
                    : (isDark ? Colors.white.withOpacity(0.1) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? Colors.transparent
                      : theme.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: MaterialButton(
                onPressed: () {},
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : (isDark ? Colors.white : theme.primaryColor),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<ProductsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: provider.products.length,
          itemBuilder: (context, index) {
            final product = provider.products[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return InkWell(
      onTap: () => _addToCart(product),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'product-${product.id}',
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: product.imageUrl == null
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade100,
                            Colors.blue.shade200,
                          ],
                        )
                      : null,
                  color: product.imageUrl != null ? Colors.grey.shade100 : null,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: product.imageUrl == null
                    ? Icon(
                        _getProductIcon(product.category),
                        size: 40,
                        color: Colors.blue.shade700,
                      )
                    : ClipOval(
                        child: product.imageUrl!.startsWith('http')
                            ? Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    _getProductIcon(product.category),
                                    size: 40,
                                    color: Colors.blue.shade700,
                                  );
                                },
                              )
                            : Icon(
                                _getProductIcon(product.category),
                                size: 40,
                                color: Colors.blue.shade700,
                              ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _currencyFormat.format(product.sellingPrice),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: product.quantity < product.minQuantity
                    ? Colors.red.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2_rounded,
                    size: 14,
                    color: product.quantity < product.minQuantity
                        ? Colors.red
                        : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${product.quantity}',
                    style: TextStyle(
                      color: product.quantity < product.minQuantity
                          ? Colors.red
                          : Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProductIcon(String category) {
    switch (category) {
      case 'إلكترونيات':
        return Icons.devices_rounded;
      case 'موبايلات':
        return Icons.smartphone_rounded;
      case 'حواسيب':
        return Icons.laptop_rounded;
      case 'إكسسوارات':
        return Icons.headphones_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  Widget _buildCartHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_cart_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'سلة المشتريات',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_cart.length} منتج',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (_cart.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _clearCart,
                icon:
                    const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                tooltip: 'إفراغ السلة',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    if (_cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'السلة فارغة',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف منتجات للبدء',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cart.length,
      itemBuilder: (context, index) {
        return _buildCartItem(_cart[index], index);
      },
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.blue.shade200],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getProductIcon(item.product.category),
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_currencyFormat.format(item.product.sellingPrice)} × ${item.quantity}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () => _removeFromCart(index),
                    icon: Icon(Icons.close_rounded,
                        size: 20, color: Colors.red.shade700),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Quantity controls
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              _updateQuantity(index, item.quantity - 1),
                          icon: const Icon(Icons.remove_rounded, size: 20),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          color: Colors.red.shade700,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              _updateQuantity(index, item.quantity + 1),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          color: Colors.green.shade700,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _currencyFormat.format(item.total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (item.discount > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.discount_rounded,
                        size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 6),
                    Text(
                      'خصم: ${_currencyFormat.format(item.discount)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Customer selection
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: theme.primaryColor.withOpacity(0.3), width: 2),
                  ),
                  child: TextField(
                    controller: _customerController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'اختر العميل (اختياري)',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      prefixIcon:
                          Icon(Icons.person_rounded, color: theme.primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.arrow_drop_down_circle_rounded,
                            color: theme.primaryColor),
                        onPressed: () => _showCustomerDialog(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade700],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showAddCustomerDialog(),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Discount
          Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
            ),
            child: TextField(
              controller: _discountController,
              decoration: InputDecoration(
                hintText: 'خصم إضافي',
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon:
                    const Icon(Icons.discount_rounded, color: Colors.orange),
                suffixText: 'د.ع',
                suffixStyle: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _totalDiscount = double.tryParse(value) ?? 0;
                });
              },
            ),
          ),
          const SizedBox(height: 20),

          // Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.1),
                  theme.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSummaryRow('المجموع الفرعي:',
                    _currencyFormat.format(_subtotal), theme),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'الخصم:',
                  _currencyFormat.format(_totalDiscount + _totalItemDiscounts),
                  theme,
                  color: Colors.red,
                ),
                const Divider(height: 24, thickness: 2),
                _buildSummaryRow(
                  'الإجمالي النهائي:',
                  _currencyFormat.format(_grandTotal),
                  theme,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme,
      {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal
                  ? theme.primaryColor
                  : theme.textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ??
                  (isTotal
                      ? Colors.green.shade700
                      : theme.textTheme.bodyLarge?.color),
              fontSize: isTotal ? 22 : 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButtons(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Payment method selector
          Row(
            children: [
              Expanded(
                child: _buildPaymentMethodButton(
                    'نقدي', Icons.payments_rounded, Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentMethodButton(
                    'بطاقة', Icons.credit_card_rounded, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentMethodButton(
                    'آجل', Icons.schedule_rounded, Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Complete sale button
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: _cart.isEmpty
                  ? null
                  : LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
              color: _cart.isEmpty ? Colors.grey.shade300 : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _cart.isEmpty
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: ElevatedButton(
              onPressed: _cart.isEmpty ? null : _completeSale,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 32,
                    color: _cart.isEmpty ? Colors.grey.shade600 : Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'إتمام عملية البيع',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          _cart.isEmpty ? Colors.grey.shade600 : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodButton(String label, IconData icon, Color color) {
    final isSelected = _paymentMethod == label;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [color.withOpacity(0.8), color],
              )
            : null,
        color: isSelected ? null : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.transparent : color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: MaterialButton(
        onPressed: () {
          setState(() {
            _paymentMethod = label;
          });
        },
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('اختر العميل'),
          content: SizedBox(
            width: 400,
            height: 400,
            child: Consumer<CustomersProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  itemCount: provider.customers.length,
                  itemBuilder: (context, index) {
                    final customer = provider.customers[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(customer.name),
                      subtitle: Text(customer.phone),
                      onTap: () {
                        setState(() {
                          _selectedCustomer = customer;
                          _customerController.text = customer.name;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_add_rounded,
                    color: Colors.green.shade700, size: 28),
              ),
              const SizedBox(width: 12),
              const Text('إضافة عميل جديد'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم العميل *',
                      prefixIcon: Icon(Icons.person_rounded),
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف *',
                      prefixIcon: Icon(Icons.phone_rounded),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان (اختياري)',
                      prefixIcon: Icon(Icons.location_on_rounded),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الرجاء إدخال اسم العميل ورقم الهاتف'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final customer = Customer(
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  address: addressController.text.trim().isEmpty
                      ? null
                      : addressController.text.trim(),
                );

                try {
                  final provider =
                      Provider.of<CustomersProvider>(context, listen: false);
                  await provider.addCustomer(customer);

                  // اختيار العميل الجديد تلقائياً
                  setState(() {
                    _selectedCustomer = customer;
                    _customerController.text = customer.name;
                  });

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ تم إضافة العميل بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ خطأ: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('إضافة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
