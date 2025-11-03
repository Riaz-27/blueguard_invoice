import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const PrimaryButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;

    return SizedBox(
      width: 160.w,
      height: 48.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: isDisabled ? 0 : 3,
          backgroundColor: isDisabled
              ? const Color(0xFF9CA3AF) // grey when disabled
              : const Color(0xFF34D399), // green-400ish
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
          textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}
