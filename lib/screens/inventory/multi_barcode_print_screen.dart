import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';

class MultiBarcodePrintScreen extends StatefulWidget {
  const MultiBarcodePrintScreen({Key? key}) : super(key: key);

  @override
  State<MultiBarcodePrintScreen> createState() =>
      _MultiBarcodePrintScreenState();
}

class _MultiBarcodePrintScreenState extends State<MultiBarcodePrintScreen> {
  final List<int> _selectedProductIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('طباعة باركود متعدد'), centerTitle: true),
      body: Consumer<ProductsProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    final product = provider.products[index];
                    final isSelected = _selectedProductIds.contains(product.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedProductIds.add(product.id!);
                            } else {
                              _selectedProductIds.remove(product.id);
                            }
                          });
                        },
                        title: Text(product.name),
                        subtitle: Text('الباركود: ${product.barcode}'),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed:
                      _selectedProductIds.isNotEmpty ? _printBarcodes : null,
                  icon: const Icon(Icons.print),
                  label: Text('طباعة ${_selectedProductIds.length} باركود'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _printBarcodes() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('سيتم طباعة ${_selectedProductIds.length} باركود')),
    );
  }
}
