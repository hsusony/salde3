import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../models/inventory_transaction.dart';

class MaterialImportScreen extends StatefulWidget {
  const MaterialImportScreen({Key? key}) : super(key: key);

  @override
  State<MaterialImportScreen> createState() => _MaterialImportScreenState();
}

class _MaterialImportScreenState extends State<MaterialImportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<InventoryProvider>()
          .loadTransactions(type: InventoryTransactionType.import);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استيراد المواد'), centerTitle: true),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading)
            return const Center(child: CircularProgressIndicator());

          if (provider.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.file_download, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('لا توجد عمليات استيراد',
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
                    backgroundColor: Colors.lightBlue,
                    child: Icon(Icons.file_download, color: Colors.white),
                  ),
                  title: Text('رقم: ${transaction.transactionNumber}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الكمية: ${transaction.quantity}'),
                      if (transaction.totalCost != null)
                        Text('التكلفة: ${transaction.totalCost}'),
                      Text(
                          'التاريخ: ${transaction.transactionDate.toString().substring(0, 10)}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
