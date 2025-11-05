import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountBalancesReportScreen extends StatefulWidget {
  const AccountBalancesReportScreen({super.key});

  @override
  State<AccountBalancesReportScreen> createState() =>
      _AccountBalancesReportScreenState();
}

class _AccountBalancesReportScreenState
    extends State<AccountBalancesReportScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _searchQuery = '';
  String _filterType = 'الكل';

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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'تقرير أرصدة الحسابات',
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
                    const SizedBox(width: 16),
                    // Filter Type
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _filterType,
                            isExpanded: true,
                            items: ['الكل', 'دائن', 'مدين', 'الرصيد صفر']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _filterType = value;
                                });
                              }
                            },
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
                    hintText: 'بحث بـ اسم الحساب...',
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
                          flex: 3,
                          child: Text(
                            'اسم الحساب',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'رقم الحساب',
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
                            'قيمة المدين',
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
                            'قيمة الدائن',
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
                        Expanded(
                          flex: 2,
                          child: Text(
                            'حالة الرصيد',
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
                            'العمليات',
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
                      itemCount: _getDemoAccounts().length,
                      itemBuilder: (context, index) {
                        final account = _getDemoAccounts()[index];
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
                                flex: 3,
                                child: Text(
                                  account['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  account['accountNo'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${_currencyFormat.format(account['debit'])} د.ع',
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
                                  '${_currencyFormat.format(account['credit'])} د.ع',
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
                                  '${_currencyFormat.format(account['balance'])} د.ع',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: account['balance'] >= 0
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: account['balance'] >= 0
                                          ? const Color(0xFF10B981)
                                              .withOpacity(0.1)
                                          : const Color(0xFFEF4444)
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      account['balance'] >= 0 ? 'دائن' : 'مدين',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: account['balance'] >= 0
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFEF4444),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.visibility_rounded,
                                        size: 20,
                                      ),
                                      tooltip: 'عرض التفاصيل',
                                      style: IconButton.styleFrom(
                                        backgroundColor: const Color(0xFF3B82F6)
                                            .withOpacity(0.1),
                                        foregroundColor:
                                            const Color(0xFF3B82F6),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.print_rounded,
                                        size: 20,
                                      ),
                                      tooltip: 'طباعة',
                                      style: IconButton.styleFrom(
                                        backgroundColor: const Color(0xFF10B981)
                                            .withOpacity(0.1),
                                        foregroundColor:
                                            const Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
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

  List<Map<String, dynamic>> _getDemoAccounts() {
    // بيانات نموذجية للحسابات
    return [
      {
        'accountNo': '1001',
        'name': 'الصندوق الرئيسي',
        'type': 'أصول',
        'debit': 5000000.0,
        'credit': 2000000.0,
        'balance': 3000000.0,
      },
      {
        'accountNo': '1002',
        'name': 'البنك العربي',
        'type': 'أصول',
        'debit': 8000000.0,
        'credit': 3000000.0,
        'balance': 5000000.0,
      },
      {
        'accountNo': '1003',
        'name': 'العملاء - حساب جاري',
        'type': 'أصول',
        'debit': 12000000.0,
        'credit': 7000000.0,
        'balance': 5000000.0,
      },
      {
        'accountNo': '2001',
        'name': 'الموردين',
        'type': 'خصوم',
        'debit': 4000000.0,
        'credit': 9000000.0,
        'balance': -5000000.0,
      },
      {
        'accountNo': '3001',
        'name': 'رأس المال',
        'type': 'حقوق ملكية',
        'debit': 0.0,
        'credit': 10000000.0,
        'balance': -10000000.0,
      },
      {
        'accountNo': '4001',
        'name': 'المبيعات',
        'type': 'إيرادات',
        'debit': 5000000.0,
        'credit': 20000000.0,
        'balance': -15000000.0,
      },
      {
        'accountNo': '5001',
        'name': 'تكلفة البضاعة المباعة',
        'type': 'مصروفات',
        'debit': 12000000.0,
        'credit': 0.0,
        'balance': 12000000.0,
      },
      {
        'accountNo': '5002',
        'name': 'الرواتب والأجور',
        'type': 'مصروفات',
        'debit': 3000000.0,
        'credit': 0.0,
        'balance': 3000000.0,
      },
      {
        'accountNo': '5003',
        'name': 'الإيجار',
        'type': 'مصروفات',
        'debit': 1200000.0,
        'credit': 0.0,
        'balance': 1200000.0,
      },
      {
        'accountNo': '5004',
        'name': 'الكهرباء والماء',
        'type': 'مصروفات',
        'debit': 500000.0,
        'credit': 0.0,
        'balance': 500000.0,
      },
    ];
  }
}
