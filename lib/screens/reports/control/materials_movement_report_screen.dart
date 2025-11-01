import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MaterialsMovementReportScreen extends StatefulWidget {
  const MaterialsMovementReportScreen({super.key});

  @override
  State<MaterialsMovementReportScreen> createState() =>
      _MaterialsMovementReportScreenState();
}

class _MaterialsMovementReportScreenState
    extends State<MaterialsMovementReportScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  String _selectedMaterial = 'المواد';
  String _selectedMovementType = 'نوع الحركة';
  String _selectedWarehouse = 'المخزن';
  bool _showOpeningBalance = false;
  bool _showClosingBalance = false;
  bool _showDetails = false;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0891B2),
              onPrimary: Colors.white,
              onSurface: Colors.black,
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
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Modern Header
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0891B2),
                  Color(0xFF0E7490),
                  Color(0xFF155E75),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0891B2).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Back Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حركة المواد',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'عرض حركات استلام واستخدام المواد',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action Buttons
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.print_rounded),
                            color: Colors.white,
                            tooltip: 'طباعة',
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.download_rounded),
                            color: Colors.white,
                            tooltip: 'تصدير',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filters Section
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                // First Row - Dates and Dropdowns
                Row(
                  children: [
                    // From Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'من',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _dateFormat.format(_fromDate),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 18,
                                    color: Color(0xFF0891B2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // To Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الى',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _dateFormat.format(_toDate),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 18,
                                    color: Color(0xFF0891B2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Material Dropdown
                    Expanded(
                      child: _buildDropdown('المادة', _selectedMaterial,
                          ['المواد', 'الكل', 'مادة 1', 'مادة 2'], (value) {
                        setState(() {
                          _selectedMaterial = value!;
                        });
                      }),
                    ),
                    const SizedBox(width: 16),
                    // Movement Type Dropdown
                    Expanded(
                      child: _buildDropdown('نوع الحركة', _selectedMovementType,
                          ['نوع الحركة', 'الكل', 'استلام', 'صرف', 'تحويل'],
                          (value) {
                        setState(() {
                          _selectedMovementType = value!;
                        });
                      }),
                    ),
                    const SizedBox(width: 16),
                    // Warehouse Dropdown
                    Expanded(
                      child: _buildDropdown('المخزن', _selectedWarehouse,
                          ['المخزن', 'الكل', 'مخزن 1', 'مخزن 2'], (value) {
                        setState(() {
                          _selectedWarehouse = value!;
                        });
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Second Row - Checkboxes and Button
                Row(
                  children: [
                    // Checkboxes
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Checkbox(
                            value: _showOpeningBalance,
                            onChanged: (value) {
                              setState(() {
                                _showOpeningBalance = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF0891B2),
                          ),
                          const Text('عرض رصيد الافتتاحية'),
                          const SizedBox(width: 16),
                          Checkbox(
                            value: _showClosingBalance,
                            onChanged: (value) {
                              setState(() {
                                _showClosingBalance = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF0891B2),
                          ),
                          const Text('عرض رصيد الختامية'),
                          const SizedBox(width: 16),
                          Checkbox(
                            value: _showDetails,
                            onChanged: (value) {
                              setState(() {
                                _showDetails = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF0891B2),
                          ),
                          const Text('عرض التفاصيل'),
                        ],
                      ),
                    ),
                    // Buttons
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0891B2),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text('بحث', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0891B2),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(
                                    color: Color(0xFF0891B2), width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.clear_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text('عرض بدمج المتشابهات',
                                      style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Summary Cards
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan[50]!,
                  Colors.cyan[100]!,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0891B2).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                _buildSummaryCard('اسم المادة', '0', const Color(0xFF0891B2)),
                Container(width: 2, height: 60, color: Colors.grey[300]),
                _buildSummaryCard(
                    'رصيد الافتتاحي', '0', const Color(0xFF10B981)),
                Container(width: 2, height: 60, color: Colors.grey[300]),
                _buildSummaryCard('الوقت', '0', const Color(0xFFF59E0B)),
                Container(width: 2, height: 60, color: Colors.grey[300]),
                _buildSummaryCard('موع الحركة', '0', const Color(0xFFEF4444)),
                Container(width: 2, height: 60, color: Colors.grey[300]),
                _buildSummaryCard('متوسط الحركة', '0', const Color(0xFF8B5CF6)),
                Container(width: 2, height: 60, color: Colors.grey[300]),
                _buildSummaryCard('الكمية', '0', const Color(0xFFEC4899)),
                Container(width: 2, height: 60, color: Colors.grey[300]),
                _buildSummaryCard('السعر', '0', const Color(0xFF06B6D4)),
                Container(width: 2, height: 60, color: Colors.grey[300]),
                _buildSummaryCard('الرصيد', '0', const Color(0xFF10B981)),
                Container(width: 2, height: 60, color: Colors.grey[300]),
                _buildSummaryCard('رقم الإشعار', '0', const Color(0xFF3B82F6)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Data Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E3A4C),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildTableHeader('رقم التقرير', flex: 2),
                        _buildTableHeader('رصيد الاول', flex: 2),
                        _buildTableHeader('رصيد الختامي', flex: 2),
                        _buildTableHeader('التاريخ', flex: 2),
                        _buildTableHeader('تفاصيل', flex: 1),
                        _buildTableHeader('اتعديل', flex: 1),
                        _buildTableHeader('الحذف', flex: 1),
                        _buildTableHeader('اضافة تعديلا', flex: 2),
                        _buildTableHeader('طباعة', flex: 1),
                      ],
                    ),
                  ),
                  // Empty State
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0891B2).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Color(0xFF0891B2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'لا توجد حركات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لا توجد حركات مواد مسجلة في الفترة المحددة',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            isExpanded: true,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
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

  Widget _buildTableHeader(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
