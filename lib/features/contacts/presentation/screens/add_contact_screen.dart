import 'dart:io';

import 'package:flowpaisa/core/utils/name_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/shared/widgets/form_section_card.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/widgets/limit_countdown_badge.dart';

class AddContactScreen extends ConsumerStatefulWidget {
  final Contact? contactToEdit;

  const AddContactScreen({super.key, this.contactToEdit});

  @override
  ConsumerState<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends ConsumerState<AddContactScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _notesController;
  late bool _isCustomer;
  late bool _isSupplier;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.contactToEdit;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _phoneController = TextEditingController(text: existing?.phone ?? '');
    _emailController = TextEditingController(text: existing?.email ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    // Defaults match DB: customer on, supplier off for new contacts.
    _isCustomer = existing?.isCustomer ?? true;
    _isSupplier = existing?.isSupplier ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFromDevice() async {
    if (Platform.isWindows) {
      ToastUtils.showInfoToast(
          context, ref, "Importing contacts is not supported on Windows");
      return;
    }
    try {
      // Use readonly: true as it's often more reliable for just picking/reading
      // and correctly handles cases where permission is already granted.
      final granted = await fc.FlutterContacts.requestPermission(readonly: true);

      if (granted) {
        final deviceContact = await fc.FlutterContacts.openExternalPick();
        if (deviceContact != null) {
          // Fetch full contact details since openExternalPick might only return basic info
          final fullContact =
              await fc.FlutterContacts.getContact(deviceContact.id);
          if (fullContact != null) {
            _populateFromDeviceContact(fullContact);
          }
        }
      } else {
        // Fallback: Try to open the picker anyway, as some Android versions 
        // don't require app-level permission for the system picker intent.
        try {
          final deviceContact = await fc.FlutterContacts.openExternalPick();
          if (deviceContact != null) {
            final fullContact = await fc.FlutterContacts.getContact(deviceContact.id);
            if (fullContact != null) {
              _populateFromDeviceContact(fullContact);
              return;
            }
          }
        } catch (_) {
          // If fallback fails, show permission error
        }

        if (mounted) {
          ToastUtils.showErrorToast(
            context,
            ref,
            l10n.contactPermissionDenied,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
          context,
          ref,
          l10n.errorPickingContact(e.toString()),
        );
      }
    }
  }

  void _populateFromDeviceContact(fc.Contact deviceContact) async {
    setState(() {
      _nameController.text = deviceContact.displayName;
    });

    if (deviceContact.emails.isNotEmpty) {
      setState(() {
        _emailController.text = deviceContact.emails.first.address;
      });
    }

    if (deviceContact.phones.isNotEmpty) {
      if (deviceContact.phones.length == 1) {
        _setPhoneNumber(deviceContact.phones.first.number);
      } else {
        final selectedPhone = await _showPhoneNumberPicker(deviceContact);
        if (selectedPhone != null) {
          _setPhoneNumber(selectedPhone);
        }
      }
    }
  }

  void _setPhoneNumber(String phone) {
    // Clean phone number: keep only digits and +
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    setState(() {
      _phoneController.text = cleanPhone;
    });
  }

  Future<String?> _showPhoneNumberPicker(fc.Contact deviceContact) async {
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
                      : AppColors.lightTextSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.selectPhoneNumber,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: deviceContact.phones.length,
                  itemBuilder: (context, index) {
                    final phone = deviceContact.phones[index];
                    return ListTile(
                      leading: Icon(
                        Icons.phone_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(phone.number),
                      subtitle: phone.label != fc.PhoneLabel.mobile
                          ? Text(phone.label.name.toUpperCase())
                          : null,
                      onTap: () => Navigator.pop(context, phone.number),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveContact() async {
    // Check limits only for new contacts - call the method directly to get accurate current limits
    if (widget.contactToEdit == null) {
      final isPremium = PremiumGate.isPremium(ref);
      if (!isPremium) {
        final limits = await PremiumGate.getContactLimits(ref);
        if (!limits.canAdd) {
          if (mounted) {
            PremiumGate.showPremiumDialog(context);
          }
          return;
        }
      }
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (!_isCustomer && !_isSupplier) {
        ToastUtils.showErrorToast(context, ref, l10n.contactRoleRequired);
        return;
      }

      final repository = ref.read(contactsRepositoryProvider);
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim();
      final email = _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      Contact? createdOrUpdatedContact;

      if (widget.contactToEdit != null) {
        // Update existing
        final updatedContact = widget.contactToEdit!.copyWith(
          name: name,
          phone: drift.Value(phone),
          email: drift.Value(email),
          notes: drift.Value(notes),
          isCustomer: _isCustomer,
          isSupplier: _isSupplier,
        );
        await repository.updateContact(updatedContact);
        createdOrUpdatedContact = updatedContact;
      } else {
        // Create new
        final newUuid = const Uuid().v4();
        await repository.createContact(
          ContactsCompanion(
            uuid: drift.Value(newUuid),
            name: drift.Value(name),
            phone: drift.Value(phone),
            email: drift.Value(email),
            notes: drift.Value(notes),
            isCustomer: drift.Value(_isCustomer),
            isSupplier: drift.Value(_isSupplier),
          ),
        );
        // Get the created contact to return it
        createdOrUpdatedContact = await repository.getContactByUuid(newUuid);
      }

      if (mounted) {
        Navigator.pop(context, createdOrUpdatedContact);
        ToastUtils.showSuccessToast(
          context,
          ref,
          widget.contactToEdit != null
              ? l10n.contactUpdatedSuccessfully
              : l10n.contactAddedSuccessfully,
        );
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final limitsAsync = ref.watch(contactLimitsProvider);

    // Determine gradient based on name input or default
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.contactToEdit != null ? l10n.editContact : l10n.addContact),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar Preview
              Center(
                child: ValueListenableBuilder(
                  valueListenable: _nameController,
                  builder: (context, TextEditingValue value, child) {
                    final name = value.text.trim();
                    final theme = Theme.of(context);
                    final gradient = name.isNotEmpty
                        ? AppColors.getContactGradient(name)
                        : AppColors.getPrimaryGradient(theme.colorScheme.primary);

                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: gradient.colors.first.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        NameUtils.getInitials(name),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Import from Contacts Button
              Center(
                child: TextButton.icon(
                  onPressed: _pickFromDevice,
                  icon: const Icon(Icons.contact_page_outlined),
                  label: Text(l10n.importFromContacts),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              FormSectionCard(
                title: l10n.sectionDetails,
                icon: Icons.badge_outlined,
                accentColor: Theme.of(context).colorScheme.primary,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.name,
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterName;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: l10n.phoneNumberOptional,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      filled: true,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.emailOptional,
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: l10n.addressNotesOptional,
                      prefixIcon: const Icon(Icons.note_alt_outlined),
                      filled: true,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),

              FormSectionCard(
                title: l10n.contactRoles,
                icon: Icons.manage_accounts_outlined,
                accentColor: AppColors.receivableColor,
                children: [
                  Text(
                    l10n.contactRolesHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  _ContactRoleTile(
                    title: l10n.customer,
                    subtitle: l10n.contactRoleCustomerHint,
                    icon: Icons.person_outline,
                    accent: AppColors.receivableColor,
                    value: _isCustomer,
                    onChanged: (v) => setState(() => _isCustomer = v),
                  ),
                  _ContactRoleTile(
                    title: l10n.supplier,
                    subtitle: l10n.contactRoleSupplierHint,
                    icon: Icons.storefront_outlined,
                    accent: AppColors.payableColor,
                    value: _isSupplier,
                    onChanged: (v) => setState(() => _isSupplier = v),
                  ),
                ],
              ),

              // Countdown Badge (Only for new contacts, show until limit reached)
              if (widget.contactToEdit == null &&
                  limitsAsync.asData?.value != null &&
                  !limitsAsync.asData!.value.isUnlimited &&
                  limitsAsync.asData!.value.canAdd)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: LimitCountdownBadge(
                      totalUsed: limitsAsync.asData!.value.used,
                      totalLimit: limitsAsync.asData!.value.total,
                    ),
                  ),
                ),

              // Submit Button with Lock Icon (Only when limit reached for new contacts)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  GradientButton(
                    label: widget.contactToEdit != null
                        ? l10n.updateContact
                        : l10n.saveContact,
                    gradient: AppColors.getPrimaryGradient(Theme.of(context).colorScheme.primary),
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _saveContact,
                    width: double.infinity,
                  ),
                  if (widget.contactToEdit == null &&
                      limitsAsync.asData?.value != null &&
                      !limitsAsync.asData!.value.canAdd)
                    const Padding(
                      padding: EdgeInsets.only(top: 8, right: 8),
                      child: Icon(Icons.lock, size: 16, color: Colors.white),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRoleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ContactRoleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: accent.withValues(alpha: value ? 0.08 : 0.03),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(!value),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: accent.withValues(alpha: value ? 0.40 : 0.22),
              width: 0.8,
            ),
          ),
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 6),
            dense: true,
            visualDensity: VisualDensity.compact,
            secondary: Icon(icon, color: accent),
            title: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(subtitle),
            value: value,
            activeThumbColor: accent,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
