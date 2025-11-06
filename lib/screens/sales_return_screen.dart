import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../providers/sales_provider.dart';
import '../models/sale.dart';
import '../services/inventory_service.dart';

class SalesReturnScreen extends StatefulWidget {
  const SalesReturnScreen({super.key});

  @override
  State<SalesReturnScreen> createState() => _SalesReturnScreenState();
}

class _SalesReturnScreenState extends State<SalesReturnScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  String _searchQuery = '';
  final _formKey = GlobalKey<FormState>();

  // Return form fields
  final Map<int, int> _returnQuantities = {};
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesProvider>(context, listen: false).loadSales();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEF4444),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _showReturnDialog(Sale sale) {
    _returnQuantities.clear();
    _reasonController.clear();

    // Initialize return quantities with 0
    for (var item in sale.items) {
      _returnQuantities[item.productId] = 0;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.keyboard_return_rounded,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إرجاع فاتورة بيع',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        'فاتورة رقم: ${sale.invoiceNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 600,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sale Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                                'العميل:', sale.customerName ?? 'نقدي'),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                                'التاريخ:',
                                DateFormat('yyyy-MM-dd')
                                    .format(sale.createdAt)),
                            const SizedBox(height: 8),
                            _buildInfoRow('المبلغ الإجمالي:',
                                '${sale.totalAmount.toStringAsFixed(2)} دينار'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Items to return
                      const Text(
                        'حدد الأصناف المراد إرجاعها:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...sale.items.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${item.unitPrice.toStringAsFixed(2)} دينار',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'الكمية المباعة: ${item.quantity}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  const Text(
                                    'كمية الإرجاع:',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 100,
                                    child: TextFormField(
                                      initialValue: '0',
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'مطلوب';
                                        }
                                        final qty = int.tryParse(value);
                                        if (qty == null || qty < 0) {
                                          return 'رقم غير صحيح';
                                        }
                                        if (qty > item.quantity) {
                                          return 'أكبر من المباع';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        setDialogState(() {
                                          _returnQuantities[item.productId] =
                                              int.tryParse(value) ?? 0;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 20),

                      // Return reason
                      TextFormField(
                        controller: _reasonController,
                        decoration: InputDecoration(
                          labelText: 'سبب الإرجاع',
                          hintText: 'اكتب سبب الإرجاع...',
                          prefixIcon: const Icon(Icons.notes),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى كتابة سبب الإرجاع';
                          }
                          return null;
                        },
                      ),

                      // Total return amount
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'المبلغ المرتجع:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_calculateReturnAmount(sale).toStringAsFixed(2)} دينار',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => _processReturn(context, sale),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('تأكيد الإرجاع'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateReturnAmount(Sale sale) {
    double total = 0;
    for (var item in sale.items) {
      final returnQty = _returnQuantities[item.productId] ?? 0;
      total += item.unitPrice * returnQty;
    }
    return total;
  }

  void _processReturn(BuildContext context, Sale sale) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if at least one item has return quantity
    final hasReturns = _returnQuantities.values.any((qty) => qty > 0);
    if (!hasReturns) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد كمية الإرجاع لصنف واحد على الأقل'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // ✅ إعادة الكميات المرتجعة إلى المخزون
      final inventoryService = InventoryService();
      for (var item in sale.items) {
        final returnQty = _returnQuantities[item.productId] ?? 0;
        if (returnQty > 0) {
          await inventoryService.returnStockForSaleReturn(
            productId: item.productId,
            quantity: returnQty.toDouble(),
            warehouseId: 1,
          );
        }
      }

      // TODO: حفظ المرتجع في قاعدة البيانات

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إرجاع الفاتورة رقم ${sale.invoiceNumber} بنجاح\nالمبلغ المرتجع: ${_calculateReturnAmount(sale).toStringAsFixed(2)} دينار\n✅ تم تحديث المخزون',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء معالجة الإرجاع: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);

    final filteredSales = salesProvider.sales.where((sale) {
      final matchesDate =
          sale.createdAt.isAfter(_fromDate.subtract(const Duration(days: 1))) &&
              sale.createdAt.isBefore(_toDate.add(const Duration(days: 1)));

      final matchesSearch = _searchQuery.isEmpty ||
          sale.invoiceNumber
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (sale.customerName
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false);

      return matchesDate && matchesSearch;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.keyboard_return_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إرجاع بيع',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'إدارة مرتجعات المبيعات',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filters
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'بحث برقم الفاتورة أو اسم العميل...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildDateButton(
                    context: context,
                    label: 'من',
                    date: _fromDate,
                    isFrom: true,
                  ),
                  const SizedBox(width: 12),
                  _buildDateButton(
                    context: context,
                    label: 'إلى',
                    date: _toDate,
                    isFrom: false,
                  ),
                ],
              ),
            ),

            // Sales List
            Expanded(
              child: Consumer<SalesProvider>(
                builder: (context, salesProvider, child) {
                  if (salesProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
                      ),
                    );
                  }

                  if (filteredSales.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد فواتير بيع',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'قم بإجراء عملية بيع أولاً من نقطة البيع',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSales.length,
                    itemBuilder: (context, index) {
                      final sale = filteredSales[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _showReturnDialog(sale),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long,
                                    color: Color(0xFFEF4444),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'فاتورة رقم: ${sale.invoiceNumber}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.green.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              sale.customerName ?? 'نقدي',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('yyyy-MM-dd')
                                                .format(sale.createdAt),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.shopping_bag,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${sale.items.length} صنف',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${sale.totalAmount.toStringAsFixed(2)} دينار',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _showReturnDialog(sale),
                                      icon: const Icon(
                                          Icons.keyboard_return_rounded,
                                          size: 18),
                                      label: const Text('إرجاع'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFEF4444),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
  }

  Widget _buildDateButton({
    required BuildContext context,
    required String label,
    required DateTime date,
    required bool isFrom,
  }) {
    return ElevatedButton.icon(
      onPressed: () => _selectDate(context, isFrom),
      icon: const Icon(Icons.calendar_today, size: 18),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
          Text(
            DateFormat('yyyy-MM-dd').format(date),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFEF4444),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFEF4444)),
        ),
      ),
    );
  }
}
