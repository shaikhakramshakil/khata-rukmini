import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';

class RecycleBinScreen extends ConsumerStatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  ConsumerState<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends ConsumerState<RecycleBinScreen> {
  bool _isLoading = false;

  Future<void> _restoreTransaction(String id, String partyId) async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.restoreTransaction(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restored successfully.')),
        );
      }
      setState(() {}); // Re-trigger FutureBuilder
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.read(databaseProvider);
    
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Recycle Bin (Deleted Transactions)', style: AppTypography.headingMedium),
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      body: FutureBuilder(
        future: db.getAllTransactionsWithParty(onlyDeleted: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Recycle bin is empty.', style: AppTypography.bodyMedium));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, _) => const Divider(color: AppColors.hairline),
            itemBuilder: (context, index) {
              final txn = items[index].transaction;
              final party = items[index].party;
              
              return ListTile(
                title: Text('${party.name} - ${AppFormatters.formatCurrency(txn.amount)}', style: AppTypography.bodyMedium),
                subtitle: Text('${AppFormatters.formatInputDate(txn.date)} • ${txn.type}', style: AppTypography.bodySmall),
                trailing: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                      icon: const Icon(Icons.restore, color: AppColors.ink),
                      tooltip: 'Restore',
                      onPressed: () => _restoreTransaction(txn.id, party.id),
                    ),
              );
            },
          );
        },
      ),
    );
  }
}
