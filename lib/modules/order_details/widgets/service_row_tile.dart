import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/service_item.dart';

class ServiceRowTile extends StatelessWidget {
  final ServiceItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const ServiceRowTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Name
          Expanded(
            flex: 5,
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Price
          Expanded(
            flex: 2,
            child: Text(
              item.price.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Qty + controls
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _QtyBtn(icon: Icons.remove, onTap: onDecrement),
                SizedBox(width: 8.w),
                Text(
                  item.qty.toString(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 8.w),
                _QtyBtn(icon: Icons.add, onTap: onIncrement),
                SizedBox(width: 12.w),
                InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(4.r),
                  child: Icon(Icons.close, size: 16.sp, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        color: Colors.white,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(6.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Icon(icon, size: 16.sp, color: Colors.black87),
        ),
      ),
    );
  }
}
