import 'package:flutter/material.dart';
import 'package:smart_resource_ai/core/constants/app_dimens.dart';
import 'package:smart_resource_ai/core/constants/app_theme.dart';

class CustomTextField extends StatelessWidget {

  const CustomTextField({
    required this.controller, required this.label, required this.icon, super.key,
    this.isPassword = false,
    this.activeColor,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: AppTextStyles.body.copyWith(color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textLight),
        prefixIcon: Icon(icon, color: AppColors.textLight),
        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.r16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.r16), borderSide: BorderSide.none),

        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.r16),
            borderSide: BorderSide(color: activeColor ?? AppColors.primary, width: AppDimens.borderWidth)
        ),

        contentPadding: const EdgeInsets.symmetric(vertical: AppDimens.p16, horizontal: AppDimens.p20),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {

  const CustomButton({
    required this.text, required this.onTap, super.key,
    this.color,
    this.isLoading = false,
  });
  final String text;
  final VoidCallback onTap;
  final Color? color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          elevation: 0,

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.r16)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text, style: AppTextStyles.buttonText),
      ),
    );
  }
}

class CleanCard extends StatelessWidget {

  const CleanCard({required this.child, super.key, this.padding, this.onTap});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.r20),
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppDimens.p20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimens.r20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: AppDimens.blurRadius,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: child,
      ),
    );
  }
}
