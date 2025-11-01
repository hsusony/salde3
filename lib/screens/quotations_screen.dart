import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../providers/quotations_provider.dart';
import '../models/quotation.dart';
import 'add_quotation_screen.dart';

class QuotationsScreen extends StatefulWidget {
  const QuotationsScreen({super.key});

  @override
  State<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends State<QuotationsScreen> {
  String _searchQuery = '';
  String _filterStatus =
      'الكل'; // الكل، قيد الانتظار، موافق عليه، مرفوض، محول إلى بيع

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuotationsProvider>(context, listen: false).loadQuotations();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'approved':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'converted_to_sale':
        return const Color(0xFF6366F1);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'approved':
        return 'موافق عليه';
      case 'rejected':
        return 'مرفوض';
      case 'converted_to_sale':
        return 'محول إلى بيع';
      default:
        return status;
    }
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade600;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuotationDetails(BuildContext context, Quotation quotation) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final numberFormat = NumberFormat.currency(
      symbol: 'د.ع',
      decimalDigits: 0,
      locale: 'ar_IQ',
    );
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 700),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.price_check_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'تفاصيل عرض السعر',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          quotation.quotationNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF334155) : Colors.grey[100],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // معلومات العميل
                      _buildInfoRow(
                        'العميل',
                        quotation.customerName ?? 'عميل عام',
                        Icons.person,
                      ),
                      _buildInfoRow(
                        'التاريخ',
                        dateFormat.format(quotation.createdAt),
                        Icons.calendar_today,
                      ),
                      _buildInfoRow(
                        'صالح حتى',
                        dateFormat.format(quotation.validUntil),
                        Icons.schedule,
                      ),
                      _buildInfoRow(
                        'الحالة',
                        _getStatusText(quotation.status),
                        Icons.info,
                        valueColor: _getStatusColor(quotation.status),
                      ),
                      const SizedBox(height: 24),

                      // المنتجات
                      const Text(
                        'المنتجات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF334155) : Colors.grey[100],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text('المنتج',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  Expanded(
                                      child: Text('الكمية',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  Expanded(
                                      child: Text('السعر',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  Expanded(
                                      child: Text('المجموع',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ),
                            ...quotation.items.map((item) => Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey[300]!),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(item.productName),
                                      ),
                                      Expanded(
                                        child: Text(
                                          item.quantity.toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          numberFormat.format(item.unitPrice),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          numberFormat.format(item.totalPrice),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // الملخص المالي
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              'المجموع الفرعي',
                              numberFormat.format(quotation.totalAmount),
                            ),
                            if (quotation.discount > 0)
                              _buildSummaryRow(
                                'الخصم',
                                '- ${numberFormat.format(quotation.discount)}',
                                color: Colors.red,
                              ),
                            if (quotation.tax > 0)
                              _buildSummaryRow(
                                'الضريبة',
                                '+ ${numberFormat.format(quotation.tax)}',
                                color: Colors.orange,
                              ),
                            const Divider(),
                            _buildSummaryRow(
                              'الإجمالي',
                              numberFormat.format(quotation.finalAmount),
                              isBold: true,
                              color: const Color(0xFF06B6D4),
                            ),
                          ],
                        ),
                      ),
                      if (quotation.notes != null &&
                          quotation.notes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'ملاحظات: ${quotation.notes}',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (quotation.status == 'pending') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateStatus(quotation.id!, 'approved');
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('موافقة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateStatus(quotation.id!, 'rejected');
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('رفض'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ] else if (quotation.status == 'approved') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _convertToSale(quotation);
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('تحويل إلى بيع'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إغلاق'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {Color? valueColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? (isDark ? const Color(0xFF94A3B8) : Colors.grey[700]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _updateStatus(int id, String status) async {
    final provider = Provider.of<QuotationsProvider>(context, listen: false);
    final success = await provider.updateQuotationStatus(id, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? 'تم تحديث حالة عرض السعر' : 'فشل تحديث حالة عرض السعر'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _convertToSale(Quotation quotation) {
    // TODO: تحويل عرض السعر إلى فاتورة بيع
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم تحويل عرض السعر إلى فاتورة بيع قريباً'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteQuotation(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف عرض السعر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = Provider.of<QuotationsProvider>(context, listen: false);
      final success = await provider.deleteQuotation(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'تم حذف عرض السعر' : 'فشل حذف عرض السعر'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF06B6D4),
                    const Color(0xFF06B6D4).withOpacity(0.8),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // زر الرجوع
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                    tooltip: 'رجوع',
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.price_check_rounded,
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
                          'عروض الأسعار',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'إدارة عروض الأسعار للعملاء',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddQuotationScreen(),
                        ),
                      );
                      if (mounted) {
                        Provider.of<QuotationsProvider>(context, listen: false)
                            .loadQuotations();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('عرض سعر جديد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF06B6D4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Statistics & Filter
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Consumer<QuotationsProvider>(
                    builder: (context, provider, child) {
                      final stats = provider.getStatistics();
                      final numberFormat = NumberFormat.currency(
                        symbol: 'د.ع',
                        decimalDigits: 0,
                        locale: 'ar_IQ',
                      );

                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'إجمالي عروض الأسعار',
                              stats['total'].toString(),
                              const Color(0xFF06B6D4),
                              Icons.receipt_long,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'قيد الانتظار',
                              stats['pending'].toString(),
                              const Color(0xFFF59E0B),
                              Icons.hourglass_empty,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'موافق عليه',
                              stats['approved'].toString(),
                              const Color(0xFF10B981),
                              Icons.check_circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'القيمة الإجمالية',
                              numberFormat.format(stats['totalAmount']),
                              const Color(0xFF6366F1),
                              Icons.attach_money,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'بحث في عروض الأسعار...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: _filterStatus,
                          underline: const SizedBox(),
                          items: [
                            'الكل',
                            'قيد الانتظار',
                            'موافق عليه',
                            'مرفوض',
                            'محول إلى بيع'
                          ]
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _filterStatus = value!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quotations List
            Expanded(
              child: Consumer<QuotationsProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var quotations = provider.quotations;

                  // Filter by status
                  if (_filterStatus != 'الكل') {
                    final statusMap = {
                      'قيد الانتظار': 'pending',
                      'موافق عليه': 'approved',
                      'مرفوض': 'rejected',
                      'محول إلى بيع': 'converted_to_sale',
                    };
                    final statusValue = statusMap[_filterStatus];
                    quotations = quotations
                        .where((q) => q.status == statusValue)
                        .toList();
                  }

                  // Filter by search
                  if (_searchQuery.isNotEmpty) {
                    quotations = quotations
                        .where((q) =>
                            q.quotationNumber
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            (q.customerName
                                    ?.toLowerCase()
                                    .contains(_searchQuery.toLowerCase()) ??
                                false))
                        .toList();
                  }

                  if (quotations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.price_check_rounded,
                              size: 80, 
                              color: isDark ? const Color(0xFF475569) : Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد عروض أسعار',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? const Color(0xFF64748B) : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final numberFormat = NumberFormat.currency(
                    symbol: 'د.ع',
                    decimalDigits: 0,
                    locale: 'ar_IQ',
                  );
                  final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: quotations.length,
                    itemBuilder: (context, index) {
                      final quotation = quotations[index];
                      final isExpired =
                          quotation.validUntil.isBefore(DateTime.now()) &&
                              quotation.status == 'pending';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isExpired
                                ? Colors.red.withOpacity(0.3)
                                : isDark 
                                    ? const Color(0xFF334155)
                                    : Colors.grey.shade200,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () =>
                                _showQuotationDetails(context, quotation),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _getStatusColor(quotation.status),
                                          _getStatusColor(quotation.status)
                                              .withOpacity(0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.price_check_rounded,
                                      color: Colors.white,
                                      size: 28,
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
                                              quotation.quotationNumber,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                        quotation.status)
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                _getStatusText(
                                                    quotation.status),
                                                style: TextStyle(
                                                  color: _getStatusColor(
                                                      quotation.status),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            if (isExpired) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'منتهي الصلاحية',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          quotation.customerName ?? 'عميل عام',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'صالح حتى: ${dateFormat.format(quotation.validUntil)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark ? const Color(0xFF64748B) : Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        numberFormat
                                            .format(quotation.finalAmount),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF06B6D4),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        dateFormat.format(quotation.createdAt),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton(
                                    icon: const Icon(Icons.more_vert),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'view',
                                        child: Row(
                                          children: [
                                            Icon(Icons.visibility),
                                            SizedBox(width: 8),
                                            Text('عرض التفاصيل'),
                                          ],
                                        ),
                                      ),
                                      if (quotation.status == 'pending')
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              SizedBox(width: 8),
                                              Text('تعديل'),
                                            ],
                                          ),
                                        ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete,
                                                color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('حذف',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'view') {
                                        _showQuotationDetails(
                                            context, quotation);
                                      } else if (value == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddQuotationScreen(
                                                    quotation: quotation),
                                          ),
                                        ).then((_) {
                                          Provider.of<QuotationsProvider>(
                                                  context,
                                                  listen: false)
                                              .loadQuotations();
                                        });
                                      } else if (value == 'delete') {
                                        _deleteQuotation(quotation.id!);
                                      }
                                    },
                                  ),
                                ],
                              ),
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
}
