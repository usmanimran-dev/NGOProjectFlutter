import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo/data/datasources/remote_data_source.dart';
import 'package:demo/domain/entities/entitlement_entity.dart';
import 'package:demo/injection_container.dart' as di;
import 'package:demo/core/theme/app_theme.dart';

class EntitlementListScreen extends StatefulWidget {
  const EntitlementListScreen({super.key});

  @override
  State<EntitlementListScreen> createState() => _EntitlementListScreenState();
}

class _EntitlementListScreenState extends State<EntitlementListScreen> {
  final _remote = di.sl<RemoteDataSource>();
  List<EntitlementEntity> _entitlements = [];
  bool _loading = true;
  String? _error;
  String _statusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _entitlements = await _remote.getEntitlements(
        status: _statusFilter == 'ALL' ? null : _statusFilter,
      );
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'REDEEMED': return AppTheme.primaryGreen;
      case 'NOT_REDEEMED': return Colors.orange;
      case 'EXPIRED': return Colors.redAccent;
      case 'BLOCKED': return Colors.grey;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'REDEEMED': return Icons.check_circle_rounded;
      case 'NOT_REDEEMED': return Icons.pending_rounded;
      case 'EXPIRED': return Icons.timer_off_rounded;
      case 'BLOCKED': return Icons.block_flipped;
      default: return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Container(decoration: AppTheme.premiumGradient()),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('ENTITLEMENT LEDGER', style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppTheme.textMain,
            )),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horizontal Filter Chips
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: ['ALL', 'NOT_REDEEMED', 'REDEEMED', 'EXPIRED', 'BLOCKED'].map((s) {
                    final isSelected = _statusFilter == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilterChip(
                        label: Text(s.replaceAll('_', ' '), style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.w900, 
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        )),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryGreen,
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,
                        onSelected: (_) { setState(() => _statusFilter = s); _load(); },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.1)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Ledger Section
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _buildErrorPlaceholder()
                        : _entitlements.isEmpty
                            ? _buildEmptyPlaceholder(theme)
                            : RefreshIndicator(
                                onRefresh: _load,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  itemCount: _entitlements.length,
                                  itemBuilder: (context, i) => _buildEntitlementTile(context, _entitlements[i]),
                                ),
                              ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEntitlementTile(BuildContext context, EntitlementEntity e) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(e.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(_statusIcon(e.status), color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${e.beneficiaryName ?? 'Beneficiary'} • ${e.month}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.2),
                ),
                const SizedBox(height: 2),
                Text(
                  'PKR ${e.amount.toStringAsFixed(0)} • ${e.assistanceType ?? 'PROVISION'} • ${e.vendorName ?? 'N/A'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildStatusBadge(e.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildEmptyPlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_rounded, size: 64, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('No entitlements recorded', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sync_problem_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text('Ledger Sync Error: $_error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _load, child: const Text('RETRY SYNC')),
        ],
      ),
    );
  }
}
