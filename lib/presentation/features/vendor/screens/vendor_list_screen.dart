import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo/data/datasources/remote_data_source.dart';
import 'package:demo/domain/entities/vendor_entity.dart';
import 'package:demo/injection_container.dart' as di;
import 'package:demo/core/theme/app_theme.dart';
import 'package:demo/presentation/features/vendor/screens/vendor_registration_screen.dart';

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({super.key});

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  final _remote = di.sl<RemoteDataSource>();
  List<VendorEntity> _vendors = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _vendors = await _remote.getVendors();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
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
            title: Text('DISTRIBUTION PARTNERS', style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppTheme.textMain,
            )),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorPlaceholder()
                  : _vendors.isEmpty
                      ? _buildEmptyPlaceholder(theme)
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: _vendors.length,
                            itemBuilder: (context, i) => _buildVendorTile(context, _vendors[i]),
                          ),
                        ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(
                builder: (_) => const VendorRegistrationScreen(),
              ));
              if (result == true) _load();
            },
            icon: const Icon(Icons.add_business_rounded, color: Colors.white),
            label: const Text('REGISTER PARTNER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
            backgroundColor: AppTheme.primaryGreen,
            elevation: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildVendorTile(BuildContext context, VendorEntity v) {
    final theme = Theme.of(context);
    final isActive = v.status.toUpperCase() == 'ACTIVE';
    final statusColor = isActive ? AppTheme.primaryGreen : Colors.grey;

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
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.storefront_rounded, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.2)),
                    const SizedBox(height: 2),
                    Text('${v.city}${v.area != null ? ' · ${v.area}' : ''}', 
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              _buildStatusBadge(v.status),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.withAlpha(20)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.phone_rounded, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(v.contactNumber ?? 'No contact', style: const TextStyle(fontSize: 12, color: AppTheme.textMain, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.map_rounded, size: 14),
                label: const Text('VIEW LOCATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                style: TextButton.styleFrom(foregroundColor: AppTheme.accentBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status.toUpperCase() == 'ACTIVE';
    final color = isActive ? AppTheme.primaryGreen : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  Widget _buildEmptyPlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.business_rounded, size: 64, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No distribution partners found', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
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
          Text(_error ?? 'Network error'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _load, child: const Text('RETRY SYNC')),
        ],
      ),
    );
  }
}
