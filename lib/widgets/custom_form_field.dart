import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final bool obscure;
  final bool showObscureToggle;
  final IconData? prefixIcon;
  final VoidCallback? onEditingComplete;
  final int maxLines;
  final Widget? suffix;

  // NEW: support read-only fields (e.g., date picker) and onTap callback
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.obscure = false,
    this.showObscureToggle = false,
    this.prefixIcon,
    this.onEditingComplete,
    this.maxLines = 1,
    this.suffix,
    this.readOnly = false, // NEW
    this.onTap, // NEW
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        validator: widget.validator,
        obscureText: _obscure,
        maxLines: widget.maxLines,
        onEditingComplete: widget.onEditingComplete,
        readOnly: widget.readOnly, // NEW
        onTap: widget.onTap, // NEW
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: widget.prefixIcon == null
              ? null
              : Icon(widget.prefixIcon, color: Colors.grey.shade600),
          // If a custom suffix is provided, use it; else, show the eye toggle when enabled
          suffixIcon:
              widget.suffix ??
              (widget.showObscureToggle
                  ? IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade700,
                      ),
                    )
                  : null),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 14.h,
          ),
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: Colors.teal.shade400, width: 1.2),
          ),
          errorBorder: border.copyWith(
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          focusedErrorBorder: border.copyWith(
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
          ),
        ),
      ),
    );
  }
}
