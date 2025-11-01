import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransferBondsReportScreen extends StatefulWidget {
  const TransferBondsReportScreen({super.key});

  @override
  State<TransferBondsReportScreen> createState() =>
      _TransferBondsReportScreenState();
}

class _TransferBondsReportScreenState extends State<TransferBondsReportScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  String _selectedStatus = 'الكل';

  final _currencyFormat = NumberFormat('#,##0', 'ar');
  final _dateFormat = DateFormat('yyyy-MM-dd', 'ar');

  @override
  Widget build(BuildContext context) {
    final transfers = _getDemoTransfers();
    final stats = _calculateStats(transfers);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'تقرير سندات الحوالة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF06B6D4),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.print_rounded),
            tooltip: 'طباعة',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded),
            tooltip: 'تصدير',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _fromDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _fromDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: Color(0xFF06B6D4),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(_dateFormat.format(_fromDate)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _toDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _toDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: Color(0xFF06B6D4),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(_dateFormat.format(_toDate)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      items: ['الكل', 'مكتمل', 'قيد المعالجة', 'ملغي']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'إجمالي الحوالات',
                    '${transfers.length}',
                    Icons.swap_horiz_rounded,
                    const Color(0xFF06B6D4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'المبلغ الكلي',
                    '${_currencyFormat.format(stats['totalAmount'])} د.ع',
                    Icons.payments_rounded,
                    const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'مكتملة',
                    '${stats['completedCount']}',
                    Icons.check_circle_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'قيد المعالجة',
                    '${stats['pendingCount']}',
                    Icons.pending_rounded,
                    const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'رقم الحوالة',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'التاريخ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'من حساب',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'إلى حساب',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'المبلغ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'البيان',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'الحالة',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: transfers.length,
                      itemBuilder: (context, index) {
                        final transfer = transfers[index];
                        final statusColor = transfer['status'] == 'مكتمل'
                            ? const Color(0xFF10B981)
                            : transfer['status'] == 'قيد المعالجة'
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFEF4444);

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  transfer['number'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Courier',
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _dateFormat.format(transfer['date']),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  transfer['fromAccount'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: Color(0xFF06B6D4),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        transfer['toAccount'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _currencyFormat.format(transfer['amount']),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  transfer['description'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    transfer['status'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<Map<String, dynamic>> transfers) {
    double totalAmount = 0;
    int completedCount = 0;
    int pendingCount = 0;

    for (var transfer in transfers) {
      totalAmount += transfer['amount'] as double;
      if (transfer['status'] == 'مكتمل') completedCount++;
      if (transfer['status'] == 'قيد المعالجة') pendingCount++;
    }

    return {
      'totalAmount': totalAmount,
      'completedCount': completedCount,
      'pendingCount': pendingCount,
    };
  }

  List<Map<String, dynamic>> _getDemoTransfers() {
    return [
      {
        'number': 'TR-2025-001',
        'date': DateTime(2025, 1, 5),
        'fromAccount': 'البنك الرئيسي',
        'toAccount': 'الصندوق',
        'amount': 5000000.0,
        'description': 'تمويل الصندوق',
        'status': 'مكتمل',
      },
      {
        'number': 'TR-2025-002',
        'date': DateTime(2025, 1, 8),
        'fromAccount': 'الصندوق',
        'toAccount': 'البنك الفرعي',
        'amount': 2500000.0,
        'description': 'إيداع بنكي',
        'status': 'مكتمل',
      },
      {
        'number': 'TR-2025-003',
        'date': DateTime(2025, 1, 10),
        'fromAccount': 'البنك الرئيسي',
        'toAccount': 'البنك الفرعي',
        'amount': 3000000.0,
        'description': 'نقل بين البنوك',
        'status': 'قيد المعالجة',
      },
      {
        'number': 'TR-2025-004',
        'date': DateTime(2025, 1, 12),
        'fromAccount': 'الصندوق الفرعي',
        'toAccount': 'الصندوق الرئيسي',
        'amount': 1800000.0,
        'description': 'توحيد الصناديق',
        'status': 'مكتمل',
      },
      {
        'number': 'TR-2025-005',
        'date': DateTime(2025, 1, 15),
        'fromAccount': 'البنك الرئيسي',
        'toAccount': 'حساب الرواتب',
        'amount': 4500000.0,
        'description': 'تحويل الرواتب',
        'status': 'مكتمل',
      },
      {
        'number': 'TR-2025-006',
        'date': DateTime(2025, 1, 18),
        'fromAccount': 'الصندوق',
        'toAccount': 'البنك الرئيسي',
        'amount': 3200000.0,
        'description': 'إيداع يومي',
        'status': 'مكتمل',
      },
      {
        'number': 'TR-2025-007',
        'date': DateTime(2025, 1, 20),
        'fromAccount': 'البنك الفرعي',
        'toAccount': 'الصندوق',
        'amount': 2000000.0,
        'description': 'سحب نقدي',
        'status': 'قيد المعالجة',
      },
      {
        'number': 'TR-2025-008',
        'date': DateTime(2025, 1, 22),
        'fromAccount': 'الصندوق الرئيسي',
        'toAccount': 'الصندوق الفرعي',
        'amount': 1500000.0,
        'description': 'توزيع السيولة',
        'status': 'مكتمل',
      },
    ];
  }
}
