import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cash_provider.dart';
import 'cash/receipt_voucher_page.dart';
import 'cash/multiple_receipt_voucher_page.dart';
import 'cash/dual_currency_receipt_voucher_page.dart';
import 'cash/transfer_document_page.dart';
import 'cash/payment_voucher_page.dart';
import 'cash/multiple_payment_voucher_page.dart';
import 'cash/dual_currency_payment_voucher_page.dart';
import 'cash/disbursement_voucher_page.dart';
import 'cash/exchange_voucher_page.dart';
import 'cash/remittance_voucher_page.dart';
import 'cash/cash_transfer_page.dart';
import 'cash/safe_to_cashbox_transfer_page.dart';
import 'cash/cashbox_to_cashbox_transfer_page.dart';
import 'cash/profit_distribution_page.dart';
import 'cash/journal_entry_page.dart';
import 'cash/multiple_journal_entry_page.dart';
import 'cash/compound_entry_page.dart';

class CashScreen extends StatefulWidget {
  const CashScreen({super.key});

  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  int _selectedIndex = 0;

  final List<CashMenuItem> _menuItems = [
    CashMenuItem(
        icon: Icons.receipt_rounded,
        label: 'سند قبض',
        type: VoucherType.receipt),
    CashMenuItem(
        icon: Icons.receipt_long_rounded,
        label: 'سند قبض متعدد',
        type: VoucherType.multipleReceipt),
    CashMenuItem(
        icon: Icons.currency_exchange_rounded,
        label: 'سند قبض بعملتين',
        type: VoucherType.dualCurrencyReceipt),
    CashMenuItem(
        icon: Icons.transform_rounded,
        label: 'عرض مستند تحويل',
        type: VoucherType.transferDocument),
    CashMenuItem(
        icon: Icons.payment_rounded,
        label: 'سند دفع',
        type: VoucherType.payment),
    CashMenuItem(
        icon: Icons.payments_rounded,
        label: 'سند دفع متعدد',
        type: VoucherType.multiplePayment),
    CashMenuItem(
        icon: Icons.attach_money_rounded,
        label: 'سند دفع بعملتين',
        type: VoucherType.dualCurrencyPayment),
    CashMenuItem(
        icon: Icons.account_balance_wallet_rounded,
        label: 'سند صرف',
        type: VoucherType.disbursement),
    CashMenuItem(
        icon: Icons.money_rounded,
        label: 'صيـرفـة',
        type: VoucherType.exchange),
    CashMenuItem(
        icon: Icons.send_rounded,
        label: 'سند حوالة',
        type: VoucherType.remittance),
    CashMenuItem(
        icon: Icons.arrow_forward_rounded,
        label: 'تحويل من الصندوق الى',
        type: VoucherType.transferFromCashbox),
    CashMenuItem(
        icon: Icons.arrow_forward_rounded,
        label: 'تحويل من الخزينة الى',
        type: VoucherType.transferFromSafe),
    CashMenuItem(
        icon: Icons.swap_horiz_rounded,
        label: 'تحويل من صندوق الى',
        type: VoucherType.transferBetweenCashboxes),
    CashMenuItem(
        icon: Icons.trending_up_rounded,
        label: 'سند توزيع الأرباح',
        type: VoucherType.profitDistribution),
    CashMenuItem(
        icon: Icons.book_rounded,
        label: 'قيد محاسبي',
        type: VoucherType.journalEntry),
    CashMenuItem(
        icon: Icons.library_books_rounded,
        label: 'سند قيد محاسبي متعدد',
        type: VoucherType.multipleJournalEntry),
    CashMenuItem(
        icon: Icons.menu_book_rounded,
        label: 'قيد مركب',
        type: VoucherType.compoundEntry),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar Menu
          Container(
            width: 320,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [Colors.white, const Color(0xFFF8FAFC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey.shade400)
                      .withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.account_balance_rounded,
                            color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'إدارة النقد والحسابات',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Consumer<CashProvider>(
                        builder: (context, provider, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        const Color(0xFF334155),
                                        const Color(0xFF475569)
                                      ]
                                    : [
                                        const Color(0xFFD1FAE5),
                                        const Color(0xFFA7F3D0)
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'الرصيد الصافي: ${_formatCurrency(provider.netCashFlow)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: isDark
                                        ? const Color(0xFF86EFAC)
                                        : const Color(0xFF059669),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                    height: 1,
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0)),
                const SizedBox(height: 8),

                // Menu Items
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;
                      final item = _menuItems[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() => _selectedIndex = index),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0x2610B981),
                                          Color(0x26059669),
                                        ],
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF10B981).withOpacity(0.5)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFF10B981),
                                                Color(0xFF059669)
                                              ],
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : (isDark
                                              ? const Color(0xFF334155)
                                              : const Color(0xFFF1F5F9)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B)),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: isSelected
                                                ? (isDark
                                                    ? Colors.white
                                                    : const Color(0xFF10B981))
                                                : (isDark
                                                    ? const Color(0xFF94A3B8)
                                                    : const Color(0xFF64748B)),
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final voucherType = _menuItems[_selectedIndex].type;

    // إذا كان النوع سند قبض، عرض الصفحة الكاملة
    if (voucherType == VoucherType.receipt) {
      return const ReceiptVoucherPage();
    }

    // إذا كان النوع سند قبض متعدد، عرض الصفحة الكاملة
    if (voucherType == VoucherType.multipleReceipt) {
      return const MultipleReceiptVoucherPage();
    }

    // إذا كان النوع سند قبض بعملتين، عرض الصفحة الكاملة
    if (voucherType == VoucherType.dualCurrencyReceipt) {
      return const DualCurrencyReceiptVoucherPage();
    }

    // إذا كان النوع عرض مستند تحويل، عرض الصفحة الكاملة
    if (voucherType == VoucherType.transferDocument) {
      return const TransferDocumentPage();
    }

    // إذا كان النوع سند دفع، عرض الصفحة الكاملة
    if (voucherType == VoucherType.payment) {
      return const PaymentVoucherPage();
    }

    // إذا كان النوع سند دفع متعدد، عرض الصفحة الكاملة
    if (voucherType == VoucherType.multiplePayment) {
      return const MultiplePaymentVoucherPage();
    }

    // إذا كان النوع سند دفع بعملتين، عرض الصفحة الكاملة
    if (voucherType == VoucherType.dualCurrencyPayment) {
      return const DualCurrencyPaymentVoucherPage();
    }

    // إذا كان النوع سند صرف، عرض الصفحة الكاملة
    if (voucherType == VoucherType.disbursement) {
      return const DisbursementVoucherPage();
    }

    // إذا كان النوع صيرفة، عرض الصفحة الكاملة
    if (voucherType == VoucherType.exchange) {
      return const ExchangeVoucherPage();
    }

    // إذا كان النوع سند حوالة، عرض الصفحة الكاملة
    if (voucherType == VoucherType.remittance) {
      return const RemittanceVoucherPage();
    }

    // إذا كان النوع تحويل من صندوق الى خزينة
    if (voucherType == VoucherType.transferFromCashbox) {
      return const CashTransferPage();
    }

    // إذا كان النوع تحويل من خزينة الى صندوق
    if (voucherType == VoucherType.transferFromSafe) {
      return const SafeToCashboxTransferPage();
    }

    // إذا كان النوع تحويل من صندوق الى صندوق
    if (voucherType == VoucherType.transferBetweenCashboxes) {
      return const CashboxToCashboxTransferPage();
    }

    // إذا كان النوع توزيع الأرباح
    if (voucherType == VoucherType.profitDistribution) {
      return const ProfitDistributionPage();
    }

    // إذا كان النوع قيد محاسبي
    if (voucherType == VoucherType.journalEntry) {
      return const JournalEntryPage();
    }

    // إذا كان النوع قيد محاسبي متعدد
    if (voucherType == VoucherType.multipleJournalEntry) {
      return const MultipleJournalEntryPage();
    }

    // إذا كان النوع قيد مركب
    if (voucherType == VoucherType.compoundEntry) {
      return const CompoundEntryPage();
    }

    // باقي الأنواع عرض النموذج القديم
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                _menuItems[_selectedIndex].icon,
                color: const Color(0xFF10B981),
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                _menuItems[_selectedIndex].label,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              // عرض زر إضافة جديد فقط للأنواع التي ليست صفحة كاملة
              if (voucherType != VoucherType.receipt)
                ElevatedButton.icon(
                  onPressed: () => _showVoucherDialog(voucherType),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('إضافة جديد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Content
          Expanded(
            child: _buildVoucherList(voucherType),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherList(VoucherType type) {
    return Consumer<CashProvider>(
      builder: (context, provider, child) {
        List<dynamic> vouchers = [];

        switch (type) {
          case VoucherType.receipt:
            vouchers = provider.receiptVouchers;
            break;
          case VoucherType.multipleReceipt:
            vouchers = provider.multipleReceiptVouchers;
            break;
          case VoucherType.dualCurrencyReceipt:
            vouchers = provider.dualCurrencyReceipts;
            break;
          case VoucherType.payment:
            vouchers = provider.paymentVouchers;
            break;
          case VoucherType.multiplePayment:
            vouchers = provider.multiplePaymentVouchers;
            break;
          case VoucherType.dualCurrencyPayment:
            vouchers = provider.dualCurrencyPayments;
            break;
          case VoucherType.disbursement:
            vouchers = provider.disbursementVouchers;
            break;
          case VoucherType.exchange:
            vouchers = provider.exchangeVouchers;
            break;
          case VoucherType.remittance:
            vouchers = provider.remittanceVouchers;
            break;
          case VoucherType.transferFromCashbox:
          case VoucherType.transferFromSafe:
          case VoucherType.transferBetweenCashboxes:
          case VoucherType.transferDocument:
            vouchers = provider.transferVouchers;
            break;
          case VoucherType.profitDistribution:
            vouchers = provider.profitDistributions;
            break;
          case VoucherType.journalEntry:
            vouchers = provider.journalEntries;
            break;
          case VoucherType.multipleJournalEntry:
            vouchers = provider.multipleJournalEntries;
            break;
          case VoucherType.compoundEntry:
            vouchers = provider.compoundJournalEntries;
            break;
        }

        if (vouchers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد سندات بعد',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اضغط على "إضافة جديد" لإنشاء سند',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: vouchers.length,
          itemBuilder: (context, index) {
            return _buildVoucherCard(vouchers[index], type);
          },
        );
      },
    );
  }

  Widget _buildVoucherCard(dynamic voucher, VoucherType type) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _menuItems[_selectedIndex].icon,
                    color: const Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getVoucherNumber(voucher),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getVoucherDate(voucher),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _getVoucherAmount(voucher),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getVoucherDetails(voucher),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                IconButton(
                  onPressed: () => _showVoucherDialog(type, voucher: voucher),
                  icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                  tooltip: 'تعديل',
                ),
                IconButton(
                  onPressed: () => _deleteVoucher(type, voucher),
                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
                  tooltip: 'حذف',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getVoucherNumber(dynamic voucher) {
    if (voucher.voucherNumber != null) return voucher.voucherNumber;
    if (voucher.entryNumber != null) return voucher.entryNumber;
    if (voucher.returnNumber != null) return voucher.returnNumber;
    return 'غير محدد';
  }

  String _getVoucherDate(dynamic voucher) {
    final date = voucher.date ?? voucher.createdAt;
    return '${date.year}/${date.month}/${date.day}';
  }

  String _getVoucherAmount(dynamic voucher) {
    double amount = 0;
    if (voucher.amount != null) {
      amount = voucher.amount;
    } else if (voucher.totalAmount != null) {
      amount = voucher.totalAmount;
    } else if (voucher.amountIQD != null) {
      amount = voucher.amountIQD;
    }
    return _formatCurrency(amount);
  }

  String _getVoucherDetails(dynamic voucher) {
    if (voucher.customerName != null) return 'العميل: ${voucher.customerName}';
    if (voucher.supplierName != null) return 'المورد: ${voucher.supplierName}';
    if (voucher.beneficiaryName != null) {
      return 'المستفيد: ${voucher.beneficiaryName}';
    }
    if (voucher.description != null) return voucher.description;
    return 'لا توجد تفاصيل';
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} د.ع';
  }

  void _showVoucherDialog(VoucherType type, {dynamic voucher}) {
    // سند القبض لا يحتاج Dialog لأنه صفحة كاملة
    if (type == VoucherType.receipt) {
      return;
    }

    // TODO: Implement other voucher dialogs
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('نافذة ${_menuItems[_selectedIndex].label} قيد التطوير'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _deleteVoucher(VoucherType type, dynamic voucher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا السند؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Delete voucher based on type
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class CashMenuItem {
  final IconData icon;
  final String label;
  final VoucherType type;

  CashMenuItem({
    required this.icon,
    required this.label,
    required this.type,
  });
}

enum VoucherType {
  receipt,
  multipleReceipt,
  dualCurrencyReceipt,
  transferDocument,
  payment,
  multiplePayment,
  dualCurrencyPayment,
  disbursement,
  exchange,
  remittance,
  transferFromCashbox,
  transferFromSafe,
  transferBetweenCashboxes,
  profitDistribution,
  journalEntry,
  multipleJournalEntry,
  compoundEntry,
}
