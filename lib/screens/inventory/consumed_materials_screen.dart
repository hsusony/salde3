import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/products_provider.dart';
import '../../models/inventory_transaction.dart';
import '../../models/product.dart';
import '../../models/warehouse.dart';

class ConsumedMaterialsScreen extends StatefulWidget {
  const ConsumedMaterialsScreen({Key? key}) : super(key: key);

  @override
  State<ConsumedMaterialsScreen> createState() =>
      _ConsumedMaterialsScreenState();
}

class _ConsumedMaterialsScreenState extends State<ConsumedMaterialsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<InventoryProvider>()
          .loadTransactions(type: InventoryTransactionType.consumed);
      context.read<ProductsProvider>().loadProducts();
      context.read<InventoryProvider>().loadWarehouses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المواد المستهلكة'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddConsumedMaterialDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة مواد مستهلكة'),
        backgroundColor: Colors.brown,
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading)
            return const Center(child: CircularProgressIndicator());

          if (provider.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('لا توجد مواد مستهلكة',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.transactions.length,
            itemBuilder: (context, index) {
              final transaction = provider.transactions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.brown,
                    child: Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                  title: Text('رقم: ${transaction.transactionNumber}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الكمية: ${transaction.quantity}'),
                      Text(
                          'التاريخ: ${transaction.transactionDate.toString().substring(0, 10)}'),
                      if (transaction.notes != null)
                        Text('ملاحظات: ${transaction.notes}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, transaction),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddConsumedMaterialDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    int? selectedProductId;
    int? selectedWarehouseId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final inventoryProvider = context.watch<InventoryProvider>();
          final productsProvider = context.watch<ProductsProvider>();

          // Generate transaction number
          final transactionNumber =
              'CON-${DateTime.now().millisecondsSinceEpoch}';

          return AlertDialog(
            title: const Text('إضافة مواد مستهلكة'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Transaction Number (Read-only)
                    TextFormField(
                      initialValue: transactionNumber,
                      decoration: const InputDecoration(
                        labelText: 'رقم العملية',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    // Product Dropdown
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'المنتج',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedProductId,
                      items: productsProvider.products.map((product) {
                        return DropdownMenuItem<int>(
                          value: product.id,
                          child: Text(product.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProductId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) return 'الرجاء اختيار المنتج';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Warehouse Dropdown
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'المخزن',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedWarehouseId,
                      items: inventoryProvider.warehouses.map((warehouse) {
                        return DropdownMenuItem<int>(
                          value: warehouse.id,
                          child: Text(warehouse.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedWarehouseId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) return 'الرجاء اختيار المخزن';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quantity
                    TextFormField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'الكمية',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال الكمية';
                        }
                        if (double.tryParse(value) == null) {
                          return 'الرجاء إدخال رقم صحيح';
                        }
                        if (double.parse(value) <= 0) {
                          return 'الكمية يجب أن تكون أكبر من صفر';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
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
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final transaction = InventoryTransaction(
                    type: InventoryTransactionType.consumed,
                    transactionNumber: transactionNumber,
                    productId: selectedProductId,
                    warehouseFromId: selectedWarehouseId,
                    quantity: double.parse(quantityController.text),
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                  );

                  final success = await context
                      .read<InventoryProvider>()
                      .addTransaction(transaction);

                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إضافة المواد المستهلكة بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                ),
                child: const Text('حفظ'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, InventoryTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف العملية رقم ${transaction.transactionNumber}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await context
                  .read<InventoryProvider>()
                  .deleteTransaction(transaction.id!);

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف العملية بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
