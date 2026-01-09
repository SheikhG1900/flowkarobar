import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/receivables/data/receivables_repository.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/add_receivable_screen.dart';
import 'package:flowpaisa/features/receivables/presentation/widgets/receivable_share_button.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:intl/intl.dart';

class ReceivablesListScreen extends ConsumerStatefulWidget {
  const ReceivablesListScreen({super.key});

  @override
  ConsumerState<ReceivablesListScreen> createState() =>
      _ReceivablesListScreenState();
}

class _ReceivablesListScreenState extends ConsumerState<ReceivablesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receivables'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.receivableColor,
          labelColor: AppColors.receivableColor,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReceivablesList('PENDING'),
          _buildReceivablesList('RECEIVED'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddReceivableScreen(),
            ),
          );
        },
        backgroundColor: AppColors.receivablesSectionColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReceivablesList(String status) {
    final receivablesAsync =
        ref.watch(receivablesWithContactsByStatusProvider(status));
    final theme = Theme.of(context);

    return receivablesAsync.when(
      data: (receivables) {
        if (receivables.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'PENDING'
                      ? Icons.hourglass_empty
                      : Icons.check_circle_outline,
                  size: 100,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 24),
                Text(
                  status == 'PENDING'
                      ? 'No pending receivables'
                      : 'No received payments',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  status == 'PENDING'
                      ? 'Add a receivable to track money owed to you'
                      : 'Mark pending receivables as received',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        // Group by Date
        final groupedReceivables = <String, List<ReceivableWithContact>>{};
        for (final item in receivables) {
          final dateKey = DateFormat.yMMMd().format(item.receivable.date);
          groupedReceivables.putIfAbsent(dateKey, () => []);
          groupedReceivables[dateKey]!.add(item);
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: groupedReceivables.length,
          itemBuilder: (context, index) {
            final dateKey = groupedReceivables.keys.elementAt(index);
            final dateItems = groupedReceivables[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    dateKey,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Items
                ...dateItems.map((item) => _buildReceivableCard(item)),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildReceivableCard(ReceivableWithContact item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final receivable = item.receivable;
    final contact = item.contact;
    final isPending = receivable.status == 'PENDING';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.receivableColor.withValues(alpha: isDark ? 0.2 : 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.receivableColor.withValues(alpha: isDark ? 0.05 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isPending ? () => _showMarkAsReceivedDialog(receivable) : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Contact Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.getContactGradient(contact?.name ?? ''),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getContactColor(contact?.name ?? '')
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    contact?.name.isNotEmpty == true
                        ? contact!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact?.name ?? 'Unknown',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (receivable.description != null &&
                          receivable.description!.isNotEmpty)
                        Text(
                          receivable.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (receivable.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.event,
                              size: 12,
                              color: isPending
                                  ? Colors.orange
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Due: ${DateFormat.yMMMd().format(receivable.dueDate!)}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isPending
                                    ? Colors.orange
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isPending ? FontWeight.bold : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Amount and Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${receivable.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.receivableColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPending)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.receivableColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'PENDING',
                              style: TextStyle(
                                color: AppColors.receivableColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: ReceivableShareButton(
                            receivable: receivable,
                            contact: contact,
                          ),
                        ),
                        if (isPending && contact?.phone != null && contact!.phone!.isNotEmpty)
                          InkWell(
                            onTap: () => _sendWhatsAppReminder(receivable, contact),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF25D366).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.chat,
                                size: 16,
                                color: Color(0xFF25D366),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendWhatsAppReminder(Receivable receivable, Contact? contact) async {
    if (contact == null || contact.phone == null || contact.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No phone number available for this contact'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final whatsAppService = ref.read(whatsAppServiceProvider);
      final message = whatsAppService.formatReceivableReminder(
        contactName: contact.name,
        amount: receivable.amount,
        description: receivable.description ?? '',
        dueDate: receivable.dueDate,
      );

      final success = await whatsAppService.sendMessage(contact.phone!, message);
      
      if (success && mounted) {
        // Optionally queue it for tracking
        final queueRepo = ref.read(whatsAppQueueRepositoryProvider);
        final queueId = await queueRepo.queueMessage(
          contactId: contact.id,
          message: message,
        );
        await queueRepo.markAsSent(queueId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening WhatsApp...'),
            backgroundColor: Color(0xFF25D366),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMarkAsReceivedDialog(Receivable receivable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Received'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Have you received the payment of ₹${receivable.amount.toStringAsFixed(2)}?',
            ),
            if (receivable.autoCreateIncome) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.incomeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.incomeColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 20, color: AppColors.incomeColor),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'This will also create an Income transaction.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final repository = ref.read(receivablesRepositoryProvider);
                await repository.markAsReceived(receivable.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marked as received'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.receivableColor,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
