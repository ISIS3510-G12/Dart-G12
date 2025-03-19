import 'package:flutter/material.dart';

class DropdownContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;

  const DropdownContainer({
    super.key,
    required this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: margin ?? EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }
}
