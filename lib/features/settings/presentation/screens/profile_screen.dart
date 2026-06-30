import 'dart:io';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/core/utils/name_utils.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/currencies/presentation/screens/currencies_list_screen.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/features/onboarding/presentation/providers/onboarding_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.addListener(() {
      setState(() {});
    });
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();

    // Load existing profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userProfileProvider);
      _nameController.text = profile.name ?? '';
      _emailController.text = profile.email ?? '';
      _phoneController.text = profile.phone ?? '';
      _addressController.text = profile.address ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(userProfileProvider.notifier);

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        await notifier.updateName(_nameController.text);
        await notifier.updateEmail(_emailController.text);
        await notifier.updatePhone(_phoneController.text);
        await notifier.updateAddress(_addressController.text);

        if (mounted) {
          Navigator.pop(context); // Close loading
          ToastUtils.showSuccessToast(context, ref, l10n.profileUpdated);
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ToastUtils.showErrorToast(
              context, ref, l10n.errorOccurred(e.toString()));
        }
      }
    }
  }

  void _showDateFormatSelector() {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.read(userProfileProvider);
    final theme = Theme.of(context);
    final now = DateTime.now();

    final predefinedFormats = [
      'MMM dd, yyyy',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'yyyy-MM-dd',
      'dd MMM yyyy',
      'EEEE, MMM dd, yyyy',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.selectDateFormat,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...predefinedFormats.map((format) => ListTile(
                        title: Text(format),
                        subtitle: Text(l10n.sample(
                            AppDateFormatter.formatDate(now, pattern: format))),
                        trailing: profile.dateFormat == format
                            ? Icon(Icons.check_circle,
                                color: theme.colorScheme.primary)
                            : null,
                        onTap: () {
                          ref
                              .read(userProfileProvider.notifier)
                              .updateDateFormat(format);
                          Navigator.pop(context);
                        },
                      )),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: Text(l10n.customFormat),
                    subtitle: Text(l10n.enterCustomDateFormat),
                    onTap: () {
                      Navigator.pop(context);
                      _showCustomDateFormatDialog();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomDateFormatDialog() {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.read(userProfileProvider);
    final controller = TextEditingController(text: profile.dateFormat);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.customDateFormat),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: l10n.formatPattern,
                  hintText: 'e.g., dd-MM-yyyy',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),
              if (controller.text.isNotEmpty)
                Text(
                  l10n.sample(AppDateFormatter.formatDate(DateTime.now(),
                      pattern: controller.text)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                l10n.dateFormatInstructions,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref
                      .read(userProfileProvider.notifier)
                      .updateDateFormat(controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(userProfileProvider);
    final backupState = ref.watch(backupProvider);
    final backupNotifier = ref.read(backupProvider.notifier);
    final theme = Theme.of(context);

    ref.listen<BackupState>(backupProvider, (previous, next) {
      if (next.accountMismatchWarning != null &&
          (previous == null || previous.accountMismatchWarning == null)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.accountChangedTitle),
            content: Text(l10n.accountChangedMessage(
              next.accountMismatchWarning!.oldEmail,
              next.accountMismatchWarning!.newEmail,
            )),
            actions: [
              TextButton(
                onPressed: () {
                  ref
                      .read(backupProvider.notifier)
                      .clearAccountMismatchWarning();
                  Navigator.pop(context);
                },
                child: Text(l10n.understood),
              ),
            ],
          ),
        );
      }
    });

    final bool isGoogleSignedIn = backupState.currentUser != null;
    final String? photoUrl = backupState.currentUser?.photoUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    if (isGoogleSignedIn &&
                        photoUrl != null &&
                        photoUrl.isNotEmpty)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: theme.colorScheme.primary, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.getContactGradient(
                                    _nameController.text.isEmpty
                                        ? (profile.name ?? '')
                                        : _nameController.text),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  NameUtils.getInitials(
                                      _nameController.text.isEmpty
                                          ? (profile.name ?? '')
                                          : _nameController.text),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppColors.getContactGradient(
                              _nameController.text.isEmpty
                                  ? (profile.name ?? '')
                                  : _nameController.text),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.getContactColor(
                                      _nameController.text.isEmpty
                                          ? (profile.name ?? '')
                                          : _nameController.text)
                                  .withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            NameUtils.getInitials(_nameController.text.isEmpty
                                ? (profile.name ?? '')
                                : _nameController.text),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Google Connect Card (same width as name/email fields)
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.cloudBackupAccount,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isGoogleSignedIn) ...[
                        Row(
                          children: [
                            const Icon(Icons.cloud_done, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                backupState.currentUser!.email,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                if (backupState.syncInterval != 'manual') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(l10n.signOut),
                                      content: Text(
                                        l10n.signOutSyncConfirmMessage,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: Text(l10n.cancel),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: Text(l10n.signOut),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm != true || !mounted) return;
                                }
                                await backupNotifier.signOut();
                              },
                              icon: Transform.scale(
                                scaleX: Directionality.of(context) ==
                                        TextDirection.rtl
                                    ? -1
                                    : 1,
                                child: const Icon(Icons.logout_outlined),
                              ),
                              color: theme.colorScheme.error,
                              tooltip: l10n.signOut,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _nameController.text =
                                    backupState.currentUser!.displayName ?? '';
                                _emailController.text =
                                    backupState.currentUser!.email;
                              });
                            },
                            icon: const Icon(Icons.auto_awesome),
                            label: Text(l10n.autofillFromGoogle),
                          ),
                        ),
                      ] else ...[
                        if (!Platform.isWindows) ...[
                          Row(
                            children: [
                              const Icon(Icons.cloud_off, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.signInGoogleToBackup,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (Platform.isWindows || PremiumGate.isPremium(ref)) {
                                backupNotifier.signIn();
                              } else {
                                PremiumGate.showPremiumDialog(context);
                              }
                            },
                            icon: Transform.scale(
                              scaleX: Directionality.of(context) ==
                                      TextDirection.rtl
                                  ? -1
                                  : 1,
                              child: const Icon(Icons.login),
                            ),
                            label: Text(l10n.connectGoogleDrive),
                          ),
                        ),
                      ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Premium Token Card
                Consumer(
                  builder: (context, ref, child) {
                    final premiumState = ref.watch(premiumProvider);
                    final token = premiumState.premiumToken;
                    final expiry = premiumState.premiumTokenExpiry;
                    final now = DateTime.now();

                    Color statusColor = Colors.grey;
                    String statusText = l10n.premiumTokenMissing;
                    IconData statusIcon = Icons.token_outlined;

                    if (!premiumState.isPremium) {
                      statusColor = theme.colorScheme.error;
                      statusText = l10n.premiumTokenMissing;
                      statusIcon = Icons.token_outlined;
                    } else if (token == null || expiry == null) {
                      statusColor = Colors.grey;
                      statusText = l10n.noTokenGenerated;
                      statusIcon = Icons.token_outlined;
                    } else {
                      final diff = expiry.difference(now);
                      if (diff.isNegative) {
                        statusColor = theme.colorScheme.error;
                        statusText = l10n.tokenExpired;
                        statusIcon = Icons.error_outline;
                      } else if (diff.inDays < 2) {
                        statusColor = Colors.orange;
                        statusText = l10n.tokenExpiringSoon;
                        statusIcon = Icons.warning_amber_rounded;
                      } else {
                        statusColor = Colors.amber;
                        statusText = l10n.tokenValid;
                        statusIcon = Icons.workspace_premium;
                      }
                    }

                    return Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  statusIcon,
                                  color: statusColor,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                statusText,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                              subtitle: expiry != null
                                  ? Text(
                                      '${l10n.tokenExpiry}: ${AppDateFormatter.formatDate(expiry, pattern: profile.dateFormat)}',
                                      style: theme.textTheme.bodySmall,
                                    )
                                  : Text(
                                      premiumState.isPremium
                                          ? l10n.noTokenGenerated
                                          : l10n.upgradeToPremium,
                                      style: theme.textTheme.bodySmall,
                                    ),
                              trailing: isGoogleSignedIn
                                  ? IconButton(
                                      icon: Icon(
                                        Platform.isWindows
                                            ? Icons.download
                                            : Icons.refresh,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        if (Platform.isWindows) {
                                          final success = await ref
                                              .read(premiumProvider.notifier)
                                              .verifyPremiumFromGoogleDrive();
                                          if (context.mounted) {
                                            if (success) {
                                              ToastUtils.showSuccessToast(
                                                  context,
                                                  ref,
                                                  l10n.premiumTokenSyncedSuccess);
                                            } else {
                                              ToastUtils.showErrorToast(
                                                  context,
                                                  ref,
                                                  l10n.premiumTokenNotFound);
                                            }
                                          }
                                        } else {
                                          if (premiumState.isPremium) {
                                            await ref
                                                .read(premiumProvider.notifier)
                                                .generatePremiumToken();
                                            if (context.mounted) {
                                              ToastUtils.showSuccessToast(
                                                  context,
                                                  ref,
                                                  l10n.tokenRegeneratedSuccess);
                                            }
                                          }
                                        }
                                      },
                                      tooltip: Platform.isWindows
                                          ? l10n.fetchPremiumToken
                                          : l10n.refreshToken,
                                    )
                                  : null,
                            ),
                            const Divider(height: 16, thickness: 0.5),
                            Text(
                              l10n.premiumTokenDescription,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 32),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  hintText: l10n.enterName,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  hintText: l10n.enterEmail,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value.contains('@')) {
                      return l10n.enterValidEmail;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  hintText: l10n.enterPhoneNumber,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: l10n.address,
                  hintText: l10n.enterAddress,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.streetAddress,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Preferences Section
              Text(
                l10n.preferences,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Currency Preference
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final currentCurrencyAsync =
                        ref.watch(currentCurrencyProvider);
                    return currentCurrencyAsync.when(
                      data: (currency) => ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.currency_rupee,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(l10n.currency),
                        subtitle: Text('${currency.name} (${currency.symbol})'),
                        trailing: Transform.scale(
                          scaleX:
                              Directionality.of(context) == TextDirection.rtl
                                  ? -1
                                  : 1,
                          child: const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CurrenciesListScreen(),
                            ),
                          );
                        },
                      ),
                      loading: () => ListTile(
                        title: Text(l10n.currency),
                        subtitle: Text(l10n.loading),
                      ),
                      error: (error, stack) => ListTile(
                        title: Text(l10n.currency),
                        subtitle: Text(l10n.errorOccurred(error.toString())),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Date Format Preference
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(l10n.dateFormat),
                  subtitle: Text(profile.dateFormat),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showDateFormatSelector,
                ),
              ),
              const SizedBox(height: 12),

              // Reset Onboarding Preference
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.tour_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(l10n.appTour),
                  subtitle: Text(l10n.resetOnboardingSubtitle),
                  trailing: const Icon(Icons.refresh, size: 16),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.appTour),
                        content: Text(l10n.resetOnboardingConfirmation),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(l10n.reset),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      ref
                          .read(onboardingCompletedProvider.notifier)
                          .setCompleted(false);
                      if (mounted) {
                        ToastUtils.showSuccessToast(
                            context, ref, l10n.onboardingResetSuccess);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              GradientButton(
                label: l10n.saveProfile,
                icon: Icons.check,
                onPressed: _saveProfile,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
