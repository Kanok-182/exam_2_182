import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF0B3D4C);
  static const teal = Color(0xFF0E7C86);
  static const green = Color(0xFF0FB87A);
  static const bg = Color(0xFFF4F7FA);
  static const danger = Color(0xFFE5484D);
}

const appGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.navy, AppColors.teal, AppColors.green],
);

InputDecoration fieldDeco({
  required String label,
  required IconData icon,
  String? hint,
  String? suffix,
}) {
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixText: suffix,
    prefixIcon: Icon(icon, color: AppColors.teal),
    filled: true,
    fillColor: Colors.white,
    border: border(Colors.grey.shade300),
    enabledBorder: border(Colors.grey.shade300),
    focusedBorder: border(AppColors.green, 2),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger, 2),
  );
}

void showSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.danger : AppColors.navy,
      behavior: SnackBarBehavior.floating,
    ));
}

String formatNum(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
