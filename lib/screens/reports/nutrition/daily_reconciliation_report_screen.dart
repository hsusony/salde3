import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyReconciliationReportScreen extends StatefulWidget {
  const DailyReconciliationReportScreen({super.key});

  @override
  State<DailyReconciliationReportScreen> createState() =>
      _DailyReconciliationReportScreenState();
}

class _DailyReconciliationReportScreenState
    extends State<DailyReconciliationReportScreen> {
  DateTime _selectedDate = DateTime.now();

  final _currencyFormat = NumberFormat('#,##0', 'ar');
  final _dateFormat = DateFormat('yyyy-MM-dd', 'ar');

  @override
  Widget build(BuildContext context) {
    final reconciliationData = _getDemoReconciliationData();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'المطابقة اليومية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF10B981),
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
          // Date Filter
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
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
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
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'التاريخ: ${_dateFormat.format(_selectedDate)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Summary Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'النظام',
                    '${_currencyFormat.format(reconciliationData['systemTotal'])} د.ع',
                    Icons.computer_rounded,
                    const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'الصندوق الفعلي',
                    '${_currencyFormat.format(reconciliationData['actualTotal'])} د.ع',
                    Icons.account_balance_wallet_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'الفرق',
                    '${_currencyFormat.format(reconciliationData['difference'])} د.ع',
                    reconciliationData['difference'] == 0
                        ? Icons.check_circle_rounded
                        : Icons.warning_rounded,
                    reconciliationData['difference'] == 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'الحالة',
                    reconciliationData['difference'] == 0
                        ? 'متطابق'
                        : 'غير متطابق',
                    reconciliationData['difference'] == 0
                        ? Icons.verified_rounded
                        : Icons.error_rounded,
                    reconciliationData['difference'] == 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Details Table
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
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'البيان',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'حسب النظام',
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
                            'حسب الصندوق',
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
                            'الفرق',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
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
                      itemCount: reconciliationData['items'].length,
                      itemBuilder: (context, index) {
                        final item = reconciliationData['items'][index];
                        final difference = item['difference'] as double;
                        final isMatched = difference == 0;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: !isMatched
                                ? const Color(0xFFEF4444).withOpacity(0.05)
                                : null,
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
                                flex: 3,
                                child: Text(
                                  item['description'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${_currencyFormat.format(item['systemAmount'])} د.ع',
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
                                  '${_currencyFormat.format(item['actualAmount'])} د.ع',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${_currencyFormat.format(difference.abs())} د.ع',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isMatched
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Icon(
                                  isMatched
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  color: isMatched
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                  size: 20,
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

  Map<String, dynamic> _getDemoReconciliationData() {
    final items = [
      {
        'description': 'الرصيد الافتتاحي',
        'systemAmount': 5000000.0,
        'actualAmount': 5000000.0,
        'difference': 0.0,
      },
      {
        'description': 'مبيعات نقدية',
        'systemAmount': 8800000.0,
        'actualAmount': 8750000.0,
        'difference': -50000.0,
      },
      {
        'description': 'تحصيلات',
        'systemAmount': 5500000.0,
        'actualAmount': 5500000.0,
        'difference': 0.0,
      },
      {
        'description': 'مدفوعات للموردين',
        'systemAmount': 4500000.0,
        'actualAmount': 4500000.0,
        'difference': 0.0,
      },
      {
        'description': 'مصروفات إدارية',
        'systemAmount': 800000.0,
        'actualAmount': 850000.0,
        'difference': 50000.0,
      },
      {
        'description': 'رواتب',
        'systemAmount': 3700000.0,
        'actualAmount': 3700000.0,
        'difference': 0.0,
      },
    ];

    double systemTotal = 0;
    double actualTotal = 0;

    for (var item in items) {
      systemTotal += (item['systemAmount'] as double) -
          (item['description'] == 'الرصيد الافتتاحي' ? 0 : 0);
      actualTotal += (item['actualAmount'] as double) -
          (item['description'] == 'الرصيد الافتتاحي' ? 0 : 0);
    }

    return {
      'items': items,
      'systemTotal': 10300000.0,
      'actualTotal': 10300000.0,
      'difference': 0.0,
    };
  }
}
