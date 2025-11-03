import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LabeledInputRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const LabeledInputRow({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final isNarrow = constraints.maxWidth < 400.w;

        if (isNarrow) {
          // mobile stacked layout: label above field
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              6.h.verticalSpace,
              _InputBox(
                controller: controller,
                hintText: hintText,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
              ),
            ],
          );
        }

        // wide layout: Row(label: input)
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140.w,
              child: Padding(
                padding: EdgeInsets.only(top: 14.h),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _InputBox(
                controller: controller,
                hintText: hintText,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const _InputBox({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: hintText,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: const Color(0xFFD1D9E6), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: const Color(0xFFD1D9E6), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: const Color(0xFF4F46E5), // indigo-600 style focus
            width: 1.4,
          ),
        ),
        fillColor: const Color(0xFFFDFEFE),
        filled: true,
      ),
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.black87,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
