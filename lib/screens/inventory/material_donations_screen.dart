import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../models/inventory_transaction.dart';

class MaterialDonationsScreen extends StatefulWidget {
  const MaterialDonationsScreen({Key? key}) : super(key: key);

  @override
  State<MaterialDonationsScreen> createState() =>
      _MaterialDonationsScreenState();
}

class _MaterialDonationsScreenState extends State<MaterialDonationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<InventoryProvider>()
          .loadTransactions(type: InventoryTransactionType.donation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إهداء المواد'), centerTitle: true),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading)
            return const Center(child: CircularProgressIndicator());

          if (provider.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('لا توجد إهداءات',
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
                    backgroundColor: Colors.pink,
                    child: Icon(Icons.card_giftcard, color: Colors.white),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
