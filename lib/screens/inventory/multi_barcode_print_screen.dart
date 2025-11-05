import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../providers/products_provider.dart';
import '../../models/product.dart';

class MultiBarcodePrintScreen extends StatefulWidget {
  const MultiBarcodePrintScreen({Key? key}) : super(key: key);

  @override
  State<MultiBarcodePrintScreen> createState() =>
      _MultiBarcodePrintScreenState();
}

class _MultiBarcodeItem {
  final Product product;
  int copies;

  _MultiBarcodeItem({required this.product, this.copies = 1});
}

class _MultiBarcodePrintScreenState extends State<MultiBarcodePrintScreen> {
  final List<_MultiBarcodeItem> _selectedProducts = [];
  double _barcodeWidth = 200;
  double _barcodeHeight = 80;
  String _barcodeType = 'Code128';
  bool _showPrice = true;
  bool _showName = true;
  int? _currentProductId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadProducts();
    });
  }

  int get _totalCopies =>
      _selectedProducts.fold(0, (sum, item) => sum + item.copies);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('طباعة باركود متعدد'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          if (_selectedProducts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'المجموع: $_totalCopies',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // Right Panel - Product Selection
            Expanded(
              flex: 2,
              child: Container(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: Column(
                  children: [
                    // Add Product Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            isDark ? const Color(0xFF334155) : Colors.grey[100],
                        border: Border(
                          bottom: BorderSide(
                            color: isDark
                                ? const Color(0xFF475569)
                                : Colors.grey[300]!,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF6366F1).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.add_shopping_cart,
                                  color: Color(0xFF6366F1),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'إضافة منتجات',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Consumer<ProductsProvider>(
                            builder: (context, provider, child) {
                              return DropdownButtonFormField<int>(
                                value: _currentProductId,
                                decoration: InputDecoration(
                                  labelText: 'اختر المنتج',
                                  prefixIcon: const Icon(Icons.inventory_2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                ),
                                items: provider.products.map((product) {
                                  final isSelected = _selectedProducts.any(
                                      (item) => item.product.id == product.id);
                                  return DropdownMenuItem(
                                    value: product.id,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${product.name} - ${product.barcode}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF10B981),
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _currentProductId = value);
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _currentProductId != null
                                  ? _addProduct
                                  : null,
                              icon: const Icon(Icons.add),
                              label: const Text('إضافة إلى القائمة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Selected Products List
                    Expanded(
                      child: _selectedProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 80,
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لم تقم بإضافة أي منتج بعد',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _selectedProducts.length,
                              itemBuilder: (context, index) {
                                final item = _selectedProducts[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: const Color(0xFF6366F1)
                                          .withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
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
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isDark
                                                          ? Colors.white
                                                          : Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    item.product.barcode,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: isDark
                                                          ? Colors.white60
                                                          : Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _selectedProducts
                                                      .removeAt(index);
                                                });
                                              },
                                              icon: const Icon(Icons.delete),
                                              color: Colors.red,
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 16),
                                        Row(
                                          children: [
                                            const Text('عدد النسخ:',
                                                style: TextStyle(fontSize: 14)),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              onPressed: () {
                                                if (item.copies > 1) {
                                                  setState(() => item.copies--);
                                                }
                                              },
                                              icon: const Icon(
                                                  Icons.remove_circle_outline),
                                              color: const Color(0xFF6366F1),
                                              iconSize: 28,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF6366F1)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${item.copies}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF6366F1),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                if (item.copies < 100) {
                                                  setState(() => item.copies++);
                                                }
                                              },
                                              icon: const Icon(
                                                  Icons.add_circle_outline),
                                              color: const Color(0xFF6366F1),
                                              iconSize: 28,
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

                    // Bottom Actions
                    if (_selectedProducts.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155)
                              : Colors.grey[100],
                          border: Border(
                            top: BorderSide(
                              color: isDark
                                  ? const Color(0xFF475569)
                                  : Colors.grey[300]!,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'إجمالي النسخ:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$_totalCopies',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedProducts.clear();
                                        _currentProductId = null;
                                      });
                                    },
                                    icon: const Icon(Icons.clear_all),
                                    label: const Text('مسح الكل'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _showPreview,
                                    icon: const Icon(Icons.preview),
                                    label: const Text('معاينة'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6366F1),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Left Panel - Settings
            Container(
              width: 320,
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Color(0xFF10B981),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'إعدادات الباركود',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'العرض: ${_barcodeWidth.toInt()} px',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                    Slider(
                      value: _barcodeWidth,
                      min: 150,
                      max: 400,
                      divisions: 25,
                      activeColor: const Color(0xFF6366F1),
                      onChanged: (value) {
                        setState(() => _barcodeWidth = value);
                      },
                    ),
                    Text(
                      'الارتفاع: ${_barcodeHeight.toInt()} px',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                    Slider(
                      value: _barcodeHeight,
                      min: 50,
                      max: 150,
                      divisions: 20,
                      activeColor: const Color(0xFF6366F1),
                      onChanged: (value) {
                        setState(() => _barcodeHeight = value);
                      },
                    ),
                    const Divider(height: 32),
                    DropdownButtonFormField<String>(
                      value: _barcodeType,
                      decoration: InputDecoration(
                        labelText: 'نوع الباركود',
                        prefixIcon: const Icon(Icons.qr_code),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF1E293B) : Colors.grey[50],
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Code128', child: Text('Code 128')),
                        DropdownMenuItem(
                            value: 'Code39', child: Text('Code 39')),
                        DropdownMenuItem(value: 'EAN13', child: Text('EAN 13')),
                        DropdownMenuItem(value: 'EAN8', child: Text('EAN 8')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _barcodeType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('عرض اسم المنتج'),
                      value: _showName,
                      activeColor: const Color(0xFF6366F1),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() => _showName = value);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('عرض السعر'),
                      value: _showPrice,
                      activeColor: const Color(0xFF6366F1),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() => _showPrice = value);
                      },
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

  void _addProduct() {
    if (_currentProductId == null) return;

    final provider = context.read<ProductsProvider>();
    final product =
        provider.products.firstWhere((p) => p.id == _currentProductId);

    // Check if already added
    final existingIndex =
        _selectedProducts.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      // Increase copies
      setState(() {
        _selectedProducts[existingIndex].copies++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم زيادة عدد نسخ ${product.name}'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      // Add new
      setState(() {
        _selectedProducts.add(_MultiBarcodeItem(product: product));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة ${product.name} إلى القائمة'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Barcode _getBarcodeType() {
    switch (_barcodeType) {
      case 'Code39':
        return Barcode.code39();
      case 'EAN13':
        return Barcode.ean13();
      case 'EAN8':
        return Barcode.ean8();
      default:
        return Barcode.code128();
    }
  }

  void _showPreview() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 800),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.preview,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معاينة الباركودات',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'إجمالي $_totalCopies نسخة',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      iconSize: 28,
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: _selectedProducts.expand((item) {
                        return List.generate(
                          item.copies > 50 ? 50 : item.copies,
                          (index) => Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_showName)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: SizedBox(
                                      width: _barcodeWidth * 0.7,
                                      child: Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                BarcodeWidget(
                                  barcode: _getBarcodeType(),
                                  data: item.product.barcode,
                                  width: _barcodeWidth * 0.7,
                                  height: _barcodeHeight * 0.7,
                                  drawText: true,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black),
                                ),
                                if (_showPrice)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      '${item.product.sellingPrice.toStringAsFixed(0)} د.ع',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label:
                          const Text('إلغاء', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('تم إرسال $_totalCopies نسخة إلى الطابعة'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.print, size: 24),
                      label: const Text('طباعة',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
