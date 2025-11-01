import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../models/product.dart';
import '../models/customer.dart';
import '../models/quotation.dart';
import '../providers/products_provider.dart';
import '../providers/customers_provider.dart';
import '../providers/quotations_provider.dart';

class AddQuotationScreen extends StatefulWidget {
  final Quotation? quotation;

  const AddQuotationScreen({super.key, this.quotation});

  @override
  State<AddQuotationScreen> createState() => _AddQuotationScreenState();
}

class QuotationCartItem {
  final Product product;
  int quantity;
  double discount;

  QuotationCartItem({
    required this.product,
    this.quantity = 1,
    this.discount = 0,
  });

  double get subtotal => product.sellingPrice * quantity;
  double get total => subtotal - discount;
}

class _AddQuotationScreenState extends State<AddQuotationScreen> {
  final _searchController = TextEditingController();
  final _customerController = TextEditingController();
  final _discountController = TextEditingController();
  final _notesController = TextEditingController();
  final _currencyFormat =
      NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);

  final List<QuotationCartItem> _items = [];
  Customer? _selectedCustomer;
  double _totalDiscount = 0;
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  String? _quotationNumber;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<QuotationsProvider>(context, listen: false);
    _quotationNumber = await provider.generateQuotationNumber();

    if (widget.quotation != null) {
      // تحميل بيانات عرض السعر للتعديل
      setState(() {
        _quotationNumber = widget.quotation!.quotationNumber;
        _validUntil = widget.quotation!.validUntil;
        _totalDiscount = widget.quotation!.discount;
        _notesController.text = widget.quotation!.notes ?? '';
        _discountController.text = _totalDiscount.toString();

        if (widget.quotation!.customerId != null) {
          _customerController.text = widget.quotation!.customerName ?? '';
        }

        // تحميل المنتجات
        final productsProvider =
            Provider.of<ProductsProvider>(context, listen: false);
        for (var item in widget.quotation!.items) {
          try {
            final product = productsProvider.products.firstWhere(
              (p) => p.id == item.productId,
            );
            _items.add(QuotationCartItem(
              product: product,
              quantity: item.quantity,
              discount: item.discount ?? 0,
            ));
          } catch (e) {
            print('Product not found: ${item.productId}');
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customerController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    setState(() {
      final existingIndex =
          _items.indexWhere((item) => item.product.id == product.id);
      if (existingIndex != -1) {
        _items[existingIndex].quantity++;
      } else {
        _items.add(QuotationCartItem(product: product));
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      _removeFromCart(index);
    } else {
      setState(() {
        _items[index].quantity = quantity;
      });
    }
  }

  double get _subtotal {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  double get _totalItemDiscounts {
    return _items.fold(0, (sum, item) => sum + item.discount);
  }

  double get _grandTotal {
    return _subtotal - _totalDiscount - _totalItemDiscounts;
  }

  Future<void> _saveQuotation() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إضافة منتجات إلى عرض السعر'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quotation = Quotation(
      id: widget.quotation?.id,
      quotationNumber: _quotationNumber!,
      customerId: _selectedCustomer?.id,
      customerName: _selectedCustomer?.name ?? _customerController.text,
      totalAmount: _subtotal,
      discount: _totalDiscount,
      tax: 0,
      finalAmount: _grandTotal,
      validUntil: _validUntil,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      items: _items
          .map((item) => QuotationItem(
                productId: item.product.id!,
                productName: item.product.name,
                productBarcode: item.product.barcode,
                quantity: item.quantity,
                unitPrice: item.product.sellingPrice,
                totalPrice: item.total,
                discount: item.discount,
              ))
          .toList(),
    );

    final provider = Provider.of<QuotationsProvider>(context, listen: false);
    final bool success;

    if (widget.quotation == null) {
      success = await provider.addQuotation(quotation);
    } else {
      success = await provider.updateQuotation(quotation);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.quotation == null
                ? 'تم حفظ عرض السعر بنجاح'
                : 'تم تحديث عرض السعر بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في حفظ عرض السعر'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showProductSearch() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1E293B) : null,
          child: Container(
            width: 600,
            height: 600,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.search, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'بحث عن منتج',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم أو الباركود',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Consumer<ProductsProvider>(
                    builder: (context, provider, child) {
                      var products = provider.products;

                      if (_searchController.text.isNotEmpty) {
                        products = products
                            .where((p) =>
                                p.name.toLowerCase().contains(
                                    _searchController.text.toLowerCase()) ||
                                p.barcode.contains(_searchController.text))
                            .toList();
                      }

                      if (products.isEmpty) {
                        return const Center(child: Text('لا توجد منتجات'));
                      }

                      return ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF06B6D4).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.inventory_2,
                                    color: Color(0xFF06B6D4)),
                              ),
                              title: Text(product.name),
                              subtitle: Text(
                                'الباركود: ${product.barcode}\nالسعر: ${_currencyFormat.format(product.sellingPrice)}',
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  _addToCart(product);
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.add_circle,
                                    color: Color(0xFF06B6D4)),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectCustomer() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1E293B) : null,
          child: Container(
            width: 600,
            height: 600,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'اختيار العميل',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Consumer<CustomersProvider>(
                    builder: (context, provider, child) {
                      if (provider.customers.isEmpty) {
                        return const Center(child: Text('لا يوجد عملاء'));
                      }

                      return ListView.builder(
                        itemCount: provider.customers.length,
                        itemBuilder: (context, index) {
                          final customer = provider.customers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    const Color(0xFF06B6D4).withOpacity(0.2),
                                child: Text(
                                  customer.name[0],
                                  style: const TextStyle(
                                    color: Color(0xFF06B6D4),
                                    fontWeight: FontWeight.bold,
                                  ),
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
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
      appBar: AppBar(
        title:
            Text(widget.quotation == null ? 'عرض سعر جديد' : 'تعديل عرض سعر'),
        backgroundColor: const Color(0xFF06B6D4),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _saveQuotation,
            icon: const Icon(Icons.save),
            tooltip: 'حفظ',
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // Products Area
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _customerController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'العميل',
                                  hintText: 'اختر عميل',
                                  prefixIcon: const Icon(Icons.person),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.arrow_drop_down),
                                    onPressed: _selectCustomer,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onTap: _selectCustomer,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(
                                  text: DateFormat('yyyy/MM/dd')
                                      .format(_validUntil),
                                ),
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'صالح حتى',
                                  prefixIcon: const Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _validUntil,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                  );
                                  if (date != null) {
                                    setState(() => _validUntil = date);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _showProductSearch,
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة منتج'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06B6D4),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart_outlined,
                                    size: 80,
                                    color: isDark
                                        ? const Color(0xFF475569)
                                        : Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد منتجات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF06B6D4)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.inventory_2,
                                          color: Color(0xFF06B6D4),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              _currencyFormat.format(
                                                  item.product.sellingPrice),
                                              style: TextStyle(
                                                color: isDark
                                                    ? const Color(0xFF94A3B8)
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () => _updateQuantity(
                                                index, item.quantity - 1),
                                            icon: const Icon(Icons.remove),
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => _updateQuantity(
                                                index, item.quantity + 1),
                                            icon: const Icon(Icons.add),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _currencyFormat.format(item.total),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF06B6D4),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _removeFromCart(index),
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // Summary Panel
            Container(
              width: 400,
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _quotationNumber ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Divider(height: 32),
                  TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'خصم إضافي',
                      prefixIcon: const Icon(Icons.discount),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _totalDiscount = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'ملاحظات',
                      prefixIcon: const Icon(Icons.note),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildSummaryRow(
                      'المجموع الفرعي', _currencyFormat.format(_subtotal)),
                  if (_totalItemDiscounts > 0)
                    _buildSummaryRow('خصم المنتجات',
                        '- ${_currencyFormat.format(_totalItemDiscounts)}',
                        color: Colors.red),
                  if (_totalDiscount > 0)
                    _buildSummaryRow('خصم إضافي',
                        '- ${_currencyFormat.format(_totalDiscount)}',
                        color: Colors.red),
                  const Divider(height: 32),
                  _buildSummaryRow(
                    'الإجمالي',
                    _currencyFormat.format(_grandTotal),
                    isBold: true,
                    color: const Color(0xFF06B6D4),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _saveQuotation,
                    icon: const Icon(Icons.save),
                    label: Text(widget.quotation == null ? 'حفظ' : 'تحديث'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 18 : 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 20 : 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
