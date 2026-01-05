import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/add_receivable_screen.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddReceivableScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Receivable'),
      ),
    );
  }

  Widget _buildReceivablesList(String status) {
    final receivablesAsync = ref.watch(receivablesByStatusProvider(status));

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
                  size: 120,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 24),
                Text(
                  status == 'PENDING'
                      ? 'No pending receivables'
                      : 'No received payments yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  status == 'PENDING'
                      ? 'Add a receivable to track money you\'re owed'
                      : 'Mark pending receivables as received',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: receivables.length,
          itemBuilder: (context, index) {
            final receivable = receivables[index];
            return _buildReceivableCard(receivable);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildReceivableCard(receivable) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();
    final isPending = receivable.status == 'PENDING';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.brightness == Brightness.dark
              ? [const Color(0xFF1A2E3A), AppColors.darkCard]
              : [const Color(0xFFE0F7FA), const Color(0xFFE1F5FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(
          color: AppColors.receivableColor.withValues(alpha: 0.3 / 1.0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.receivableColor.withValues(alpha: 0.15 / 1.0),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.receivableGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.receivableColor.withValues(alpha: 0.4 / 1.0),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          receivable.description ?? 'Receivable',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(dateFormat.format(receivable.date)),
            if (receivable.dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${dateFormat.format(receivable.dueDate!)}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${receivable.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.receivableColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (isPending) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2 / 1.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: isPending
            ? () => _showMarkAsReceivedDialog(receivable)
            : null,
      ),
    );
  }

  void _showMarkAsReceivedDialog(receivable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Received'),
        content: Text(
          'Mark ₹${receivable.amount.toStringAsFixed(2)} as received?\n\n'
          '${receivable.autoCreateIncome ? 'An income transaction will be automatically created.' : ''}',
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
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marked as received'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
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
            child: const Text('Mark as Received'),
          ),
        ],
      ),
    );
  }
}

