import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LabeledFieldBlock extends StatelessWidget {
  final String label;
  final Widget child;

  const LabeledFieldBlock({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        6.h.verticalSpace,
        child,
      ],
    );
  }
}
