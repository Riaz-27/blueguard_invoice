import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Color? btnColor;
  final Color? txtColor;
  final double? borderRadius;
  final Color? borderColor;
  final VoidCallback? onPressed;
  final bool loading;
  final bool isExpanded;
  final TextStyle? txtStyle;
  final double? height;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.btnColor,
    this.txtColor,
    this.borderRadius,
    this.isExpanded = true,
    this.txtStyle,
    this.height,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 50.h,
      width: isExpanded ? double.infinity : null,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: btnColor ?? primaryColor,
          foregroundColor: txtColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
          ),
          side: BorderSide(
            color: borderColor ?? Colors.transparent,
            width: borderColor != null ? 1 : 0,
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style:
                    txtStyle ??
                    TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: txtColor ?? Colors.white,
                    ),
              ),
      ),
    );
  }
}
