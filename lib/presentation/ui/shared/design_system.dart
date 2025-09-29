import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary Colors - Burgundy Red to Navy Blue Gradient
  static const Color primary = Color(0xFFD61D39); // Burgundy Red - Primary brand color
  static const Color primaryLight = Color(0xFFE84C64); // Lighter burgundy
  static const Color primaryDark = Color(0xFFB01729); // Darker burgundy

  // Brand Secondary Colors - Navy Blue
  static const Color secondary = Color(0xFF323282); // Navy Blue - Secondary brand color
  static const Color secondaryLight = Color(0xFF4A4A9C); // Lighter navy
  static const Color secondaryDark = Color(0xFF252568); // Darker navy

  // Brand Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary], // Burgundy to Navy gradient
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, secondary], // Burgundy to Navy gradient
  );

  // Status Colors - Harmonized with brand colors
  static const Color success = Color(0xFF10B981); // Emerald green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red (lighter than primary)
  static const Color info = Color(0xFF3B82F6); // Blue

  // Online/Offline Colors - High contrast
  static const Color online = Color(0xFF2E7D32);
  static const Color offline = Color(0xFFC62828);

  // Neutral Colors - Better contrast
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Text Colors - Higher contrast
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSurface = Color(0xFF1A1A1A);

  // Border Colors - More defined
  static const Color border = Color(0xFFDDDDDD);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color borderDark = Color(0xFFBBBBBB);

  // Shadow Color - More pronounced
  static const Color shadow = Color(0x20000000);
  static const Color shadowLight = Color(0x10000000);
  static const Color shadowDark = Color(0x30000000);
}

// Brand Gradient Utilities
class AppGradients {
  // Main brand gradient (Burgundy to Navy)
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.secondary],
  );

  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primary, AppColors.secondary],
  );

  static const LinearGradient primaryHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primary, AppColors.secondary],
  );

  // Subtle gradients for cards and backgrounds
  static const LinearGradient primarySubtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFDF2F4), // Very light burgundy
      Color(0xFFF4F4F9), // Very light navy
    ],
  );

  // Reverse gradient
  static const LinearGradient primaryReverse = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.secondary, AppColors.primary],
  );
}


class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xl = 24.0;
  static const double pill = 100.0;
}

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.25,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.25,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
    height: 1.33,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 1.25,
  );

  // High contrast versions for better readability
  static const TextStyle bodyLargeContrast = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle bodyMediumContrast = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.25,
    height: 1.4,
  );
}

class AppElevations {
  static const double level0 = 0;
  static const double level1 = 3;
  static const double level2 = 6;
  static const double level3 = 10;
  static const double level4 = 16;
  static const double level5 = 24;
}

class AppShadows {
  static BoxShadow get small => BoxShadow(
    color: AppColors.shadow,
    offset: const Offset(0, 1),
    blurRadius: 3,
    spreadRadius: 0,
  );

  static BoxShadow get medium => BoxShadow(
    color: AppColors.shadow,
    offset: const Offset(0, 2),
    blurRadius: 6,
    spreadRadius: 0,
  );

  static BoxShadow get large => BoxShadow(
    color: AppColors.shadowDark,
    offset: const Offset(0, 4),
    blurRadius: 12,
    spreadRadius: 0,
  );

  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: AppColors.shadow, offset: const Offset(0, 2), blurRadius: 8, spreadRadius: 0),
    BoxShadow(
      color: AppColors.shadowLight,
      offset: const Offset(0, 1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
}

// Common widget styles and builders
class AppWidgets {
  static Widget buildCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    double? elevation,
    bool useBetterShadow = true,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
        boxShadow: useBetterShadow
            ? AppShadows.cardShadow
            : elevation != null && elevation > 0
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  offset: const Offset(0, 2),
                  blurRadius: elevation,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding ?? const EdgeInsets.all(AppSpacing.md), child: child),
    );
  }

  static Widget buildSectionHeader({
    required String title,
    Widget? trailing,
    Color? backgroundColor,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceVariant,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.medium),
          topRight: Radius.circular(AppBorderRadius.medium),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(child: Text(title, style: AppTextStyles.headline3)),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  static Widget buildStatusIndicator({required bool isOnline, String? label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline ? AppColors.online : AppColors.offline,
            shape: BoxShape.circle,
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isOnline ? AppColors.online : AppColors.offline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  static Widget buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.headline3.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: AppSpacing.lg), action],
          ],
        ),
      ),
    );
  }

  static Widget buildLoadingIndicator({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

// App Theme Configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: _createMaterialColor(AppColors.primary),
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.border,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary, // Will be overridden with gradient in widgets
        foregroundColor: AppColors.textOnPrimary,
        elevation: AppElevations.level2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnPrimary,
        ),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: AppElevations.level1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppBorderRadius.medium)),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: AppElevations.level2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.small)),
          textStyle: AppTextStyles.buttonText,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: AppElevations.level3,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.textOnPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.bodyMedium,
      ),
    );
  }

  // Helper function to create MaterialColor from brand colors
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

// Gradient AppBar Utility
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Gradient? gradient;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient ?? AppGradients.primary),
      child: AppBar(
        title: Text(title),
        actions: actions,
        leading: leading,
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
