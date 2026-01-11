import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _notesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.contactToEdit?.name ?? '');
    _phoneController =
        TextEditingController(text: widget.contactToEdit?.phone ?? '');
    _emailController =
        TextEditingController(text: widget.contactToEdit?.email ?? '');
    _notesController =
        TextEditingController(text: widget.contactToEdit?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
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
        );
        await repository.updateContact(updatedContact);
        createdOrUpdatedContact = updatedContact;
      } else {
        // Create new
        final contactId = await repository.createContact(
          ContactsCompanion(
            name: drift.Value(name),
            phone: drift.Value(phone),
            email: drift.Value(email),
            notes: drift.Value(notes),
          ),
        );
        // Get the created contact to return it
        createdOrUpdatedContact = await repository.getContactById(contactId);
      }

      if (mounted) {
        Navigator.pop(context, createdOrUpdatedContact);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.contactToEdit != null
                ? 'Contact updated successfully'
                : 'Contact added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
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
            Text(widget.contactToEdit != null ? 'Edit Contact' : 'Add Contact'),
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
                    final gradient = name.isNotEmpty
                        ? AppColors.getContactGradient(name)
                        : AppColors.primaryGradient;

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
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
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
              const SizedBox(height: 32),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Address/Notes Field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Address / Notes (Optional)',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

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
                        ? 'Update Contact'
                        : 'Save Contact',
                    gradient: AppColors.primaryGradient,
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
