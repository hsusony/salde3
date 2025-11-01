import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../models/product.dart';
import '../models/customer.dart';
import '../models/pending_order.dart';
import '../providers/products_provider.dart';
import '../providers/customers_provider.dart';
import '../providers/pending_orders_provider.dart';

class AddPendingOrderScreen extends StatefulWidget {
  final PendingOrder? order;

  const AddPendingOrderScreen({super.key, this.order});

  @override
  State<AddPendingOrderScreen> createState() => _AddPendingOrderScreenState();
}

class OrderCartItem {
  final Product product;
  int quantity;
  double discount;
  String notes;

  OrderCartItem({
    required this.product,
    this.quantity = 1,
    this.discount = 0,
    this.notes = '',
  });

  double get subtotal => product.sellingPrice * quantity;
  double get total => subtotal - discount;
}

class _AddPendingOrderScreenState extends State<AddPendingOrderScreen> {
  final _searchController = TextEditingController();
  final _customerController = TextEditingController();
  final _discountController = TextEditingController();
  final _notesController = TextEditingController();
  final _depositController = TextEditingController();
  final _currencyFormat =
      NumberFormat.currency(symbol: 'د.ع ', decimalDigits: 0);

  final List<OrderCartItem> _items = [];
  Customer? _selectedCustomer;
  double _totalDiscount = 0;
  double _depositAmount = 0;
  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));
  String? _orderNumber;
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<PendingOrdersProvider>(context, listen: false);
    _orderNumber = await provider.generateOrderNumber();

    if (widget.order != null) {
      setState(() {
        _orderNumber = widget.order!.orderNumber;
        _deliveryDate = widget.order!.deliveryDate ??
            DateTime.now().add(const Duration(days: 7));
        _totalDiscount = widget.order!.discount;
        _depositAmount = widget.order!.depositAmount;
        _status = widget.order!.status;
        _notesController.text = widget.order!.notes ?? '';
        _discountController.text = _totalDiscount.toString();
        _depositController.text = _depositAmount.toString();

        if (widget.order!.customerId != null) {
          _customerController.text = widget.order!.customerName ?? '';
        }

        final productsProvider =
            Provider.of<ProductsProvider>(context, listen: false);
        for (var item in widget.order!.items) {
          try {
            final product = productsProvider.products.firstWhere(
              (p) => p.id == item.productId,
            );
            _items.add(OrderCartItem(
              product: product,
              quantity: item.quantity,
              discount: item.discount ?? 0,
              notes: item.notes ?? '',
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
    _depositController.dispose();
    super.dispose();
  }

  void _showProductSearch() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('اختر منتج'),
          content: SizedBox(
            width: 600,
            height: 500,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'بحث',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Consumer<ProductsProvider>(
                    builder: (context, provider, _) {
                      var products = provider.products.where((p) {
                        final search = _searchController.text.toLowerCase();
                        return p.name.toLowerCase().contains(search) ||
                            p.barcode.toLowerCase().contains(search);
                      }).toList();

                      return ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text(
                              'الباركود: ${product.barcode} | السعر: ${_currencyFormat.format(product.sellingPrice)}',
                            ),
                            onTap: () {
                              _addProductToCart(product);
                              Navigator.pop(context);
                              _searchController.clear();
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _searchController.clear();
              },
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  void _addProductToCart(Product product) {
    setState(() {
      final existingIndex =
          _items.indexWhere((item) => item.product.id == product.id);
      if (existingIndex >= 0) {
        _items[existingIndex].quantity++;
      } else {
        _items.add(OrderCartItem(product: product));
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateQuantity(int index, int quantity) {
    if (quantity > 0) {
      setState(() {
        _items[index].quantity = quantity;
      });
    }
  }

  void _updateDiscount(int index, double discount) {
    setState(() {
      _items[index].discount = discount;
    });
  }

  void _updateItemNotes(int index, String notes) {
    setState(() {
      _items[index].notes = notes;
    });
  }

  void _showCustomerSearch() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('اختر زبون'),
          content: SizedBox(
            width: 500,
            height: 400,
            child: Consumer<CustomersProvider>(
              builder: (context, provider, _) {
                return ListView.builder(
                  itemCount: provider.customers.length,
                  itemBuilder: (context, index) {
                    final customer = provider.customers[index];
                    return ListTile(
                      title: Text(customer.name),
                      subtitle: Text('الهاتف: ${customer.phone}'),
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
        ),
      ),
    );
  }

  Future<void> _selectDeliveryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _deliveryDate = picked;
      });
    }
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);
  double get _totalItemDiscount =>
      _items.fold(0, (sum, item) => sum + item.discount);
  double get _grandTotal => _subtotal - _totalItemDiscount - _totalDiscount;
  double get _remainingAmount => _grandTotal - _depositAmount;

  Future<void> _saveOrder() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إضافة منتجات')),
      );
      return;
    }

    final order = PendingOrder(
      id: widget.order?.id,
      orderNumber: _orderNumber!,
      customerId: _selectedCustomer?.id,
      customerName: _selectedCustomer?.name,
      customerPhone: _selectedCustomer?.phone,
      totalAmount: _subtotal,
      discount: _totalDiscount,
      tax: 0,
      finalAmount: _grandTotal,
      depositAmount: _depositAmount,
      remainingAmount: _remainingAmount,
      status: _status,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      deliveryDate: _deliveryDate,
      createdAt: widget.order?.createdAt,
      items: _items
          .map((item) => PendingOrderItem(
                productId: item.product.id!,
                productName: item.product.name,
                productBarcode: item.product.barcode,
                quantity: item.quantity,
                unitPrice: item.product.sellingPrice,
                totalPrice: item.total,
                discount: item.discount,
                notes: item.notes.isEmpty ? null : item.notes,
              ))
          .toList(),
    );

    try {
      final provider =
          Provider.of<PendingOrdersProvider>(context, listen: false);
      if (widget.order == null) {
        await provider.addOrder(order);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة الطلب بنجاح')),
          );
        }
      } else {
        await provider.updateOrder(order);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث الطلب بنجاح')),
          );
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(widget.order == null ? 'طلب معلق جديد' : 'تعديل طلب معلق'),
          backgroundColor: const Color(0xFFEC4899),
          foregroundColor: Colors.white,
        ),
        body: Row(
          children: [
            // القسم الأيمن - قائمة المنتجات
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // معلومات الطلب
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'رقم الطلب: $_orderNumber',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(_status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getStatusText(_status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _customerController,
                                decoration: InputDecoration(
                                  labelText: 'الزبون',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.person),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                                ),
                                readOnly: true,
                                onTap: _showCustomerSearch,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: _selectDeliveryDate,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'تاريخ التسليم',
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.calendar_today),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                                  ),
                                  child: Text(
                                    DateFormat('yyyy-MM-dd')
                                        .format(_deliveryDate),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // قائمة المنتجات
                  Expanded(
                    child: _items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 80,
                                  color: isDark ? const Color(0xFF475569) : Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد منتجات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
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
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.product.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'الباركود: ${item.product.barcode}',
                                                  style: TextStyle(
                                                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () => _removeItem(index),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        children: [
                                          // الكمية
                                          Expanded(
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons
                                                      .remove_circle_outline),
                                                  onPressed: () =>
                                                      _updateQuantity(
                                                    index,
                                                    item.quantity - 1,
                                                  ),
                                                ),
                                                Text(
                                                  '${item.quantity}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.add_circle_outline),
                                                  onPressed: () =>
                                                      _updateQuantity(
                                                    index,
                                                    item.quantity + 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // السعر
                                          Text(
                                            _currencyFormat.format(
                                                item.product.sellingPrice),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              decoration: const InputDecoration(
                                                labelText: 'الحسم',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                final discount =
                                                    double.tryParse(value) ?? 0;
                                                _updateDiscount(
                                                    index, discount);
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: TextField(
                                              decoration: const InputDecoration(
                                                labelText: 'ملاحظات',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                              onChanged: (value) =>
                                                  _updateItemNotes(
                                                      index, value),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'المجموع الفرعي: ${_currencyFormat.format(item.subtotal)}',
                                            style: TextStyle(
                                                color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600]),
                                          ),
                                          Text(
                                            'المجموع: ${_currencyFormat.format(item.total)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFEC4899),
                                            ),
                                          ),
                                        ],
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
            // القسم الأيسر - الملخص والإجراءات
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                border: Border(
                  right: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey[300]!),
                ),
              ),
              child: Column(
                children: [
                  // زر إضافة منتج
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _showProductSearch,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('إضافة منتج'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEC4899),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  // الملخص المالي
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الملخص المالي',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow('المجموع الفرعي', _subtotal),
                          _buildSummaryRow('حسم المنتجات', _totalItemDiscount),
                          TextField(
                            controller: _discountController,
                            decoration: const InputDecoration(
                              labelText: 'حسم إضافي',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _totalDiscount = double.tryParse(value) ?? 0;
                              });
                            },
                          ),
                          const Divider(height: 32),
                          _buildSummaryRow(
                            'المجموع الكلي',
                            _grandTotal,
                            isTotal: true,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _depositController,
                            decoration: const InputDecoration(
                              labelText: 'الدفعة المقدمة',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.payments),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _depositAmount = double.tryParse(value) ?? 0;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow(
                            'المبلغ المتبقي',
                            _remainingAmount,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'ملاحظات',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _status,
                            decoration: const InputDecoration(
                              labelText: 'الحالة',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'pending',
                                  child: Text('قيد الانتظار')),
                              DropdownMenuItem(
                                  value: 'processing',
                                  child: Text('قيد المعالجة')),
                              DropdownMenuItem(
                                  value: 'ready', child: Text('جاهز للتسليم')),
                              DropdownMenuItem(
                                  value: 'completed', child: Text('مكتمل')),
                              DropdownMenuItem(
                                  value: 'cancelled', child: Text('ملغى')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _status = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // أزرار الحفظ والإلغاء
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEC4899),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              widget.order == null
                                  ? 'حفظ الطلب'
                                  : 'تحديث الطلب',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('إلغاء'),
                          ),
                        ),
                      ],
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

  Widget _buildSummaryRow(String label, double amount,
      {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            _currencyFormat.format(amount),
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isTotal ? const Color(0xFFEC4899) : null),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'processing':
        return 'قيد المعالجة';
      case 'ready':
        return 'جاهز للتسليم';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغى';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
