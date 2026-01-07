import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/screens/add_payable_screen.dart';
import 'package:intl/intl.dart';

class PayablesListScreen extends ConsumerStatefulWidget {
  const PayablesListScreen({super.key});

  @override
  ConsumerState<PayablesListScreen> createState() =>
      _PayablesListScreenState();
}

class _PayablesListScreenState extends ConsumerState<PayablesListScreen>
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
        title: const Text('Payables'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Paid'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPayablesList('PENDING'),
          _buildPayablesList('PAID'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPayableScreen(),
            ),
          );
        },
        backgroundColor: AppColors.payablesSectionColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPayablesList(String status) {
    final payablesAsync = ref.watch(payablesByStatusProvider(status));

    return payablesAsync.when(
      data: (payables) {
        if (payables.isEmpty) {
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
                      ? 'No pending payables'
                      : 'No paid bills yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  status == 'PENDING'
                      ? 'Add a payable to track money you owe'
                      : 'Mark pending payables as paid',
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
          itemCount: payables.length,
          itemBuilder: (context, index) {
            final payable = payables[index];
            return _buildPayableCard(payable);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildPayableCard(Payable payable) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();
    final isPending = payable.status == 'PENDING';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.brightness == Brightness.dark
              ? [const Color(0xFF3A2E1A), AppColors.darkCard]
              : [const Color(0xFFFFF9E6), const Color(0xFFFFF5E1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(
          color: AppColors.payableColor.withValues(alpha: 0.3 / 1.0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.payableColor.withValues(alpha: 0.15 / 1.0),
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
            gradient: AppColors.payableGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.payableColor.withValues(alpha: 0.4 / 1.0),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.payment_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          payable.description ?? 'Payable',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(dateFormat.format(payable.date)),
            if (payable.dueDate != null) ...[
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
                    'Due: ${dateFormat.format(payable.dueDate!)}',
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
              '₹${payable.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.payableColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (isPending) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2 / 1.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: isPending ? () => _showMarkAsPaidDialog(payable) : null,
      ),
    );
  }

  void _showMarkAsPaidDialog(Payable payable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: Text(
          'Mark ₹${payable.amount.toStringAsFixed(2)} as paid?\n\n'
          '${payable.autoCreateExpense ? 'An expense transaction will be automatically created.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final repository = ref.read(payablesRepositoryProvider);
                await repository.markAsPaid(payable.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marked as paid'),
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
            child: const Text('Mark as Paid'),
          ),
        ],
      ),
    );
  }
}

