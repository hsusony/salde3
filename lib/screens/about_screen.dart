import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: const Text(
            'حول النظام',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 1,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667EEA),
                const Color(0xFF764BA2),
                const Color(0xFF8B5CF6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Advanced Gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFA709A),
                    const Color(0xFFFE5196),
                    const Color(0xFFFF6B6B),
                    const Color(0xFFFF8E53),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.6),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Animated Background Pattern
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _AnimatedPatternPainter(_controller.value),
                        );
                      },
                    ),
                  ),
                  // Floating Particles
                  ...List.generate(15, (index) => _buildFloatingParticle(index)),
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      // Logo Container with SVG and Animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                            CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
                          ),
                          child: Hero(
                            tag: 'company_logo',
                            child: AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _controller.value * 2 * math.pi / 10,
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.6),
                                          blurRadius: 50,
                                          spreadRadius: 10,
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFFFF6B35).withOpacity(0.5),
                                          blurRadius: 40,
                                          offset: const Offset(0, 15),
                                        ),
                                      ],
                                    ),
                                    child: Transform.rotate(
                                      angle: -_controller.value * 2 * math.pi / 10,
                                      child: SvgPicture.asset(
                                        'assets/images/9soft_logo.svg',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                      // Company Name with Gradient
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFFFF5F0)],
                        ).createShader(bounds),
                        child: const Text(
                          '9SOFT',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 10,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 5),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'INNOVATIVE SOFTWARE SOLUTIONS',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.98),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'حلول برمجية مبتكرة ومتطورة',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white.withOpacity(0.98),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 45),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Statistics Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '15+',
                      'سنة خبرة',
                      Icons.workspace_premium_rounded,
                      const Color(0xFFF093FB),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '500+',
                      'عميل راضي',
                      Icons.people_rounded,
                      const Color(0xFF4FACFE),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '1000+',
                      'مشروع منجز',
                      Icons.task_alt_rounded,
                      const Color(0xFF43E97B),
                      isDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Info Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Address Card
                  _buildInfoCard(
                    icon: Icons.location_on_rounded,
                    iconColor: const Color(0xFFE74C3C),
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
                    iconColor: const Color(0xFF00D4AA),
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
                    iconColor: const Color(0xFF5B8DEE),
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
                    iconColor: const Color(0xFFFFA800),
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

            // About Company Section with Advanced Design
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                children: [
                  // Background blur effect
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFFFFA17F).withOpacity(0.3),
                                const Color(0xFFFF7E79).withOpacity(0.25),
                                const Color(0xFFFF6B9D).withOpacity(0.2),
                              ]
                            : [
                                const Color(0xFFFFA17F).withOpacity(0.15),
                                const Color(0xFFFF7E79).withOpacity(0.12),
                                const Color(0xFFFF6B9D).withOpacity(0.08),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFFFF6B35).withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                          spreadRadius: 3,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Animated Icon Container
                        AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (math.sin(_controller.value * 2 * math.pi) * 0.05),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFA709A),
                                    Color(0xFFFE5196),
                                    Color(0xFFFF6B6B),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF6B35).withOpacity(0.6),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(-2, -2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.business_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'حول ناين سوفت',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFFFF6B35),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.25)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : const Color(0xFFFF6B35).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'ناين سوفت هي شركة عراقية رائدة تأسست عام 2010، متخصصة في توفير مجموعة متكاملة من البرامج المحاسبية الاحترافية بالإضافة إلى تصميم برامج مخصصة حسب الطلب وتصميم المواقع والمتاجر الإلكترونية والعديد من الخدمات التقنية المتقدمة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        height: 2,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white.withOpacity(0.95) : Colors.black87,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildBadge(
                        icon: Icons.calendar_today_rounded,
                        label: 'منذ عام 2010',
                        color: const Color(0xFFFF6B9D),
                      ),
                      _buildBadge(
                        icon: Icons.verified_rounded,
                        label: 'شركة عراقية',
                        color: const Color(0xFF38EF7D),
                      ),
                      _buildBadge(
                        icon: Icons.workspace_premium_rounded,
                        label: 'خبرة 15+ سنة',
                        color: const Color(0xFF667EEA),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

            const SizedBox(height: 32),

            // Vision & Mission Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildVisionMissionCard(
                      'رؤيتنا',
                      'أن نكون الشركة الرائدة في تقديم الحلول البرمجية المبتكرة في العراق والمنطقة',
                      Icons.visibility_rounded,
                      const Color(0xFF667EEA),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildVisionMissionCard(
                      'رسالتنا',
                      'تمكين الشركات من النجاح من خلال توفير حلول تقنية عالية الجودة ودعم متميز',
                      Icons.flag_rounded,
                      const Color(0xFFFE5196),
                      isDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Features Section with Premium Design
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF667EEA).withOpacity(0.25),
                          const Color(0xFF764BA2).withOpacity(0.25),
                          const Color(0xFFF093FB).withOpacity(0.2),
                        ]
                      : [
                          const Color(0xFF667EEA).withOpacity(0.12),
                          const Color(0xFF764BA2).withOpacity(0.12),
                          const Color(0xFFF093FB).withOpacity(0.08),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFF667EEA).withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF667EEA),
                          Color(0xFF764BA2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'خدماتنا المميزة',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(
                    Icons.account_balance_rounded,
                    'البرامج المحاسبية',
                    isDark,
                  ),
                  _buildFeatureItem(
                    Icons.laptop_rounded,
                    'تصميم برامج حسب الطلب',
                    isDark,
                  ),
                  _buildFeatureItem(
                    Icons.web_rounded,
                    'تصميم المواقع الإلكترونية',
                    isDark,
                  ),
                  _buildFeatureItem(
                    Icons.shopping_cart_rounded,
                    'تصميم المتاجر الإلكترونية',
                    isDark,
                  ),
                  _buildFeatureItem(
                    Icons.support_agent_rounded,
                    'الدعم الفني والصيانة',
                    isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Testimonials Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFFF093FB).withOpacity(0.2),
                          const Color(0xFFF5576C).withOpacity(0.2),
                        ]
                      : [
                          const Color(0xFFF093FB).withOpacity(0.1),
                          const Color(0xFFF5576C).withOpacity(0.08),
                        ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFF093FB).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        color: const Color(0xFFF093FB),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'آراء العملاء',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFFF093FB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTestimonial(
                    'خدمة ممتازة واحترافية عالية في التعامل. البرنامج المحاسبي سهل الاستخدام ويلبي جميع احتياجاتنا.',
                    'محمد علي',
                    'مدير شركة التجارة الحديثة',
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildTestimonial(
                    'فريق محترف ومتعاون. تم إنجاز موقعنا الإلكتروني في وقت قياسي وبجودة عالية.',
                    'سارة أحمد',
                    'مديرة التسويق - شركة النجاح',
                    isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Copyright Section with Modern Design
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF1E1E2E),
                          const Color(0xFF2A2A3E),
                        ]
                      : [
                          Colors.grey[50]!,
                          Colors.grey[100]!,
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
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
                    'شركة 9SOFT للحلول البرمجية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
            if (isDark)
              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(-5, -5),
              ),
          ],
          border: Border.all(
            color: isDark 
                ? iconColor.withOpacity(0.3)
                : iconColor.withOpacity(0.15),
            width: 2,
          ),
          gradient: isDark
              ? LinearGradient(
                  colors: [
                    const Color(0xFF2A2A3E),
                    const Color(0xFF1E1E2E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconColor,
                    iconColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF6366F1).withOpacity(0.15)
            : const Color(0xFF6366F1).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: const Color(0xFF10B981),
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = math.Random(index);
    final left = random.nextDouble();
    final top = random.nextDouble() * 0.8;
    final size = random.nextDouble() * 30 + 10;
    final duration = random.nextInt(5) + 3;
    
    return Positioned(
      left: left * 400,
      top: top * 300,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = (_controller.value * duration) % 1.0;
          return Transform.translate(
            offset: Offset(0, math.sin(value * 2 * math.pi) * 20),
            child: Opacity(
              opacity: 0.1 + (math.sin(value * 2 * math.pi) * 0.1),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(isDark ? 0.25 : 0.15),
            color.withOpacity(isDark ? 0.15 : 0.08),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisionMissionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonial(
    String quote,
    String name,
    String position,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF093FB).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      position,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              ...List.generate(
                5,
                (index) => const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFD93D),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quote,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Animated Background Pattern
class _AnimatedPatternPainter extends CustomPainter {
  final double animation;
  
  _AnimatedPatternPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < 8; i++) {
      for (var j = 0; j < 6; j++) {
        final x = i * size.width / 8;
        final y = j * size.height / 6;
        final offset = math.sin((animation * 2 * math.pi) + (i + j) * 0.5) * 10;
        
        canvas.drawCircle(
          Offset(x, y + offset),
          15 + math.sin((animation * 2 * math.pi) + i) * 5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_AnimatedPatternPainter oldDelegate) => true;
}
