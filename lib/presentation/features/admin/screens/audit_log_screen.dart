import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo/data/datasources/remote_data_source.dart';
import 'package:demo/domain/entities/audit_log_entity.dart';
import 'package:demo/injection_container.dart' as di;
import 'package:intl/intl.dart';
import 'package:demo/core/theme/app_theme.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final _remote = di.sl<RemoteDataSource>();
  List<AuditLogEntity> _logs = [];
  bool _loading = true;
  String? _error;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _logs = await _remote.getAuditLogs(limit: 100);
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Color _actionColor(String action) {
    final a = action.toUpperCase();
    if (a.contains('CREATE') || a.contains('POST')) return AppTheme.primaryGreen;
    if (a.contains('UPDATE') || a.contains('PUT')) return AppTheme.accentBlue;
    if (a.contains('DELETE')) return Colors.redAccent;
    if (a.contains('LOGIN')) return Colors.deepPurpleAccent;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _searchController.text.isEmpty
        ? _logs
        : _logs.where((l) =>
            (l.action ?? '').toLowerCase().contains(_searchController.text.toLowerCase()) ||
            (l.entity ?? '').toLowerCase().contains(_searchController.text.toLowerCase()) ||
            (l.userName ?? '').toLowerCase().contains(_searchController.text.toLowerCase())).toList();

    return Stack(
      children: [
        Container(decoration: AppTheme.premiumGradient()),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('SECURITY AUDIT LOGS', style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppTheme.textMain,
            )),
          ),
          body: Column(
            children: [
              // Search Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search actions, entities, or users...',
                    prefixIcon: const Icon(Icons.manage_search_rounded, size: 24),
                    fillColor: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),

              // Results Area
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _buildErrorPlaceholder()
                        : filtered.isEmpty
                            ? _buildEmptyPlaceholder(theme)
                            : RefreshIndicator(
                                onRefresh: _load,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, i) => _buildLogTile(context, filtered[i]),
                                ),
                              ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogTile(BuildContext context, AuditLogEntity log) {
    final theme = Theme.of(context);
    final timeStr = log.createdAt != null ? DateFormat('MMM dd • HH:mm:ss').format(log.createdAt!) : 'N/A';
    final accentColor = _actionColor(log.action);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(log.action.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 0.5)),
                          ),
                          Text(timeStr, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary.withOpacity(0.5))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textMain, height: 1.4),
                          children: [
                            TextSpan(text: log.userName ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.w900)),
                            const TextSpan(text: ' performed action on '),
                            TextSpan(text: log.entity, style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.accentBlue)),
                            if (log.entityId != null) 
                              TextSpan(text: ' (ID: ${log.entityId})', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.shield_rounded, size: 12, color: AppTheme.textSecondary.withOpacity(0.4)),
                          const SizedBox(width: 4),
                          Text(log.role.replaceAll('_', ' '), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary.withOpacity(0.4))),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('No security logs recorded', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('Failed to retrieve audit trail'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _load, child: const Text('RETRY LOAD')),
        ],
      ),
    );
  }
}
