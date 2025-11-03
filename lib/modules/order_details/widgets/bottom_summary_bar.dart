import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'tax_chip.dart';

class BottomSummaryBar extends StatelessWidget {
  final List<String> provinceChips;
  final String selectedProvince;
  final void Function(String code) onSelectProvince;

  final double subTotal;
  final double taxPercent;
  final double taxAmount;
  final double total;

  final VoidCallback? onNext;
  final bool isLoading;

  const BottomSummaryBar({
    super.key,
    required this.provinceChips,
    required this.selectedProvince,
    required this.onSelectProvince,
    required this.subTotal,
    required this.taxPercent,
    required this.taxAmount,
    required this.total,
    required this.onNext,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.h,
        bottom: 16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20.r,
            offset: const Offset(0, -4),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tax Slab chips
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tax Slab:",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            8.h.verticalSpace,
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: provinceChips.map((code) {
                final isSelected = selectedProvince == code;
                return TaxChip(
                  label: code,
                  selected: isSelected,
                  onTap: () => onSelectProvince(code),
                );
              }).toList(),
            ),

            16.h.verticalSpace,

            // Subtotal / tax / total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Sub Total",
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                ),
                Text(
                  "\$${subTotal.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            6.h.verticalSpace,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tax ${(taxPercent * 100).toStringAsFixed(0)}%",
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                ),
                Text(
                  "\$${taxAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            8.h.verticalSpace,
            Divider(thickness: 1, color: const Color(0xFFE5E7EB), height: 1.h),
            8.h.verticalSpace,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "\$${total.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            16.h.verticalSpace,

            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C), // orange CTA
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(
                  isLoading ? "Please wait..." : "Next",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
