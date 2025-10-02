import 'package:flutter/material.dart';
import 'package:flutter_camera/presentation/ui/shared/design_system.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(8));
    const textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);

    final buttonChild = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Text(text, style: textStyle);

    if (gradient != null) {
      // Gradient button
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: borderRadius,
            child: Center(child: buttonChild),
          ),
        ),
      );
    }

    // Regular button
    return SizedBox(
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 2,
        ),
        child: buttonChild,
      ),
    );
  }
}