import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TaxChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TaxChip({
    super.key,
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
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    blurRadius: 12.r,
                    offset: const Offset(0, 4),
                    color: const Color(0xFF2563EB).withOpacity(0.4),
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
