import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:confetti/confetti.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../providers/products_provider.dart';
import '../providers/customers_provider.dart';
import '../providers/sales_provider.dart';

/// Main POS Screen for creating sales invoices
/// Features:
/// - Smart unified search (barcode & name)
/// - Real-time stock validation
/// - Auto-focus barcode scanner
/// - Keyboard shortcuts support
/// - Live cart management
/// - Smooth animations with flutter_animate
/// - Shimmer effects for loading states
/// - SpinKit loading indicators
/// - Animated text effects
class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

/// Cart Item Model with discount support
class CartItem {
  final Product product;
  int quantity;
  double discount;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.discount = 0,
  });

  /// Calculate subtotal before discount
  double get subtotal => product.sellingPrice * quantity;

  /// Calculate final total after discount
  double get total => subtotal - discount;
}

class _SalesListScreenState extends State<SalesListScreen> {
  // Controllers
  final _searchController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _customerController = TextEditingController();
  final _discountController = TextEditingController();
  late ConfettiController _confettiController;

  // Formatters
  final _currencyFormat =
      NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);

  // State Variables
  final List<CartItem> _cart = [];
  Customer? _selectedCustomer;
  String _paymentMethod = 'نقدي';
  double _totalDiscount = 0;
  String _selectedCategory = 'الكل';

  // Focus Nodes
  final FocusNode _barcodeFocusNode = FocusNode();

  // Debouncing timer for search optimization
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Initialize confetti controller
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).loadProducts();
      Provider.of<CustomersProvider>(context, listen: false).loadCustomers();
      _barcodeFocusNode.requestFocus();
    });

    // Listen to search changes with debouncing
    _searchController.addListener(_onSearchChanged);
  }

  /// Debounced search to improve performance
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Cancel debounce timer
    _debounce?.cancel();

    // Dispose confetti controller
    _confettiController.dispose();

    // Dispose controllers
    _searchController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _customerController.dispose();
    _discountController.dispose();

    // Dispose focus nodes
    _barcodeFocusNode.dispose();

    super.dispose();
  }

  /// Add product to cart or increment quantity if already exists
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

  /// Remove item from cart by index
  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  /// Update cart item quantity or remove if zero
  void _updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      _removeFromCart(index);
    } else {
      setState(() {
        _cart[index].quantity = quantity;
      });
    }
  }

  /// Calculate subtotal before any discounts
  double get _subtotal {
    return _cart.fold(0, (sum, item) => sum + item.subtotal);
  }

  /// Calculate total item-level discounts
  double get _totalItemDiscounts {
    return _cart.fold(0, (sum, item) => sum + item.discount);
  }

  /// Calculate grand total after all discounts
  double get _grandTotal {
    return _subtotal - _totalDiscount - _totalItemDiscounts;
  }

  /// Clear cart and reset all fields
  void _clearCart() {
    setState(() {
      _cart.clear();
      _selectedCustomer = null;
      _totalDiscount = 0;
      _discountController.clear();
      _customerController.clear();
    });
    _barcodeFocusNode.requestFocus();
  }

  /// Complete the sale and save to database
  Future<void> _completeSale() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ السلة فارغة - أضف منتجات أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final salesProvider = Provider.of<SalesProvider>(context, listen: false);

    // Generate unique invoice number
    final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';

    final sale = Sale(
      invoiceNumber: invoiceNumber,
      customerId: _selectedCustomer?.id,
      customerName: _selectedCustomer?.name,
      totalAmount: _subtotal,
      discount: _totalDiscount + _totalItemDiscounts,
      tax: 0,
      finalAmount: _grandTotal,
      paidAmount: _grandTotal,
      remainingAmount: 0,
      paymentMethod: _paymentMethod,
      status: 'completed',
      items: const [],
    );

    try {
      await salesProvider.addSale(sale);

      // Trigger confetti celebration
      _confettiController.play();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم إتمام البيع - فاتورة رقم: $invoiceNumber'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      _clearCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          // F2: Focus on barcode field
          if (event.logicalKey == LogicalKeyboardKey.f2) {
            _barcodeFocusNode.requestFocus();
          }
          // F3: Clear cart
          else if (event.logicalKey == LogicalKeyboardKey.f3) {
            _clearCart();
          }
          // F4: Complete sale (if cart not empty)
          else if (event.logicalKey == LogicalKeyboardKey.f4 &&
              _cart.isNotEmpty) {
            _completeSale();
          }
          // Escape: Clear current input
          else if (event.logicalKey == LogicalKeyboardKey.escape) {
            _barcodeController.clear();
            _barcodeFocusNode.requestFocus();
          }
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
        body: Stack(
          children: [
            Column(
              children: [
                // Enhanced Animated Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF10B981),
                        Color(0xFF059669),
                        Color(0xFF047857),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(14),
                        ),
                        tooltip: 'رجوع',
                      ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.cashRegister,
                          color: Colors.white,
                          size: 36,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 100.ms)
                          .slideX(begin: -0.2, end: 0),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🛍️ نقطة البيع - POS',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 200.ms)
                                .slideY(begin: -0.3, end: 0),
                            const SizedBox(height: 6),
                            Text(
                              'بيع المنتجات وإصدار الفواتير | الفاتورة #${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 0.3,
                              ),
                            ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                            const SizedBox(height: 4),
                            // Keyboard shortcuts hint with shimmer
                            Text(
                              '⌨️ F2: بحث | F3: مسح | F4: إتمام | ESC: إلغاء',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            )
                                .animate(
                                    onPlay: (controller) => controller.repeat())
                                .shimmer(
                                  duration: 3000.ms,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                          ],
                        ),
                      ),
                      // Animated Cart Summary Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const FaIcon(
                                FontAwesomeIcons.cartShopping,
                                color: Color(0xFF10B981),
                                size: 24,
                              ),
                            )
                                .animate(
                                    onPlay: (controller) => controller.repeat())
                                .shake(
                                    duration: 2000.ms, delay: 500.ms, hz: 0.5),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_cart.length} منتج',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ).animate().fadeIn(duration: 300.ms).scale(),
                                Text(
                                  _currencyFormat.format(_grandTotal),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: Row(
                    children: [
                      // Products List - Left Side
                      Expanded(
                        flex: 3,
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Unified Smart Search Section
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF3B82F6).withOpacity(0.1),
                                      const Color(0xFF2563EB).withOpacity(0.05),
                                    ],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: const Color(0xFF3B82F6)
                                          .withOpacity(0.2),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Section Title
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3B82F6),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF3B82F6)
                                                    .withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.qr_code_scanner_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          '🔍 بحث ذكي موحد',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E40AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Unified Smart Search Field
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: const Color(0xFF3B82F6),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF3B82F6)
                                                .withOpacity(0.15),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: _barcodeController,
                                        focusNode: _barcodeFocusNode,
                                        autofocus: true,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText:
                                              '🔍 امسح الباركود أو اكتب اسم المنتج... (Enter للإضافة)',
                                          hintStyle: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search_rounded,
                                            color: Color(0xFF3B82F6),
                                            size: 28,
                                          ),
                                        ),
                                        onSubmitted: (value) {
                                          if (value.isNotEmpty) {
                                            final productsProvider =
                                                Provider.of<ProductsProvider>(
                                                    context,
                                                    listen: false);

                                            // Smart Search: Try barcode first, then name
                                            Product? foundProduct;
                                            try {
                                              foundProduct = productsProvider
                                                  .products
                                                  .firstWhere(
                                                (p) =>
                                                    p.barcode.toLowerCase() ==
                                                    value.toLowerCase(),
                                              );
                                            } catch (e) {
                                              try {
                                                foundProduct = productsProvider
                                                    .products
                                                    .firstWhere(
                                                  (p) => p.name
                                                      .toLowerCase()
                                                      .contains(
                                                          value.toLowerCase()),
                                                );
                                              } catch (e) {
                                                foundProduct = null;
                                              }
                                            }

                                            if (foundProduct != null &&
                                                foundProduct.id != null) {
                                              // Check stock before adding
                                              if (foundProduct.quantity <= 0) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: [
                                                        const Icon(
                                                            Icons
                                                                .warning_amber_rounded,
                                                            color:
                                                                Colors.white),
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                          child: Text(
                                                              '⚠️ ${foundProduct.name} غير متوفر في المخزون!'),
                                                        ),
                                                      ],
                                                    ),
                                                    backgroundColor:
                                                        const Color(0xFFEF4444),
                                                    duration: const Duration(
                                                        seconds: 3),
                                                  ),
                                                );
                                                _barcodeController.clear();
                                                _barcodeFocusNode
                                                    .requestFocus();
                                                return;
                                              }

                                              // Check low stock warning
                                              if (foundProduct.quantity <=
                                                  foundProduct.minQuantity) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: [
                                                        const Icon(
                                                            Icons.info_outline,
                                                            color:
                                                                Colors.white),
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                          child: Text(
                                                              '⚡ ${foundProduct.name} - الكمية المتبقية: ${foundProduct.quantity} فقط!'),
                                                        ),
                                                      ],
                                                    ),
                                                    backgroundColor:
                                                        const Color(0xFFF59E0B),
                                                    duration: const Duration(
                                                        seconds: 2),
                                                  ),
                                                );
                                              }

                                              // Auto-add with quantity 1 (or custom quantity)
                                              final qty = int.tryParse(
                                                      _quantityController
                                                          .text) ??
                                                  1;

                                              // Check if quantity exceeds stock
                                              if (qty > foundProduct.quantity) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        '❌ الكمية المطلوبة ($qty) أكبر من المتوفر (${foundProduct.quantity})!'),
                                                    backgroundColor:
                                                        const Color(0xFFEF4444),
                                                    duration: const Duration(
                                                        seconds: 2),
                                                  ),
                                                );
                                                _barcodeController.clear();
                                                _barcodeFocusNode
                                                    .requestFocus();
                                                return;
                                              }

                                              for (int i = 0; i < qty; i++) {
                                                _addToCart(foundProduct);
                                              }
                                              _barcodeController.clear();
                                              _quantityController.text = '1';
                                              _barcodeFocusNode.requestFocus();

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.check_circle,
                                                          color: Colors.white),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                            '✅ أُضيف: ${foundProduct.name} × $qty'),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor:
                                                      const Color(0xFF10B981),
                                                  duration: const Duration(
                                                      milliseconds: 800),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Icon(Icons.error_outline,
                                                          color: Colors.white),
                                                      SizedBox(width: 8),
                                                      Text(
                                                          '❌ المنتج غير موجود!'),
                                                    ],
                                                  ),
                                                  backgroundColor:
                                                      Color(0xFFEF4444),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                              _barcodeController.clear();
                                              _barcodeFocusNode.requestFocus();
                                            }
                                          }
                                        },
                                        onChanged: (value) {
                                          // Live search as you type
                                          setState(() {
                                            _searchController.text = value;
                                          });
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Quantity Control Row
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.inventory_2_outlined,
                                          color: Color(0xFF10B981),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'الكمية:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFF10B981),
                                                width: 2,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    int current = int.tryParse(
                                                            _quantityController
                                                                .text) ??
                                                        1;
                                                    if (current > 1) {
                                                      setState(() {
                                                        _quantityController
                                                                .text =
                                                            (current - 1)
                                                                .toString();
                                                      });
                                                    }
                                                  },
                                                  icon: const Icon(
                                                      Icons.remove_circle,
                                                      color: Color(0xFFEF4444)),
                                                  iconSize: 28,
                                                ),
                                                Container(
                                                  width: 60,
                                                  alignment: Alignment.center,
                                                  child: TextField(
                                                    controller:
                                                        _quantityController,
                                                    textAlign: TextAlign.center,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF059669),
                                                    ),
                                                    decoration:
                                                        const InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: '1',
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    int current = int.tryParse(
                                                            _quantityController
                                                                .text) ??
                                                        1;
                                                    setState(() {
                                                      _quantityController.text =
                                                          (current + 1)
                                                              .toString();
                                                    });
                                                  },
                                                  icon: const Icon(
                                                      Icons.add_circle,
                                                      color: Color(0xFF10B981)),
                                                  iconSize: 28,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Categories Filter
                                    SizedBox(
                                      height: 50,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          _buildCategoryChip('الكل'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              // Products List
                              Expanded(
                                child: Consumer<ProductsProvider>(
                                  builder: (context, provider, child) {
                                    if (provider.isLoading) {
                                      // Professional SpinKit loading effect
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SpinKitWave(
                                              color: const Color(0xFF10B981),
                                              size: 50.0,
                                            ),
                                            const SizedBox(height: 20),
                                            AnimatedTextKit(
                                              animatedTexts: [
                                                WavyAnimatedText(
                                                  'جاري تحميل المنتجات...',
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF059669),
                                                  ),
                                                ),
                                              ],
                                              isRepeatingAnimation: true,
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    var filteredProducts =
                                        provider.products.where((product) {
                                      final matchesSearch = _searchController
                                              .text.isEmpty ||
                                          product.name.toLowerCase().contains(
                                              _searchController.text
                                                  .toLowerCase()) ||
                                          product.barcode
                                              .toLowerCase()
                                              .contains(_searchController.text
                                                  .toLowerCase());
                                      final matchesCategory =
                                          _selectedCategory == 'الكل' ||
                                              product.category ==
                                                  _selectedCategory;
                                      return matchesSearch && matchesCategory;
                                    }).toList();

                                    if (filteredProducts.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.inventory_2_outlined,
                                              size: 80,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'لا توجد منتجات',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: filteredProducts.length,
                                      itemBuilder: (context, index) {
                                        final product = filteredProducts[index];
                                        return _buildProductItem(
                                                product, isDark)
                                            .animate()
                                            .fadeIn(
                                              duration: 300.ms,
                                              delay: (index * 50).ms,
                                            )
                                            .slideX(
                                              begin: -0.1,
                                              end: 0,
                                              duration: 400.ms,
                                              delay: (index * 50).ms,
                                            );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Cart - Right Side
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 16, right: 16, bottom: 16),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Enhanced Cart Header
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFEF4444),
                                      Color(0xFFDC2626),
                                    ],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFEF4444)
                                          .withOpacity(0.4),
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
                                        color: Colors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: const FaIcon(
                                        FontAwesomeIcons.receipt,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    )
                                        .animate()
                                        .fadeIn(duration: 400.ms)
                                        .rotate(delay: 200.ms),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '📋 الفاتورة',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${_cart.length} صنف في السلة',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_cart.isNotEmpty)
                                      ElevatedButton.icon(
                                        onPressed: _clearCart,
                                        icon: const Icon(
                                            Icons.delete_sweep_rounded,
                                            size: 20),
                                        label: const Text(
                                          'إفراغ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor:
                                              const Color(0xFFEF4444),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          elevation: 2,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              // Cart Items
                              Expanded(
                                child: _cart.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.shopping_cart_outlined,
                                              size: 80,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'السلة فارغة',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.all(8),
                                        itemCount: _cart.length,
                                        itemBuilder: (context, index) {
                                          return Slidable(
                                            key: ValueKey(
                                                _cart[index].product.id),
                                            endActionPane: ActionPane(
                                              motion: const DrawerMotion(),
                                              children: [
                                                SlidableAction(
                                                  onPressed: (context) {
                                                    setState(() {
                                                      _cart.removeAt(index);
                                                    });
                                                  },
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  icon: Icons.delete,
                                                  label: 'حذف',
                                                ),
                                              ],
                                            ),
                                            child: _buildCartItem(
                                                _cart[index], index, isDark),
                                          )
                                              .animate()
                                              .fadeIn(duration: 200.ms)
                                              .slideX(begin: 0.1, end: 0);
                                        },
                                      ),
                              ),
                              const Divider(height: 1),
                              // Customer Selection
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: InkWell(
                                  onTap: _showCustomerDialog,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF10B981)
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.person,
                                            color: Color(0xFF10B981)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _selectedCustomer?.name ??
                                                'اختر العميل (اختياري)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _selectedCustomer != null
                                                  ? null
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Enhanced Summary Section
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF3B82F6).withOpacity(0.1),
                                      const Color(0xFF2563EB).withOpacity(0.05),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  border: Border(
                                    top: BorderSide(
                                      color: const Color(0xFF3B82F6)
                                          .withOpacity(0.2),
                                      width: 2,
                                    ),
                                    bottom: BorderSide(
                                      color: const Color(0xFF3B82F6)
                                          .withOpacity(0.2),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Summary Title
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3B82F6),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const FaIcon(
                                            FontAwesomeIcons.calculator,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        )
                                            .animate(
                                                onPlay: (controller) =>
                                                    controller.repeat())
                                            .shimmer(
                                                duration: 2000.ms,
                                                color: Colors.white
                                                    .withOpacity(0.3)),
                                        const SizedBox(width: 10),
                                        const Text(
                                          '💰 الملخص المالي',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E40AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Subtotal
                                    _buildSummaryRow(
                                      'المجموع الفرعي:',
                                      _currencyFormat.format(_subtotal),
                                    ),
                                    const SizedBox(height: 10),

                                    // Discount
                                    _buildSummaryRow(
                                      'الخصم:',
                                      _currencyFormat.format(
                                          _totalDiscount + _totalItemDiscounts),
                                      color: const Color(0xFFEF4444),
                                    ),

                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: Divider(thickness: 2),
                                    ),

                                    // Grand Total
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF10B981),
                                            Color(0xFF059669),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF10B981)
                                                .withOpacity(0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.payments_rounded,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'الإجمالي النهائي:',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            _currencyFormat.format(_grandTotal),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Payment Methods Section
                              Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8B5CF6),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const FaIcon(
                                            FontAwesomeIcons.creditCard,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        )
                                            .animate()
                                            .scale(duration: 300.ms)
                                            .then()
                                            .shake(
                                                hz: 2,
                                                curve: Curves.easeInOutCubic),
                                        const SizedBox(width: 10),
                                        const Text(
                                          '💳 طريقة الدفع',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF6D28D9),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Payment Buttons Grid
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildPaymentButton(
                                            'نقدي',
                                            Icons.money,
                                            const Color(0xFF10B981),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _buildPaymentButton(
                                            'بطاقة',
                                            Icons.credit_card,
                                            const Color(0xFF3B82F6),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildPaymentButton(
                                            'آجل',
                                            Icons.schedule,
                                            const Color(0xFFF59E0B),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _buildPaymentButton(
                                            'ماستر',
                                            Icons.credit_score,
                                            const Color(0xFF8B5CF6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Action Buttons
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Complete Sale Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 60,
                                      child: ElevatedButton(
                                        onPressed: _cart.isEmpty
                                            ? null
                                            : _completeSale,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF10B981),
                                          disabledBackgroundColor:
                                              Colors.grey[300],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          elevation: 6,
                                          shadowColor: const Color(0xFF10B981)
                                              .withOpacity(0.5),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FaIcon(FontAwesomeIcons.circleCheck,
                                                size: 28),
                                            SizedBox(width: 12),
                                            Text(
                                              'إتمام البيع ✓',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                          .animate()
                                          .shimmer(
                                              duration: 1500.ms,
                                              color:
                                                  Colors.white.withOpacity(0.4))
                                          .then(delay: 500.ms)
                                          .shake(
                                              hz: 1, curve: Curves.easeInOut),
                                    ),
                                    const SizedBox(height: 12),

                                    // Quick Actions Row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: _cart.isEmpty
                                                ? null
                                                : () {
                                                    // Save draft
                                                  },
                                            icon: const Icon(
                                                Icons.save_outlined,
                                                size: 20),
                                            label: const Text(
                                              'حفظ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  const Color(0xFF3B82F6),
                                              side: const BorderSide(
                                                color: Color(0xFF3B82F6),
                                                width: 2,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _cart.clear();
                                                _selectedCustomer = null;
                                                _paymentMethod = 'نقدي';
                                              });
                                            },
                                            icon: const Icon(
                                                Icons.refresh_rounded,
                                                size: 20),
                                            label: const Text(
                                              'جديد',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  const Color(0xFF10B981),
                                              side: const BorderSide(
                                                color: Color(0xFF10B981),
                                                width: 2,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Confetti Widget Overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Color(0xFF10B981),
                  Color(0xFF3B82F6),
                  Color(0xFFF59E0B),
                  Color(0xFFEF4444),
                  Color(0xFF8B5CF6),
                ],
                numberOfParticles: 50,
                gravity: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: const Color(0xFF10B981),
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildProductItem(Product product, bool isDark) {
    final isLowStock = product.quantity <= product.minQuantity;
    final isOutOfStock = product.quantity <= 0;

    return InkWell(
      onTap: isOutOfStock ? null : () => _addToCart(product),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOutOfStock
              ? Colors.grey.shade200
              : (isDark ? const Color(0xFF334155) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOutOfStock
                ? Colors.red.shade300
                : (isLowStock
                    ? Colors.orange.shade300
                    : (isDark ? const Color(0xFF475569) : Colors.grey[200]!)),
            width: isLowStock || isOutOfStock ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isOutOfStock
                        ? Colors.red.withOpacity(0.1)
                        : (isLowStock
                            ? Colors.orange.withOpacity(0.1)
                            : const Color(0xFF10B981).withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isOutOfStock
                        ? LineIcons.ban
                        : (isLowStock
                            ? LineIcons.exclamationTriangle
                            : LineIcons.box),
                    color: isOutOfStock
                        ? Colors.red
                        : (isLowStock
                            ? Colors.orange
                            : const Color(0xFF10B981)),
                    size: 26,
                  ),
                ).animate().scale(duration: 300.ms).fadeIn(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isOutOfStock ? Colors.grey : null,
                          decoration:
                              isOutOfStock ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _currencyFormat.format(product.sellingPrice),
                            style: TextStyle(
                              fontSize: 14,
                              color: isOutOfStock
                                  ? Colors.grey
                                  : const Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? Colors.red.withOpacity(0.15)
                                  : (isLowStock
                                      ? Colors.orange.withOpacity(0.15)
                                      : Colors.grey.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isOutOfStock
                                    ? Colors.red
                                    : (isLowStock
                                        ? Colors.orange
                                        : Colors.grey.shade300),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOutOfStock
                                      ? Icons.error_outline
                                      : (isLowStock
                                          ? Icons.warning_amber
                                          : Icons.check_circle_outline),
                                  size: 12,
                                  color: isOutOfStock
                                      ? Colors.red
                                      : (isLowStock
                                          ? Colors.orange
                                          : Colors.grey[700]),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isOutOfStock
                                      ? 'نفذت الكمية'
                                      : 'متوفر: ${product.quantity}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isOutOfStock
                                        ? Colors.red
                                        : (isLowStock
                                            ? Colors.orange
                                            : Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: isOutOfStock ? null : () => _addToCart(product),
                  icon: Icon(
                    isOutOfStock ? Icons.block : Icons.add_circle,
                    color: isOutOfStock ? Colors.grey : const Color(0xFF10B981),
                  ),
                  iconSize: 32,
                ),
              ],
            ),
            // Low Stock Warning Badge
            if (isLowStock && !isOutOfStock)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '⚡ قريب النفاذ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFormat.format(item.product.sellingPrice),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removeFromCart(index),
                icon: const Icon(Icons.delete, size: 20),
                color: Colors.red,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          _updateQuantity(index, item.quantity - 1),
                      icon: const Icon(Icons.remove, size: 18),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          _updateQuantity(index, item.quantity + 1),
                      icon: const Icon(Icons.add, size: 18),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                _currencyFormat.format(item.total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: color ?? (isTotal ? const Color(0xFF10B981) : null),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton(String method, IconData icon, Color color) {
    final isSelected = _paymentMethod == method;
    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
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
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[700],
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              method,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white : Colors.grey[700],
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.people, color: Color(0xFF10B981)),
              SizedBox(width: 12),
              Text('اختر العميل'),
            ],
          ),
          content: SizedBox(
            width: 400,
            height: 400,
            child: Consumer<CustomersProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: provider.customers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child:
                              Icon(Icons.person_outline, color: Colors.white),
                        ),
                        title: const Text('زبون عام'),
                        onTap: () {
                          setState(() {
                            _selectedCustomer = null;
                            _customerController.clear();
                          });
                          Navigator.pop(context);
                        },
                      );
                    }
                    final customer = provider.customers[index - 1];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF10B981),
                        child: Text(
                          customer.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
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
}
