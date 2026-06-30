import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flowpaisa/core/utils/name_utils.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final GoogleSignInAccount? user;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.user,
    this.size = 32,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget avatarContent;

    if (user == null) {
      avatarContent = Icon(Icons.person_outline, size: size * 0.6);
    } else if (user!.photoUrl != null &&
        user!.photoUrl!.isNotEmpty) {
      avatarContent = ClipOval(
        child: Image.network(
          user!.photoUrl!,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) =>
              _buildNameAvatar(theme),
        ),
      );
    } else {
      avatarContent = _buildNameAvatar(theme);
    }

    Widget container = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: avatarContent,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }

  Widget _buildNameAvatar(ThemeData theme) {
    final name = user?.displayName ?? user?.email ?? '?';
    final initial = NameUtils.getInitials(name);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.getContactGradient(name),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
