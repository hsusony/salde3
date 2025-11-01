import 'package:flutter/material.dart';
import 'control/deleted_accounts_report_screen.dart';
import 'control/deleted_lists_report_screen.dart';
import 'control/deleted_materials_report_screen.dart';
import 'control/materials_movement_report_screen.dart';
import 'control/operations_statement_report_screen.dart';
import 'control/bonds_report_screen.dart';
import 'control/modification_report_screen.dart';
import 'control/losing_materials_report_screen.dart';
import 'control/inventory_report_screen.dart';
import 'control/general_balance_report_screen.dart';
import 'control/income_statement_report_screen.dart';
import 'control/material_modifications_report_screen.dart';

class ControlReportsScreen extends StatelessWidget {
  const ControlReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                  ]
                : [
                    Colors.grey[50]!,
                    Colors.white,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6),
                    const Color(0xFF3B82F6).withOpacity(0.8),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
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
                      Icons.shield_rounded,
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
                          'التقارير الرقابية',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'عرض وإدارة التقارير الرقابية',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.print_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Content - Grid of Report Cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.0,
                  children: [
                    _buildReportCard(
                      title: 'المواد المحذوفة',
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DeletedMaterialsReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'القوائم المحذوفة',
                      icon: Icons.list_alt_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DeletedListsReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'الحسابات المحذوفة',
                      icon: Icons.account_circle_outlined,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DeletedAccountsReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'حركة مواد',
                      icon: Icons.sync_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MaterialsMovementReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'المواد الخاسرة',
                      icon: Icons.trending_down_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LosingMaterialsReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'تقرير التعديل على',
                      icon: Icons.edit_note_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ModificationReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'تقرير السندات',
                      icon: Icons.description_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BondsReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'كشف العمليات',
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const OperationsStatementReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'تعديلات المواد',
                      icon: Icons.edit_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MaterialModificationsReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'تقرير كشف الدخل',
                      icon: Icons.payments_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const IncomeStatementReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'المنزانة العمومية',
                      icon: Icons.account_balance_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const GeneralBalanceReportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildReportCard(
                      title: 'تقرير الجرد',
                      icon: Icons.inventory_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InventoryReportScreen(),
                          ),
                        );
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

  Widget _buildReportCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E4D45),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
