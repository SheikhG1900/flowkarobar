import 'package:flutter/material.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';

/// A centralized contact solid gradient pill styled consistently across transaction lists.
class ContactSolidPill extends StatelessWidget {
  final String contactName;
  final Key? textKey;
  final bool isCompact;

  const ContactSolidPill({
    super.key,
    required this.contactName,
    this.textKey,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.getContactGradient(contactName),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        key: textKey,
        contactName,
        style: const TextStyle(
          fontSize: 9.5,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
