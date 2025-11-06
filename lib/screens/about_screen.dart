import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(uri)) {
      throw Exception('Could not call $phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'حول',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF8A00),
                            Color(0xFFFFB800),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF8A00).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background Circle
                          Center(
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF8A00),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // Number 9
                          Positioned(
                            right: 15,
                            top: 20,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF8A00),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Text NINE
                          const Positioned(
                            left: 10,
                            top: 45,
                            child: Text(
                              'NINE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Number 9 text
                          const Positioned(
                            right: 25,
                            top: 30,
                            child: Text(
                              '9',
                              style: TextStyle(
                                color: Color(0xFFFF8A00),
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                          ),
                          // Text SOFT
                          const Positioned(
                            left: 10,
                            bottom: 35,
                            child: Text(
                              'SOFT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Company Name
                  const Text(
                    'Nine Soft',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'حلول برمجية متكاملة',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Info Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Address Card
                  _buildInfoCard(
                    icon: Icons.location_on_rounded,
                    iconColor: const Color(0xFFEF4444),
                    title: 'العنوان',
                    subtitle: 'بغداد - شارع الصناعة',
                    description: 'مقابل الجامعة التكنولوجية',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Phone Card
                  _buildInfoCard(
                    icon: Icons.phone_rounded,
                    iconColor: const Color(0xFF10B981),
                    title: 'الهاتف',
                    subtitle: '07755667500',
                    description: 'متاح من 9 صباحاً - 5 مساءً',
                    onTap: () => _makePhoneCall('07755667500'),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Website Card
                  _buildInfoCard(
                    icon: Icons.language_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    title: 'الموقع الإلكتروني',
                    subtitle: 'nine-soft.com',
                    description: 'تفضل بزيارة موقعنا',
                    onTap: () => _launchURL('https://nine-soft.com'),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Email Card
                  _buildInfoCard(
                    icon: Icons.email_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'البريد الإلكتروني',
                    subtitle: 'info@nine-soft.com',
                    description: 'راسلنا في أي وقت',
                    onTap: () => _launchURL('mailto:info@nine-soft.com'),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Features Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF6366F1).withOpacity(0.2),
                          const Color(0xFF8B5CF6).withOpacity(0.2),
                        ]
                      : [
                          const Color(0xFF6366F1).withOpacity(0.1),
                          const Color(0xFF8B5CF6).withOpacity(0.1),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'خدماتنا',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(
                    Icons.computer_rounded,
                    'تطوير البرمجيات',
                    isDark,
                  ),
                  _buildFeatureItem(
                    Icons.phone_android_rounded,
                    'تطبيقات الموبايل',
                    isDark,
                  ),
                  _buildFeatureItem(
                    Icons.web_rounded,
                    'تصميم المواقع',
                    isDark,
                  ),
                  _buildFeatureItem(
                    Icons.support_agent_rounded,
                    'الدعم الفني',
                    isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Copyright Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A3E) : Colors.grey[100],
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.copyright_rounded,
                    size: 32,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'جميع الحقوق محفوظة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'شركة Nine Soft',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© ${DateTime.now().year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6366F1),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
