import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/products_provider.dart';
import '../../models/inventory_transaction.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({Key? key}) : super(key: key);

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _AdjustmentItem {
  int? productId;
  String productName;
  double quantity;
  double price;
  double cost;

  _AdjustmentItem({
    this.productId,
    this.productName = '',
    this.quantity = 0,
    this.price = 0,
    this.cost = 0,
  });

  double get total => quantity * price;
  double get difference => total - (quantity * cost);
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  int? _selectedWarehouseId;
  String _transactionNumber = '';
  final List<_AdjustmentItem> _items = [];
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadWarehouses();
      context.read<ProductsProvider>().loadProducts();
      _generateTransactionNumber();
    });
    _addNewItem();
  }

  void _addNewItem() {
    setState(() {
      _items.add(_AdjustmentItem());
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items.removeAt(index);
      });
    }
  }

  double get _grandTotal {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  Future<void> _generateTransactionNumber() async {
    final number = await context
        .read<InventoryProvider>()
        .generateTransactionNumber(InventoryTransactionType.adjustment);
    setState(() => _transactionNumber = number);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2_rounded, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('تسوية مخزنية',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _addNewItem,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline,
                          color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'صف جديد',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF2D2D44), const Color(0xFF1E1E2E)]
                    : [Colors.white, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Transaction Number
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.numbers,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'رقم التسوية',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _transactionNumber,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Warehouse Selection
                  Expanded(
                    child: Consumer<InventoryProvider>(
                      builder: (context, provider, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF2D2D44) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: DropdownButtonFormField<int>(
                            value: _selectedWarehouseId,
                            decoration: InputDecoration(
                              labelText: 'المخزن',
                              prefixIcon: Icon(Icons.warehouse_rounded,
                                  color: primaryColor),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            items: provider.warehouses
                                .map((w) => DropdownMenuItem(
                                    value: w.id,
                                    child: Text(w.name,
                                        style: const TextStyle(fontSize: 14))))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedWarehouseId = value),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Table Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2D44) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildHeaderCell('المادة', flex: 3),
                          _buildHeaderCell('الكمية', flex: 1),
                          _buildHeaderCell('السعر', flex: 1),
                          _buildHeaderCell('المجموع', flex: 1),
                          _buildHeaderCell('التكلفة', flex: 1),
                          _buildHeaderCell('الفرق', flex: 1),
                          _buildHeaderCell('', flex: 0, width: 60),
                        ],
                      ),
                    ),
                    // Table Body
                    Expanded(
                      child: _items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined,
                                      size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد مواد',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'اضغط على "صف جديد" لإضافة مواد',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                return _buildItemRow(
                                    index, isDark, primaryColor);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Footer Section
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF2D2D44), const Color(0xFF1E1E2E)]
                    : [Colors.white, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Grand Total
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[400]!, Colors.green[600]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.calculate_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'المجموع الإجمالي',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_grandTotal.toStringAsFixed(2)} د.ع',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'ملاحظات',
                      hintText: 'أدخل أي ملاحظات إضافية...',
                      prefixIcon:
                          Icon(Icons.note_alt_outlined, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF1E1E2E) : Colors.grey[50],
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green[400]!, Colors.green[600]!],
                            ),
                            borderRadius: BorderRadius.circular(12),
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
                              borderRadius: BorderRadius.circular(12),
                              onTap: _saveTransaction,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_rounded,
                                      color: Colors.white, size: 24),
                                  SizedBox(width: 12),
                                  Text(
                                    'حفظ التسوية',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red[400]!, Colors.red[600]!],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.pop(context),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.close_rounded,
                                      color: Colors.white, size: 24),
                                  SizedBox(width: 12),
                                  Text(
                                    'إلغاء',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required int flex, double? width}) {
    if (width != null) {
      return SizedBox(
        width: width,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(int index, bool isDark, Color primaryColor) {
    final item = _items[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Product
            Expanded(
              flex: 3,
              child: Consumer<ProductsProvider>(
                builder: (context, provider, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D2D44) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: item.productId,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        hintText: 'اختر المادة',
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      items: provider.products
                          .map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name,
                                  style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          item.productId = value;
                          final product = provider.products
                              .firstWhere((p) => p.id == value);
                          item.productName = product.name;
                          item.price = product.sellingPrice;
                          item.cost = product.purchasePrice;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            // Quantity
            Expanded(
              flex: 1,
              child: _buildInputField(
                initialValue:
                    item.quantity == 0 ? '' : item.quantity.toString(),
                onChanged: (value) {
                  setState(() {
                    item.quantity = double.tryParse(value) ?? 0;
                  });
                },
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            // Price
            Expanded(
              flex: 1,
              child: _buildInputField(
                initialValue: item.price == 0 ? '' : item.price.toString(),
                onChanged: (value) {
                  setState(() {
                    item.price = double.tryParse(value) ?? 0;
                  });
                },
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            // Total
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber[300]!, Colors.amber[400]!],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    item.total.toStringAsFixed(0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Cost
            Expanded(
              flex: 1,
              child: _buildInputField(
                initialValue: item.cost == 0 ? '' : item.cost.toString(),
                onChanged: (value) {
                  setState(() {
                    item.cost = double.tryParse(value) ?? 0;
                  });
                },
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            // Difference
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: item.difference >= 0
                        ? [Colors.green[300]!, Colors.green[400]!]
                        : [Colors.red[300]!, Colors.red[400]!],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    item.difference.toStringAsFixed(0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Delete Button
            SizedBox(
              width: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[400]!, Colors.red[600]!],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _removeItem(index),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.delete_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String initialValue,
    required Function(String) onChanged,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (_selectedWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار المخزن')),
      );
      return;
    }

    if (_items.isEmpty || _items.every((item) => item.productId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة مادة واحدة على الأقل')),
      );
      return;
    }

    // Save each item as a separate transaction
    bool allSuccess = true;
    for (var item in _items) {
      if (item.productId != null && item.quantity > 0) {
        final transaction = InventoryTransaction(
          type: InventoryTransactionType.adjustment,
          transactionNumber: _transactionNumber,
          productId: item.productId,
          warehouseToId: _selectedWarehouseId,
          quantity: item.quantity,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        final success =
            await context.read<InventoryProvider>().addTransaction(transaction);

        if (!success) allSuccess = false;
      }
    }

    if (allSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التسوية بنجاح')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
