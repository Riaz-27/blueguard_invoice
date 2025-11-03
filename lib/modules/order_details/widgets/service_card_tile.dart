import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../order_details_controller.dart';

class ServiceCardTile extends StatelessWidget {
  final ServiceItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const ServiceCardTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            blurRadius: 20.r,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON / THUMBNAIL
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.cleaning_services_rounded,
              color: const Color(0xFF1E293B),
              size: 28.sp,
            ),
          ),

          12.w.horizontalSpace,

          // TEXT + CONTROLS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // first row: name + close btn
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(4.r),
                      onTap: onRemove,
                      child: Icon(
                        Icons.close,
                        size: 16.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                4.h.verticalSpace,

                // optional subtext
                Text(
                  "Service",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                  ),
                ),

                8.h.verticalSpace,

                // bottom row: price + qty pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${item.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    _QtyPill(
                      qty: item.qty,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  final int qty;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QtyPill({
    required this.qty,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: Icon(Icons.remove, size: 16.sp, color: Colors.white),
          ),
          8.w.horizontalSpace,
          Text(
            qty.toString(),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          8.w.horizontalSpace,
          GestureDetector(
            onTap: onIncrement,
            child: Icon(Icons.add, size: 16.sp, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
