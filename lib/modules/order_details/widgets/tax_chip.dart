import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TaxChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final GlobalKey? itemKey;

  const TaxChip({
    super.key,
    required this.itemKey,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = selected
        ? const Color(0xFF2563EB)
        : const Color(0xFFE0E7FF);
    final textColor = selected ? Colors.white : const Color(0xFF1E3A8A);

    return InkWell(
      borderRadius: BorderRadius.circular(50.r),
      onTap: onTap,
      child: Container(
        key: itemKey,
        height: 35.h,
        margin: EdgeInsets.only(right: 10.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    blurRadius: 15.r,
                    offset: const Offset(0, 4),
                    color: const Color(0xFF2563EB).withAlpha(50),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
