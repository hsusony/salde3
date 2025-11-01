import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';

class BarcodePrintScreen extends StatefulWidget {
  const BarcodePrintScreen({Key? key}) : super(key: key);

  @override
  State<BarcodePrintScreen> createState() => _BarcodePrintScreenState();
}

class _BarcodePrintScreenState extends State<BarcodePrintScreen> {
  int? _selectedProductId;

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
      appBar: AppBar(title: const Text('طباعة باركود'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Consumer<ProductsProvider>(
                      builder: (context, provider, child) {
                        return DropdownButtonFormField<int>(
                          value: _selectedProductId,
                          decoration: const InputDecoration(
                            labelText: 'اختر المنتج',
                            border: OutlineInputBorder(),
                          ),
                          items: provider.products.map((product) {
                            return DropdownMenuItem(
                              value: product.id,
                              child:
                                  Text('${product.name} - ${product.barcode}'),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedProductId = value),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed:
                          _selectedProductId != null ? _printBarcode : null,
                      icon: const Icon(Icons.print),
                      label: const Text('طباعة'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _printBarcode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة وظيفة الطباعة قريباً')),
    );
  }
}
