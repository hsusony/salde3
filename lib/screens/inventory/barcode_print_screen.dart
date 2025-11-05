import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../providers/products_provider.dart';
import '../../models/product.dart';

class BarcodePrintScreen extends StatefulWidget {
  const BarcodePrintScreen({Key? key}) : super(key: key);

  @override
  State<BarcodePrintScreen> createState() => _BarcodePrintScreenState();
}

class _BarcodePrintScreenState extends State<BarcodePrintScreen> {
  int? _selectedProductId;
  Product? _selectedProduct;
  int _copies = 1;
  double _barcodeWidth = 200;
  double _barcodeHeight = 80;
  String _barcodeType = 'Code128';
  bool _showPrice = true;
  bool _showName = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('طباعة باركود'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بطاقة اختيار المنتج
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.qr_code_2,
                              color: Color(0xFF6366F1),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'اختيار المنتج',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Consumer<ProductsProvider>(
                        builder: (context, provider, child) {
                          return DropdownButtonFormField<int>(
                            value: _selectedProductId,
                            decoration: InputDecoration(
                              labelText: 'المنتج',
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
                              return DropdownMenuItem(
                                value: product.id,
                                child: Text(
                                  '${product.name} - ${product.barcode}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedProductId = value;
                                _selectedProduct = provider.products
                                    .firstWhere((p) => p.id == value);
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // بطاقة إعدادات الطباعة
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.settings,
                              color: Color(0xFF10B981),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'إعدادات الطباعة',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // عدد النسخ
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'عدد النسخ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (_copies > 1) {
                                setState(() => _copies--);
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                            color: const Color(0xFF6366F1),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_copies',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (_copies < 100) {
                                setState(() => _copies++);
                              }
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            color: const Color(0xFF6366F1),
                          ),
                        ],
                      ),
                      const Divider(height: 32),

                      // حجم الباركود
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

                      // نوع الباركود
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
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Code128',
                            child: Text('Code 128'),
                          ),
                          DropdownMenuItem(
                            value: 'Code39',
                            child: Text('Code 39'),
                          ),
                          DropdownMenuItem(
                            value: 'EAN13',
                            child: Text('EAN 13'),
                          ),
                          DropdownMenuItem(
                            value: 'EAN8',
                            child: Text('EAN 8'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _barcodeType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // خيارات العرض
                      SwitchListTile(
                        title: const Text('عرض اسم المنتج'),
                        value: _showName,
                        activeColor: const Color(0xFF6366F1),
                        onChanged: (value) {
                          setState(() => _showName = value);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('عرض السعر'),
                        value: _showPrice,
                        activeColor: const Color(0xFF6366F1),
                        onChanged: (value) {
                          setState(() => _showPrice = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // بطاقة المعاينة
              if (_selectedProduct != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.preview,
                                color: Color(0xFFF59E0B),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'معاينة الباركود',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              if (_showName)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    _selectedProduct!.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              BarcodeWidget(
                                barcode: _getBarcodeType(),
                                data: _selectedProduct!.barcode,
                                width: _barcodeWidth,
                                height: _barcodeHeight,
                                drawText: true,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                              if (_showPrice)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'السعر: ${_selectedProduct!.sellingPrice.toStringAsFixed(0)} د.ع',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // زر الطباعة
              ElevatedButton.icon(
                onPressed: _selectedProduct != null ? _printBarcode : null,
                icon: const Icon(Icons.print, size: 28),
                label: const Text(
                  'طباعة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  void _printBarcode() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                  ),
                  borderRadius: const BorderRadius.only(
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
                      child: const Icon(
                        Icons.preview,
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
                            'معاينة قبل الطباعة',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'تأكد من صحة البيانات قبل الطباعة',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
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

              // Body with preview
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Product Info Card
                        Card(
                          elevation: 2,
                          color: isDark
                              ? const Color(0xFF334155)
                              : Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: isDark
                                          ? const Color(0xFF818CF8)
                                          : const Color(0xFF6366F1),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'معلومات المنتج',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                _buildInfoRow(
                                  'اسم المنتج',
                                  _selectedProduct!.name,
                                  Icons.inventory_2,
                                  isDark,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'رقم الباركود',
                                  _selectedProduct!.barcode,
                                  Icons.qr_code_2,
                                  isDark,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'السعر',
                                  '${_selectedProduct!.sellingPrice.toStringAsFixed(0)} د.ع',
                                  Icons.attach_money,
                                  isDark,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'عدد النسخ',
                                  '$_copies نسخة',
                                  Icons.print,
                                  isDark,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'نوع الباركود',
                                  _barcodeType,
                                  Icons.category,
                                  isDark,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Barcode Preview Grid
                        Text(
                          'معاينة الباركودات ($_copies نسخة)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Grid of barcodes
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: List.generate(
                            _copies > 20 ? 20 : _copies, // Max 20 in preview
                            (index) => Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      const Color(0xFF6366F1).withOpacity(0.3),
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
                                      child: Text(
                                        _selectedProduct!.name,
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
                                  BarcodeWidget(
                                    barcode: _getBarcodeType(),
                                    data: _selectedProduct!.barcode,
                                    width: _barcodeWidth * 0.7,
                                    height: _barcodeHeight * 0.7,
                                    drawText: true,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (_showPrice)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        '${_selectedProduct!.sellingPrice.toStringAsFixed(0)} د.ع',
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
                          ),
                        ),

                        if (_copies > 20)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              'عرض 20 باركود من أصل $_copies',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isDark ? Colors.white70 : Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer with actions
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border(
                    top: BorderSide(
                      color:
                          isDark ? const Color(0xFF334155) : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text(
                        'إلغاء',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDark ? Colors.white70 : Colors.grey[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.white),
                                const SizedBox(width: 12),
                                Text(
                                  'تم إرسال $_copies نسخة من الباركود إلى الطابعة',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      icon: const Icon(Icons.print, size: 24),
                      label: const Text(
                        'تأكيد الطباعة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
