import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo/data/datasources/remote_data_source.dart';
import 'package:demo/domain/entities/assistance_case_entity.dart';
import 'package:demo/domain/entities/vendor_entity.dart';
import 'package:demo/injection_container.dart' as di;
import 'package:demo/core/theme/app_theme.dart';

class AssistanceCaseScreen extends StatefulWidget {
  const AssistanceCaseScreen({super.key});

  @override
  State<AssistanceCaseScreen> createState() => _AssistanceCaseScreenState();
}

class _AssistanceCaseScreenState extends State<AssistanceCaseScreen> {
  final _remote = di.sl<RemoteDataSource>();
  List<AssistanceCaseEntity> _cases = [];
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
      _cases = await _remote.getAssistanceCases(
        status: _statusFilter == 'ALL' ? null : _statusFilter,
      );
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'RATION': return AppTheme.primaryGreen;
      case 'RENT': return AppTheme.accentBlue;
      case 'MEDICAL': return Colors.redAccent;
      case 'EMERGENCY': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'RATION': return Icons.shopping_bag_rounded;
      case 'RENT': return Icons.home_work_rounded;
      case 'MEDICAL': return Icons.medical_services_rounded;
      case 'EMERGENCY': return Icons.notification_important_rounded;
      default: return Icons.help_center_rounded;
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
            title: Text('ASSISTANCE REGISTRY', style: theme.textTheme.titleSmall?.copyWith(
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
                  children: ['ALL', 'ACTIVE', 'PAUSED', 'CLOSED'].map((s) {
                    final isSelected = _statusFilter == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilterChip(
                        label: Text(s, style: TextStyle(
                          fontSize: 11, 
                          fontWeight: FontWeight.w900, 
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          letterSpacing: 1,
                        )),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryGreen,
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,
                        onSelected: (_) { setState(() => _statusFilter = s); _load(); },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.1)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Cases List Section
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _buildErrorPlaceholder()
                        : _cases.isEmpty
                            ? _buildEmptyPlaceholder(theme)
                            : RefreshIndicator(
                                onRefresh: _load,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  itemCount: _cases.length,
                                  itemBuilder: (context, i) => _buildCaseTile(context, _cases[i]),
                                ),
                              ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {}, // Implementation later
            icon: const Icon(Icons.add_task_rounded, color: Colors.white),
            label: const Text('NEW PROVISION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
            backgroundColor: AppTheme.primaryGreen,
            elevation: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildCaseTile(BuildContext context, AssistanceCaseEntity c) {
    final theme = Theme.of(context);
    final typeColor = _typeColor(c.assistanceType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(_typeIcon(c.assistanceType), color: typeColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.assistanceType.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(c.beneficiaryName ?? 'Unknown Beneficiary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                  ],
                ),
              ),
              _buildStatusBadge(c.status),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.withAlpha(20)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MONTHLY ALLOWANCE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textSecondary.withOpacity(0.5), letterSpacing: 0.5)),
                  Text('₨ ${c.monthlyAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primaryGreen)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('ASSIGNED PARTNER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textSecondary.withOpacity(0.5), letterSpacing: 0.5)),
                  Text(c.vendorName ?? 'Awaiting Vendor', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textMain)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'ACTIVE') color = AppTheme.primaryGreen;
    if (status == 'PAUSED') color = Colors.orange;
    if (status == 'CLOSED') color = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  Widget _buildEmptyPlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('No assistance cases documented', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
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
          Text('Registry Sync Error: $_error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _load, child: const Text('RETRY SYNC')),
        ],
      ),
    );
  }
}
