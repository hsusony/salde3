import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../providers/installments_provider.dart';
import '../../models/installment.dart';

class InstallmentsReportsScreen extends StatefulWidget {
  const InstallmentsReportsScreen({super.key});

  @override
  State<InstallmentsReportsScreen> createState() =>
      _InstallmentsReportsScreenState();
}

class _InstallmentsReportsScreenState extends State<InstallmentsReportsScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  String _reportType = 'الكل'; // الكل، النشطة، المكتملة، المتأخرة

  @override
  void initState() {
    super.initState();
    // Load installments when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InstallmentsProvider>(context, listen: false)
          .loadInstallments();
    });
  }

  Future<void> _exportToExcel(List<Installment> installments) async {
    try {
      // Check if there's data to export
      if (installments.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'لا توجد بيانات للتصدير. الرجاء التأكد من وجود أقساط في الفترة المحددة.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Show loading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('جاري تصدير ${installments.length} قسط...'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Create Excel file
      var excel = excel_lib.Excel.createExcel();

      // Delete default sheet and create new one
      excel.delete('Sheet1');
      var sheet = excel['تقرير الأقساط']; // Add headers
      var headers = [
        'ت',
        'اسم الزبون',
        'المبلغ الإجمالي',
        'المبلغ المدفوع',
        'المبلغ المتبقي',
        'عدد الأقساط المدفوعة',
        'إجمالي الأقساط',
        'قيمة القسط',
        'تاريخ البدء',
        'الحالة',
        'ملاحظات'
      ];

      // Add headers to first row
      for (int i = 0; i < headers.length; i++) {
        var cell = sheet.cell(
            excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = excel_lib.TextCellValue(headers[i]);
        cell.cellStyle = excel_lib.CellStyle(
          backgroundColorHex: excel_lib.ExcelColor.blue,
          fontColorHex: excel_lib.ExcelColor.white,
          bold: true,
        );
      }

      // Add data
      final numberFormat = NumberFormat('#,##0', 'ar_IQ');
      final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

      for (int i = 0; i < installments.length; i++) {
        var installment = installments[i];
        int row = i + 1;

        sheet
            .cell(excel_lib.CellIndex.indexByColumnRow(
                columnIndex: 0, rowIndex: row))
            .value = excel_lib.IntCellValue(i + 1);
        sheet
            .cell(excel_lib.CellIndex.indexByColumnRow(
                columnIndex: 1, rowIndex: row))
            .value = excel_lib.TextCellValue(installment.customerName);
        sheet
                .cell(excel_lib.CellIndex.indexByColumnRow(
                    columnIndex: 2, rowIndex: row))
                .value =
            excel_lib.TextCellValue(
                numberFormat.format(installment.totalAmount));
        sheet
                .cell(excel_lib.CellIndex.indexByColumnRow(
                    columnIndex: 3, rowIndex: row))
                .value =
            excel_lib.TextCellValue(
                numberFormat.format(installment.paidAmount));
        sheet
                .cell(excel_lib.CellIndex.indexByColumnRow(
                    columnIndex: 4, rowIndex: row))
                .value =
            excel_lib.TextCellValue(
                numberFormat.format(installment.remainingAmount));
        sheet
            .cell(excel_lib.CellIndex.indexByColumnRow(
                columnIndex: 5, rowIndex: row))
            .value = excel_lib.IntCellValue(installment.paidInstallments);
        sheet
            .cell(excel_lib.CellIndex.indexByColumnRow(
                columnIndex: 6, rowIndex: row))
            .value = excel_lib.IntCellValue(installment.numberOfInstallments);
        sheet
                .cell(excel_lib.CellIndex.indexByColumnRow(
                    columnIndex: 7, rowIndex: row))
                .value =
            excel_lib.TextCellValue(
                numberFormat.format(installment.installmentAmount));
        sheet
                .cell(excel_lib.CellIndex.indexByColumnRow(
                    columnIndex: 8, rowIndex: row))
                .value =
            excel_lib.TextCellValue(
                dateFormat.format(DateTime.parse(installment.startDate)));

        String statusText = installment.status == 'active'
            ? 'نشط'
            : installment.status == 'completed'
                ? 'مكتمل'
                : installment.status == 'overdue'
                    ? 'متأخر'
                    : 'غير معروف';
        sheet
            .cell(excel_lib.CellIndex.indexByColumnRow(
                columnIndex: 9, rowIndex: row))
            .value = excel_lib.TextCellValue(statusText);
        sheet
            .cell(excel_lib.CellIndex.indexByColumnRow(
                columnIndex: 10, rowIndex: row))
            .value = excel_lib.TextCellValue(installment.notes);
      }

      // Add summary row
      int summaryRow = installments.length + 2;
      sheet
          .cell(excel_lib.CellIndex.indexByColumnRow(
              columnIndex: 0, rowIndex: summaryRow))
          .value = excel_lib.TextCellValue('الإجمالي:');

      double totalAmount =
          installments.fold(0, (sum, inst) => sum + inst.totalAmount);
      double paidAmount =
          installments.fold(0, (sum, inst) => sum + inst.paidAmount);
      double remainingAmount =
          installments.fold(0, (sum, inst) => sum + inst.remainingAmount);

      sheet
          .cell(excel_lib.CellIndex.indexByColumnRow(
              columnIndex: 2, rowIndex: summaryRow))
          .value = excel_lib.TextCellValue(numberFormat.format(totalAmount));
      sheet
          .cell(excel_lib.CellIndex.indexByColumnRow(
              columnIndex: 3, rowIndex: summaryRow))
          .value = excel_lib.TextCellValue(numberFormat.format(paidAmount));
      sheet
              .cell(excel_lib.CellIndex.indexByColumnRow(
                  columnIndex: 4, rowIndex: summaryRow))
              .value =
          excel_lib.TextCellValue(numberFormat.format(remainingAmount));

      // Set column widths
      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 20);
      }

      // Pick save location
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ ملف Excel',
        fileName:
            'تقرير_الأقساط_${DateFormat('yyyy_MM_dd_HH_mm').format(DateTime.now())}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputPath != null) {
        // Ensure the file has .xlsx extension
        if (!outputPath.endsWith('.xlsx')) {
          outputPath = '$outputPath.xlsx';
        }

        // Save the file
        var fileBytes = excel.encode();
        if (fileBytes != null) {
          File(outputPath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم حفظ الملف بنجاح في: $outputPath'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء التصدير: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
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

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
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
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final numberFormat = NumberFormat.currency(
      symbol: 'د.ع',
      decimalDigits: 0,
      locale: 'ar_IQ',
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.assessment_outlined,
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
                            'كشف قوائم الأقساط',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'تقارير تفصيلية عن جميع الأقساط',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.print,
                          color: Colors.white, size: 26),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('جاري طباعة التقرير...')),
                        );
                      },
                      tooltip: 'طباعة',
                    ),
                    const SizedBox(width: 8),
                    Consumer<InstallmentsProvider>(
                      builder: (context, provider, child) {
                        return IconButton(
                          icon: const Icon(Icons.file_download,
                              color: Colors.white, size: 26),
                          onPressed: () {
                            var filteredInstallments =
                                provider.installments.where((inst) {
                              final startDate = DateTime.parse(inst.startDate);
                              if (startDate.isBefore(_fromDate) ||
                                  startDate.isAfter(
                                      _toDate.add(const Duration(days: 1)))) {
                                return false;
                              }
                              if (_reportType == 'النشطة' &&
                                  inst.status != 'active') return false;
                              if (_reportType == 'المكتملة' &&
                                  inst.status != 'completed') return false;
                              if (_reportType == 'المتأخرة' &&
                                  inst.status != 'overdue') return false;
                              return true;
                            }).toList();
                            _exportToExcel(filteredInstallments);
                          },
                          tooltip: 'تصدير إلى Excel',
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf,
                          color: Colors.white, size: 26),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('جاري تصدير PDF...')),
                        );
                      },
                      tooltip: 'تصدير PDF',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Filters Row
                Row(
                  children: [
                    // From Date
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'من',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dateFormat.format(_fromDate),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
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
                    const SizedBox(width: 12),
                    // To Date
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الى',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dateFormat.format(_toDate),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
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
                    const SizedBox(width: 12),
                    // Report Type Filter
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _reportType,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1E40AF),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.white),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                            items: ['الكل', 'النشطة', 'المكتملة', 'المتأخرة']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _reportType = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Search button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon:
                            const Icon(Icons.search, color: Color(0xFF3B82F6)),
                        onPressed: () {
                          setState(() {});
                        },
                        tooltip: 'بحث',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Statistics Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Consumer<InstallmentsProvider>(
              builder: (context, provider, child) {
                // Filter installments based on date and type
                var filteredInstallments = provider.installments.where((inst) {
                  final startDate = DateTime.parse(inst.startDate);
                  if (startDate.isBefore(_fromDate) ||
                      startDate.isAfter(_toDate.add(const Duration(days: 1)))) {
                    return false;
                  }
                  if (_reportType == 'النشطة' && inst.status != 'active')
                    return false;
                  if (_reportType == 'المكتملة' && inst.status != 'completed')
                    return false;
                  if (_reportType == 'المتأخرة' && inst.status != 'overdue')
                    return false;
                  return true;
                }).toList();

                double totalAmount = filteredInstallments.fold(
                    0, (sum, inst) => sum + inst.totalAmount);
                double paidAmount = filteredInstallments.fold(
                    0, (sum, inst) => sum + inst.paidAmount);
                double remainingAmount = filteredInstallments.fold(
                    0, (sum, inst) => sum + inst.remainingAmount);
                int totalCount = filteredInstallments.length;

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'الإجمالي',
                        numberFormat.format(totalAmount),
                        const Color(0xFF3B82F6),
                        Icons.account_balance_wallet,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'المدفوع',
                        numberFormat.format(paidAmount),
                        const Color(0xFF10B981),
                        Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'المتبقي',
                        numberFormat.format(remainingAmount),
                        const Color(0xFFEF4444),
                        Icons.pending,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'المجموع',
                        '$totalCount قسط',
                        const Color(0xFF8B5CF6),
                        Icons.format_list_numbered,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Table Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.1),
                  const Color(0xFF1E40AF).withOpacity(0.05)
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border:
                  Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    'ت',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الحساب',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الباقي',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'المدفوع',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الاجمالي',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'الحالة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'تفاصيل',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Table Body
          Expanded(
            child: Consumer<InstallmentsProvider>(
              builder: (context, provider, child) {
                var filteredInstallments = provider.installments.where((inst) {
                  final startDate = DateTime.parse(inst.startDate);
                  if (startDate.isBefore(_fromDate) ||
                      startDate.isAfter(_toDate.add(const Duration(days: 1)))) {
                    return false;
                  }
                  if (_reportType == 'النشطة' && inst.status != 'active')
                    return false;
                  if (_reportType == 'المكتملة' && inst.status != 'completed')
                    return false;
                  if (_reportType == 'المتأخرة' && inst.status != 'overdue')
                    return false;
                  return true;
                }).toList();

                if (filteredInstallments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد أقساط في هذه الفترة',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filteredInstallments.length,
                  itemBuilder: (context, index) {
                    final installment = filteredInstallments[index];

                    Color statusColor;
                    String statusText;
                    switch (installment.status) {
                      case 'active':
                        statusColor = const Color(0xFF10B981);
                        statusText = 'نشط';
                        break;
                      case 'completed':
                        statusColor = const Color(0xFF3B82F6);
                        statusText = 'مكتمل';
                        break;
                      case 'overdue':
                        statusColor = const Color(0xFFEF4444);
                        statusText = 'متأخر';
                        break;
                      default:
                        statusColor = Colors.grey;
                        statusText = 'غير معروف';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 1),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.grey.shade200, width: 1),
                          right: BorderSide(color: statusColor, width: 4),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        statusColor.withOpacity(0.8),
                                        statusColor
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        installment.customerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'رقم القسط: #${installment.id}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              numberFormat.format(installment.remainingAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF4444),
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              numberFormat.format(installment.paidAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              numberFormat.format(installment.totalAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B82F6),
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.visibility,
                                    color: Color(0xFF3B82F6),
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    _showInstallmentDetails(
                                        context, installment);
                                  },
                                  tooltip: 'عرض',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.print,
                                    color: Color(0xFF10B981),
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'طباعة قسط ${installment.customerName}'),
                                      ),
                                    );
                                  },
                                  tooltip: 'طباعة',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showInstallmentDetails(BuildContext context, Installment installment) {
    final numberFormat = NumberFormat.currency(
      symbol: 'د.ع',
      decimalDigits: 0,
      locale: 'ar_IQ',
    );
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
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
                        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'تفاصيل القسط',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 30),
              _buildDetailRow('رقم القسط', '#${installment.id}', Icons.tag),
              _buildDetailRow(
                  'اسم الزبون', installment.customerName, Icons.person),
              _buildDetailRow(
                  'المبلغ الإجمالي',
                  numberFormat.format(installment.totalAmount),
                  Icons.account_balance),
              _buildDetailRow('المبلغ المدفوع',
                  numberFormat.format(installment.paidAmount), Icons.payment),
              _buildDetailRow(
                  'المبلغ المتبقي',
                  numberFormat.format(installment.remainingAmount),
                  Icons.money_off),
              _buildDetailRow(
                  'عدد الأقساط',
                  '${installment.paidInstallments}/${installment.numberOfInstallments}',
                  Icons.format_list_numbered),
              _buildDetailRow(
                  'قيمة القسط',
                  numberFormat.format(installment.installmentAmount),
                  Icons.attach_money),
              _buildDetailRow(
                  'تاريخ البدء',
                  dateFormat.format(DateTime.parse(installment.startDate)),
                  Icons.calendar_today),
              if (installment.notes.isNotEmpty)
                _buildDetailRow('ملاحظات', installment.notes, Icons.note),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('إغلاق'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.grey.shade700),
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
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
