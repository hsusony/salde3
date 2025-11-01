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

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedWarehouseId;
  int? _selectedProductId;
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  String _transactionNumber = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadWarehouses();
      context.read<ProductsProvider>().loadProducts();
      _generateTransactionNumber();
    });
  }

  Future<void> _generateTransactionNumber() async {
    final number = await context
        .read<InventoryProvider>()
        .generateTransactionNumber(InventoryTransactionType.adjustment);
    setState(() => _transactionNumber = number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسوية مخزنية'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('رقم المعاملة: $_transactionNumber',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Consumer<InventoryProvider>(
                      builder: (context, provider, child) {
                        return DropdownButtonFormField<int>(
                          value: _selectedWarehouseId,
                          decoration: const InputDecoration(
                              labelText: 'المخزن',
                              border: OutlineInputBorder()),
                          items: provider.warehouses
                              .map((w) => DropdownMenuItem(
                                  value: w.id, child: Text(w.name)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedWarehouseId = value),
                          validator: (value) =>
                              value == null ? 'الرجاء اختيار المخزن' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Consumer<ProductsProvider>(
                      builder: (context, provider, child) {
                        return DropdownButtonFormField<int>(
                          value: _selectedProductId,
                          decoration: const InputDecoration(
                              labelText: 'المنتج',
                              border: OutlineInputBorder()),
                          items: provider.products
                              .map((p) => DropdownMenuItem(
                                  value: p.id, child: Text(p.name)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedProductId = value),
                          validator: (value) =>
                              value == null ? 'الرجاء اختيار المنتج' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'الكمية الصحيحة',
                        border: OutlineInputBorder(),
                        helperText: 'الكمية الفعلية الموجودة في المخزن',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'الرجاء إدخال الكمية';
                        if (double.tryParse(value) == null)
                          return 'الرجاء إدخال رقم صحيح';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                          labelText: 'ملاحظات', border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveTransaction,
              icon: const Icon(Icons.save),
              label: const Text('حفظ التسوية'),
              style:
                  ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final transaction = InventoryTransaction(
      type: InventoryTransactionType.adjustment,
      transactionNumber: _transactionNumber,
      productId: _selectedProductId,
      warehouseToId: _selectedWarehouseId,
      quantity: double.parse(_quantityController.text),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    final success =
        await context.read<InventoryProvider>().addTransaction(transaction);

    if (success && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم حفظ التسوية بنجاح')));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
