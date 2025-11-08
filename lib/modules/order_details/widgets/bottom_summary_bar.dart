import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:invoice/widgets/custom_button.dart';
import '../../../utils/colors.dart';
import 'tax_chip.dart';

class BottomSummaryBar extends StatelessWidget {
  final List<String> taxSlabs;
  final String selectedTaxSlab;
  final void Function(String code) onSelectTaxSlab;

  final double subTotal;
  final double taxPercent;
  final double taxAmount;
  final double total;

  final VoidCallback? onNext;
  final bool isLoading;

  final String primaryLabel;

  final GlobalKey itemKey;
  final ScrollController scrollController;

  const BottomSummaryBar({
    super.key,
    required this.taxSlabs,
    required this.selectedTaxSlab,
    required this.onSelectTaxSlab,
    required this.subTotal,
    required this.taxPercent,
    required this.taxAmount,
    required this.total,
    required this.onNext,
    required this.isLoading,
    required this.itemKey,
    required this.scrollController,
    this.primaryLabel = "Generate Invoice",
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            blurRadius: 25.r,
            offset: const Offset(0, -4),
            color: Colors.black.withAlpha(10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tax Slab chips
            Text(
              "Tax Slab",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black45,
              ),
            ),
            8.h.verticalSpace,
            isLoading
                ? Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 16.h,
                          width: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                          ),
                        ),
                        4.w.horizontalSpace,
                        Text('Loading...'),
                      ],
                    ),
                  )
                : SizedBox(
                    height: 35.h,
                    child: ListView.builder(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: taxSlabs.length,
                      itemBuilder: (context, index) {
                        final taxSlab = taxSlabs[index];
                        final isSelected = selectedTaxSlab == taxSlab;
                        return TaxChip(
                          itemKey: isSelected ? itemKey : null,
                          label: taxSlab,
                          selected: isSelected,
                          onTap: () => onSelectTaxSlab(taxSlab),
                        );
                      },
                    ),
                  ),
            16.h.verticalSpace,

            // Subtotal / tax / total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Sub Total",
                  style: TextStyle(fontSize: 13.sp, color: Colors.black45),
                ),
                Text(
                  "\$${subTotal.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 13.sp,
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
                  "Tax ${(taxPercent * 100).toStringAsFixed(2)}%",
                  style: TextStyle(fontSize: 13.sp, color: Colors.black45),
                ),
                Text(
                  "\$${taxAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 13.sp,
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
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "\$${total.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            16.h.verticalSpace,

            CustomButton(
              label: primaryLabel,
              loading: isLoading,
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
