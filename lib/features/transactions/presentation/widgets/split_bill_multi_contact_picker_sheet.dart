import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/contacts/data/contacts_repository.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/add_contact_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the same multi-select contact drawer used for split bill flows.
Future<List<Contact>?> showSplitBillMultiContactPicker(
  BuildContext context, {
  required Set<String> excludeContactUuids,
}) {
  return showModalBottomSheet<List<Contact>>(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Consumer(
        builder: (context, ref, _) {
          final contactsAsync = ref.watch(smartContactsProvider);
          final theme = Theme.of(context);
          final l10n = AppLocalizations.of(context)!;
          return SplitBillMultiContactPickerSheet(
            scrollController: scrollController,
            contactsAsync: contactsAsync,
            excludeContactUuids: excludeContactUuids,
            theme: theme,
            l10n: l10n,
          );
        },
      ),
    ),
  );
}

/// Multi-select contacts for split bill; confirm with the primary Add action.
class SplitBillMultiContactPickerSheet extends StatefulWidget {
  final ScrollController scrollController;
  final AsyncValue<List<ContactWithUsage>> contactsAsync;
  final Set<String> excludeContactUuids;
  final ThemeData theme;
  final AppLocalizations l10n;

  const SplitBillMultiContactPickerSheet({
    super.key,
    required this.scrollController,
    required this.contactsAsync,
    required this.excludeContactUuids,
    required this.theme,
    required this.l10n,
  });

  @override
  State<SplitBillMultiContactPickerSheet> createState() =>
      _SplitBillMultiContactPickerSheetState();
}

class _SplitBillMultiContactPickerSheetState
    extends State<SplitBillMultiContactPickerSheet> {
  final Set<String> _selectedUuids = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                widget.l10n.selectContact,
                style: widget.theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final newContact = await Navigator.push<Contact>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddContactScreen(),
                    ),
                  );
                  if (newContact != null &&
                      context.mounted &&
                      !widget.excludeContactUuids
                          .contains(newContact.uuid)) {
                    Navigator.pop(context, [newContact]);
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(widget.l10n.addNew),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.contactsAsync.when(
            data: (contactsWithUsage) {
              final filtered = contactsWithUsage
                  .where((item) =>
                      !widget.excludeContactUuids.contains(item.contact.uuid))
                  .toList();
              if (filtered.isEmpty) {
                return Center(
                  child: Text(contactsWithUsage.isEmpty
                      ? widget.l10n.noContactsFound
                      : widget.l10n.allContactsAddedToSplit),
                );
              }
              return ListView.builder(
                controller: widget.scrollController,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final contact = item.contact;
                  final selected = _selectedUuids.contains(contact.uuid);
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Material(
                      color: selected
                          ? widget.theme.colorScheme.primary
                              .withValues(alpha: 0.12)
                          : widget.theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selectedUuids.remove(contact.uuid);
                            } else {
                              _selectedUuids.add(contact.uuid);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: AppColors.getContactGradient(
                                      contact.name),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  contact.name.isNotEmpty
                                      ? contact.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      contact.name,
                                      style:
                                          widget.theme.textTheme.titleMedium,
                                    ),
                                    if (contact.phone != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        contact.phone!,
                                        style: widget.theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: widget.theme.colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (selected)
                                Icon(
                                  Icons.check_circle,
                                  color: widget.theme.colorScheme.primary,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(
              child: Text(widget.l10n.errorOccurred(e.toString())),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                final contactsWithUsage = widget.contactsAsync.value;
                if (contactsWithUsage == null) return;
                final filtered = contactsWithUsage
                    .where((item) => !widget.excludeContactUuids
                        .contains(item.contact.uuid))
                    .toList();
                final selected = filtered
                    .where((item) =>
                        _selectedUuids.contains(item.contact.uuid))
                    .map((item) => item.contact)
                    .toList();
                Navigator.pop(context, selected);
              },
              icon: const Icon(Icons.add),
              label: Text(widget.l10n.add),
            ),
          ),
        ),
      ],
    );
  }
}
