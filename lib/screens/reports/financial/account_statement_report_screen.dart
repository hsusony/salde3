import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountStatementReportScreen extends StatefulWidget {
  const AccountStatementReportScreen({super.key});

  @override
  State<AccountStatementReportScreen> createState() =>
      _AccountStatementReportScreenState();
}

class _AccountStatementReportScreenState
    extends State<AccountStatementReportScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _selectedAccount = 'الكل';
  String _searchQuery = '';

  final _currencyFormat = NumberFormat('#,##0', 'ar');
  final _dateFormat = DateFormat('yyyy/MM/dd', 'ar');

  @override
  void initState() {
    super.initState();
    _fromDate = DateTime.now().subtract(const Duration(days: 30));
    _toDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B981),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _getFilteredTransactions();
    final summary = _calculateSummary(transactions);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'كشف حساب',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
          // Filters Section
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
                    // Account Selection
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedAccount,
                            isExpanded: true,
                            hint: const Text('اختر الحساب'),
                            items: [
                              'الكل',
                              // TODO: استبدل هذه القائمة بجلب الحسابات من قاعدة البيانات
                            ]
                                .map((account) => DropdownMenuItem(
                                      value: account,
                                      child: Text(account),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedAccount = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // From Date
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 20,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'من تاريخ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      _fromDate != null
                                          ? _dateFormat.format(_fromDate!)
                                          : 'اختر التاريخ',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // To Date
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 20,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'إلى تاريخ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      _toDate != null
                                          ? _dateFormat.format(_toDate!)
                                          : 'اختر التاريخ',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'بحث بـ البيان أو رقم السند...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF10B981),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF10B981),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'إجمالي المدين',
                    '${_currencyFormat.format(summary['totalDebit'])} د.ع',
                    Icons.arrow_upward_rounded,
                    const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'إجمالي الدائن',
                    '${_currencyFormat.format(summary['totalCredit'])} د.ع',
                    Icons.arrow_downward_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'الرصيد الحالي',
                    '${_currencyFormat.format(summary['balance'])} د.ع',
                    Icons.account_balance_wallet_rounded,
                    summary['balance'] >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'عدد الحركات',
                    '${transactions.length}',
                    Icons.receipt_long_rounded,
                    const Color(0xFF3B82F6),
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
                  // Table Header
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
                          flex: 1,
                          child: Text(
                            'ت',
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
                            'رقم السند',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
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
                            'المدين',
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
                            'الدائن',
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
                            'الرصيد',
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
                  // Table Body
                  Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
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
                                flex: 1,
                                child: Text('${index + 1}'),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _dateFormat.format(transaction['date']),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  transaction['docNo'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  transaction['description'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  transaction['debit'] > 0
                                      ? '${_currencyFormat.format(transaction['debit'])} د.ع'
                                      : '-',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  transaction['credit'] > 0
                                      ? '${_currencyFormat.format(transaction['credit'])} د.ع'
                                      : '-',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${_currencyFormat.format(transaction['balance'])} د.ع',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: transaction['balance'] >= 0
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const Spacer(),
            ],
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredTransactions() {
    final allTransactions = _getDemoTransactions();
    return allTransactions.where((transaction) {
      final matchesAccount = _selectedAccount == 'الكل' ||
          transaction['account'] == _selectedAccount;
      final matchesSearch = _searchQuery.isEmpty ||
          transaction['description']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          transaction['docNo']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesAccount && matchesSearch;
    }).toList();
  }

  Map<String, dynamic> _calculateSummary(
      List<Map<String, dynamic>> transactions) {
    double totalDebit = 0;
    double totalCredit = 0;

    for (var transaction in transactions) {
      totalDebit += transaction['debit'];
      totalCredit += transaction['credit'];
    }

    return {
      'totalDebit': totalDebit,
      'totalCredit': totalCredit,
      'balance': totalCredit - totalDebit,
    };
  }

  List<Map<String, dynamic>> _getDemoTransactions() {
    // بيانات نموذجية للعرض
    double runningBalance = 0;
    final rawTransactions = <Map<String, dynamic>>[
      {
        'date': DateTime(2025, 1, 1),
        'docNo': 'V-001',
        'description': 'رصيد افتتاحي',
        'account': 'الصندوق',
        'debit': 0.0,
        'credit': 5000000.0,
      },
      {
        'date': DateTime(2025, 1, 5),
        'docNo': 'V-002',
        'description': 'مبيعات نقدية',
        'account': 'الصندوق',
        'debit': 0.0,
        'credit': 1500000.0,
      },
      {
        'date': DateTime(2025, 1, 8),
        'docNo': 'V-003',
        'description': 'شراء بضاعة',
        'account': 'الصندوق',
        'debit': 800000.0,
        'credit': 0.0,
      },
      {
        'date': DateTime(2025, 1, 10),
        'docNo': 'V-004',
        'description': 'تحويل إلى البنك',
        'account': 'الصندوق',
        'debit': 2000000.0,
        'credit': 0.0,
      },
      {
        'date': DateTime(2025, 1, 12),
        'docNo': 'V-005',
        'description': 'مبيعات آجلة',
        'account': 'الصندوق',
        'debit': 0.0,
        'credit': 2500000.0,
      },
      {
        'date': DateTime(2025, 1, 15),
        'docNo': 'V-006',
        'description': 'دفع إيجار',
        'account': 'الصندوق',
        'debit': 500000.0,
        'credit': 0.0,
      },
      {
        'date': DateTime(2025, 1, 18),
        'docNo': 'V-007',
        'description': 'مبيعات نقدية',
        'account': 'الصندوق',
        'debit': 0.0,
        'credit': 1800000.0,
      },
      {
        'date': DateTime(2025, 1, 20),
        'docNo': 'V-008',
        'description': 'مصروفات عمومية',
        'account': 'الصندوق',
        'debit': 300000.0,
        'credit': 0.0,
      },
      {
        'date': DateTime(2025, 1, 22),
        'docNo': 'V-009',
        'description': 'تحصيل من عملاء',
        'account': 'الصندوق',
        'debit': 0.0,
        'credit': 3000000.0,
      },
      {
        'date': DateTime(2025, 1, 25),
        'docNo': 'V-010',
        'description': 'رواتب موظفين',
        'account': 'الصندوق',
        'debit': 1200000.0,
        'credit': 0.0,
      },
    ];

    final transactions = <Map<String, dynamic>>[];

    // Calculate running balance
    for (var transaction in rawTransactions) {
      runningBalance +=
          (transaction['credit'] as double) - (transaction['debit'] as double);
      transaction['balance'] = runningBalance;
      transactions.add(transaction);
    }

    return transactions;
  }
}
