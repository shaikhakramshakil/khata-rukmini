import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../backup/backup_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../parties/interest_calculator_dialog.dart';
import '../parties/party_list_screen.dart';
import '../parties/party_profile_screen.dart';
import '../search/global_search_dialog.dart';
import '../settings/first_run_dialog.dart';
import '../settings/settings_screen.dart';
import '../statements/statement_screen.dart';
import '../transactions/transaction_detail_dialog.dart';
import '../transactions/transaction_form_dialog.dart';
import '../transactions/transaction_list_screen.dart';

import 'package:khata_rukmini/core/services/update_service.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedTabIndex = 0;
  String? _activePartyProfileId;
  String? _statementPartyId;
  final UpdateService _updateService = UpdateService();
  bool _isCheckingUpdate = false;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  bool _hasCheckedFirstRun = false;

  @override
  void initState() {
    super.initState();
    // Rebuild app bar on shop settings change
    ref.listenManual(shopSettingsProvider, (prev, next) {
      if (mounted) setState(() {});
    });
    
    // Check for updates on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runStartupChecks();
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    if (_isCheckingUpdate) return;
    setState(() => _isCheckingUpdate = true);
    
    try {
      final updateInfo = await _updateService.checkForUpdate();
      if (!mounted) return;
      setState(() => _isCheckingUpdate = false);

      if (updateInfo != null) {
        _showUpdateDialog(updateInfo);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCheckingUpdate = false);
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: !updateInfo.isMandatory,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Update Available'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Version ${updateInfo.version} is available!'),
                  const SizedBox(height: 12),
                  Text('Release Notes:', style: AppTypography.label),
                  const SizedBox(height: 4),
                  Text(updateInfo.releaseNotes),
                  if (_isDownloading) ...[
                    const SizedBox(height: 24),
                    LinearProgressIndicator(value: _downloadProgress),
                    const SizedBox(height: 8),
                    Text('${(_downloadProgress * 100).toStringAsFixed(1)}% downloaded'),
                  ]
                ],
              ),
            ),
            actions: [
              if (!updateInfo.isMandatory && !_isDownloading)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Later'),
                ),
              if (!_isDownloading)
                AppButton(
                  label: 'Update Now',
                  onPressed: () async {
                    setDialogState(() {
                      _isDownloading = true;
                      _downloadProgress = 0.0;
                    });
                    final file = await _updateService.downloadUpdate(
                      updateInfo.downloadUrl, 
                      (count, total) {
                        if (total > 0) {
                          setDialogState(() => _downloadProgress = count / total);
                        }
                      }
                    );
                    if (file != null) {
                      _updateService.installUpdateAndRestart(file);
                    } else {
                      setDialogState(() => _isDownloading = false);
                      // Show error...
                    }
                  },
                ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _runStartupChecks() async {
    if (_hasCheckedFirstRun) return;
    _hasCheckedFirstRun = true;

    final settings = await ref.read(settingsRepositoryProvider).getSettings();
    final backupService = ref.read(backupServiceProvider);

    // 1. Check auto-backup
    try {
      await backupService.checkAndRunDailyBackup();
    } catch (_) {}

    // 2. Check first run
    if (!settings.isFirstRunCompleted && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const FirstRunSetupDialog(),
      );
    }
  }

  void _openSearch() {
    showDialog(
      context: context,
      builder: (ctx) => GlobalSearchDialog(
        onSelectParty: (party) {
          setState(() {
            _activePartyProfileId = party.id;
            _selectedTabIndex = party.type == 'supplier' ? 2 : 1;
          });
        },
        onSelectTransaction: (txn) {
          showDialog(
            context: context,
            builder: (c) => TransactionDetailDialog(transactionId: txn.id),
          );
        },
      ),
    );
  }

  void _openNewTransaction() {
    showDialog(
      context: context,
      builder: (ctx) => const TransactionFormDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(shopSettingsProvider);
    final rawShopName = settingsAsync.value?.shopName.trim();
    final shopName = (rawShopName != null && rawShopName.isNotEmpty)
        ? rawShopName
        : 'Rukmini Khata Book';

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _openSearch,
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            _openNewTransaction,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              // Top Bar
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: AppColors.elevated,
                  border: Border(bottom: BorderSide(color: AppColors.hairline)),
                ),
                child: Row(
                  children: [
                    // Brand / Shop title
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.menu_book_outlined,
                            size: 20,
                            color: AppColors.ink,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              shopName,
                              style: AppTypography.label.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Centered Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Global Search Button (Ctrl + K)
                        InkWell(
                          onTap: _openSearch,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.hairlineSoft,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.hairline),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  size: 16,
                                  color: AppColors.mute,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Search anything...',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.mute,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.elevated,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.hairline),
                                  ),
                                  child: Text(
                                    'Ctrl K',
                                    style: AppTypography.codeMono.copyWith(
                                      fontSize: 10,
                                      color: AppColors.mute,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Global Interest Calculator
                        AppButton(
                          label: 'Interest Calc',
                          variant: AppButtonVariant.secondary,
                          icon: Icons.percent,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => const InterestCalculatorDialog(),
                            );
                          },
                        ),

                        const SizedBox(width: 8),

                        // Quick Transaction Button (Ctrl + N)
                        AppButton(
                          label: 'New Entry',
                          variant: AppButtonVariant.primary,
                          icon: Icons.add,
                          onPressed: _openNewTransaction,
                        ),
                      ],
                    ),

                    // Right padding to balance the left Expanded, making the middle Row perfectly centered
                    const Spacer(),
                  ],
                ),
              ),

              // Main Workspace: Sidebar + Content
              Expanded(
                child: Row(
                  children: [
                    // Fixed Sidebar
                    Container(
                      width: 220,
                      decoration: const BoxDecoration(
                        color: AppColors.elevated,
                        border: Border(
                          right: BorderSide(color: AppColors.hairline),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          _buildSidebarItem(
                            0,
                            Icons.dashboard_outlined,
                            'Dashboard',
                          ),
                          _buildSidebarItem(
                            1,
                            Icons.people_outline,
                            'Customers',
                          ),
                          _buildSidebarItem(
                            2,
                            Icons.local_shipping_outlined,
                            'Suppliers',
                          ),
                          _buildSidebarItem(
                            3,
                            Icons.swap_horiz,
                            'Transactions',
                          ),
                          _buildSidebarItem(
                            4,
                            Icons.receipt_long_outlined,
                            'Statements',
                          ),
                          const Spacer(),
                          const Divider(height: 1, color: AppColors.hairline),
                          _buildSidebarItem(
                            5,
                            Icons.settings_outlined,
                            'Settings',
                          ),
                          _buildSidebarItem(
                            6,
                            Icons.backup_outlined,
                            'Backup & Restore',
                          ),
                          const Divider(height: 1, color: AppColors.hairline),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: InkWell(
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Log Out'),
                                    content: const Text(
                                      'Are you sure you want to log out of the application?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text(
                                          'Log Out',
                                          style: TextStyle(
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  ref
                                      .read(isLoggedInProvider.notifier)
                                      .logout();
                                }
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                height: 38,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.logout_outlined,
                                      size: 18,
                                      color: AppColors.mute,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Log Out',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.mute,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                    // Dynamic Content View
                    Expanded(child: _buildCurrentContent()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    final isSelected = _selectedTabIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            _activePartyProfileId = null;
            _statementPartyId = null;
          });
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.hairlineSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.ink : AppColors.mute,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.ink : AppColors.body,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentContent() {
    if (_activePartyProfileId != null) {
      return PartyProfileScreen(
        partyId: _activePartyProfileId!,
        onBack: () => setState(() => _activePartyProfileId = null),
        onOpenStatement: (partyId) {
          setState(() {
            _statementPartyId = partyId;
            _selectedTabIndex = 4;
            _activePartyProfileId = null;
          });
        },
      );
    }

    switch (_selectedTabIndex) {
      case 0:
        return DashboardScreen(
          onNavigateTab: (tabIndex) =>
              setState(() => _selectedTabIndex = tabIndex),
          onSelectParty: (partyId) =>
              setState(() => _activePartyProfileId = partyId),
        );
      case 1:
        return PartyListScreen(
          partyType: 'customer',
          onSelectParty: (id) => setState(() => _activePartyProfileId = id),
          onOpenStatement: (id) {
            setState(() {
              _statementPartyId = id;
              _selectedTabIndex = 4;
            });
          },
        );
      case 2:
        return PartyListScreen(
          partyType: 'supplier',
          onSelectParty: (id) => setState(() => _activePartyProfileId = id),
          onOpenStatement: (id) {
            setState(() {
              _statementPartyId = id;
              _selectedTabIndex = 4;
            });
          },
        );
      case 3:
        return const TransactionListScreen();
      case 4:
        return StatementScreen(initialPartyId: _statementPartyId);
      case 5:
        return const SettingsScreen();
      case 6:
        return const BackupScreen();
      default:
        return const SizedBox();
    }
  }
}
