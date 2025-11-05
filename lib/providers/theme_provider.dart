import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Color _selectedPrimaryColor = const Color(0xFF6366F1); // Default Indigo
  String _fontFamily = 'Tajawal';
  double _fontSize = 14.0;

  ThemeMode get themeMode => _themeMode;
  Color get selectedPrimaryColor => _selectedPrimaryColor;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _selectedPrimaryColor = color;
    notifyListeners();
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  // Professional Color Palette - Modern & Elegant
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondaryColor = Color(0xFF06B6D4); // Cyan
  static const Color secondaryLight = Color(0xFF22D3EE);
  static const Color accentColor = Color(0xFFF59E0B); // Amber
  static const Color successColor = Color(0xFF10B981); // Emerald
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color infoColor = Color(0xFF3B82F6); // Blue

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6)
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFF06B6D4),
    Color(0xFF3B82F6)
  ];
  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF059669)
  ];
  static const List<Color> warningGradient = [
    Color(0xFFF59E0B),
    Color(0xFFD97706)
  ];
  static const List<Color> errorGradient = [
    Color(0xFFEF4444),
    Color(0xFFDC2626)
  ];

  // Light Theme - Enhanced
  ThemeData get lightTheme {
    // استخدام اللون المختار أو اللون الافتراضي
    final currentPrimary = _selectedPrimaryColor;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: currentPrimary,
      colorScheme: ColorScheme.light(
        primary: currentPrimary,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: Colors.white,
        surfaceContainerHighest: const Color(0xFFF1F5F9),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF0F172A),
        onSurfaceVariant: const Color(0xFF475569),
        outline: const Color(0xFFCBD5E1),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.08),
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.05),
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0F172A),
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF475569), size: 24),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.tajawal(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            height: 1.2),
        displayMedium: GoogleFonts.tajawal(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            height: 1.2),
        displaySmall: GoogleFonts.tajawal(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            height: 1.3),
        headlineMedium: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
            height: 1.3),
        titleLarge: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
            height: 1.4),
        titleMedium: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
            height: 1.4),
        bodyLarge: GoogleFonts.tajawal(
            fontSize: 16, color: const Color(0xFF475569), height: 1.5),
        bodyMedium: GoogleFonts.tajawal(
            fontSize: 14, color: const Color(0xFF64748B), height: 1.5),
        labelLarge: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
            letterSpacing: 0.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: currentPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: currentPrimary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.tajawal(
              fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.white.withOpacity(0.1);
              }
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withOpacity(0.2);
              }
              return null;
            },
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: currentPrimary,
          side: BorderSide(color: currentPrimary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.tajawal(
              fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: currentPrimary,
          textStyle:
              GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: currentPrimary, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 2.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: GoogleFonts.tajawal(
            fontSize: 14,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500),
        hintStyle:
            GoogleFonts.tajawal(fontSize: 14, color: const Color(0xFF94A3B8)),
        floatingLabelStyle: GoogleFonts.tajawal(
            fontSize: 14, color: currentPrimary, fontWeight: FontWeight.w600),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF475569), size: 24),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F5F9),
        labelStyle: GoogleFonts.tajawal(
            fontSize: 13,
            color: const Color(0xFF334155),
            fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1E293B),
        contentTextStyle:
            GoogleFonts.tajawal(fontSize: 14, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.white,
        selectedTileColor: const Color(0xFFF1F5F9),
        textColor: const Color(0xFF1E293B),
        iconColor: const Color(0xFF475569),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A)),
        dataTextStyle:
            GoogleFonts.tajawal(fontSize: 14, color: const Color(0xFF334155)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected)
              ? primaryColor
              : const Color(0xFF94A3B8),
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected)
              ? primaryColor.withOpacity(0.5)
              : const Color(0xFFE2E8F0),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected)
              ? primaryColor
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected)
              ? primaryColor
              : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  // Dark Theme - Enhanced & Modern
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryLight,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF818CF8), // Lighter indigo for better visibility
        secondary: Color(0xFF22D3EE), // Brighter cyan
        tertiary: Color(0xFFFBBF24), // Brighter amber
        error: Color(0xFFF87171), // Lighter red
        surface: Color(0xFF1E293B), // Slate-800
        surfaceContainerHighest: Color(0xFF334155), // Slate-700
        onPrimary: Color(0xFF0F172A),
        onSecondary: Color(0xFF0F172A),
        onSurface: Color(0xFFF1F5F9),
        onSurfaceVariant: Color(0xFFCBD5E1),
        outline: Color(0xFF475569),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate-900
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(0xFF1E293B), // Slate-800
        shadowColor: Colors.black.withOpacity(0.5),
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFF1E293B), // Slate-800
        foregroundColor: const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.3),
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF8FAFC),
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: Color(0xFFCBD5E1), size: 24),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.tajawal(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFF8FAFC),
            height: 1.2),
        displayMedium: GoogleFonts.tajawal(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFF8FAFC),
            height: 1.2),
        displaySmall: GoogleFonts.tajawal(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFF1F5F9),
            height: 1.3),
        headlineMedium: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE2E8F0),
            height: 1.3),
        titleLarge: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFE2E8F0),
            height: 1.4),
        titleMedium: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCBD5E1),
            height: 1.4),
        bodyLarge: GoogleFonts.tajawal(
            fontSize: 16, color: const Color(0xFFCBD5E1), height: 1.5),
        bodyMedium: GoogleFonts.tajawal(
            fontSize: 14, color: const Color(0xFFA8B4C5), height: 1.5),
        labelLarge: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF1F5F9),
            letterSpacing: 0.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF818CF8), // Lighter primary
          foregroundColor: const Color(0xFF0F172A),
          elevation: 2,
          shadowColor: const Color(0xFF818CF8).withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.tajawal(
              fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return const Color(0xFFA5B4FC).withOpacity(0.1);
              }
              if (states.contains(WidgetState.pressed)) {
                return const Color(0xFFA5B4FC).withOpacity(0.2);
              }
              return null;
            },
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF818CF8),
          side: const BorderSide(color: Color(0xFF818CF8), width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.tajawal(
              fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF818CF8),
          textStyle:
              GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B), // Slate-800
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF818CF8), width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 2.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: GoogleFonts.tajawal(
            fontSize: 14,
            color: const Color(0xFFA8B4C5),
            fontWeight: FontWeight.w500),
        hintStyle:
            GoogleFonts.tajawal(fontSize: 14, color: const Color(0xFF64748B)),
        floatingLabelStyle: GoogleFonts.tajawal(
            fontSize: 14,
            color: const Color(0xFF818CF8),
            fontWeight: FontWeight.w600),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFCBD5E1), size: 24),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF334155),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF334155),
        labelStyle: GoogleFonts.tajawal(
            fontSize: 13,
            color: const Color(0xFFE2E8F0),
            fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E293B),
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFF8FAFC)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1E293B),
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF334155),
        contentTextStyle:
            GoogleFonts.tajawal(fontSize: 14, color: const Color(0xFFF8FAFC)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: const Color(0xFF1E293B),
        selectedTileColor: const Color(0xFF334155),
        textColor: const Color(0xFFE2E8F0),
        iconColor: const Color(0xFFCBD5E1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFF1F5F9)),
        dataTextStyle:
            GoogleFonts.tajawal(fontSize: 14, color: const Color(0xFFCBD5E1)),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected)
              ? const Color(0xFF818CF8)
              : const Color(0xFF64748B),
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected)
              ? const Color(0xFF818CF8).withOpacity(0.5)
              : const Color(0xFF334155),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected)
              ? const Color(0xFF818CF8)
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected)
              ? const Color(0xFF818CF8)
              : const Color(0xFF64748B),
        ),
      ),
    );
  }
}
