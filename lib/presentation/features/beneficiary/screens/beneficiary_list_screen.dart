import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo/data/datasources/remote_data_source.dart';
import 'package:demo/data/models/beneficiary_model.dart';
import 'package:demo/injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:demo/presentation/features/auth/bloc/auth_state.dart';
import 'package:demo/domain/entities/user_entity.dart';
import 'package:demo/data/models/user_model.dart';
import 'package:demo/presentation/features/beneficiary/screens/beneficiary_registration_screen.dart';
import 'package:demo/presentation/features/beneficiary/screens/beneficiary_detail_screen.dart';
import 'package:demo/core/theme/app_theme.dart';

class BeneficiaryListScreen extends StatefulWidget {
  const BeneficiaryListScreen({super.key});

  @override
  State<BeneficiaryListScreen> createState() => _BeneficiaryListScreenState();
}

class _BeneficiaryListScreenState extends State<BeneficiaryListScreen> {
  final _remote = di.sl<RemoteDataSource>();
  List<BeneficiaryModel> _beneficiaries = [];
  bool _loading = true;
  String? _error;
  String _statusFilter = 'ALL';
  final _searchController = TextEditingController();

  final _statusOptions = ['ALL', 'PENDING', 'VERIFIED', 'APPROVED', 'REJECTED', 'SUSPENDED', 'CLOSED'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _beneficiaries = await _remote.getBeneficiaries(
        limit: 50,
        status: _statusFilter == 'ALL' ? null : _statusFilter,
      );
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED': case 'VERIFIED': return AppTheme.primaryGreen;
      case 'PENDING': return Colors.orange;
      case 'REJECTED': return Colors.redAccent;
      case 'SUSPENDED': return Colors.grey;
      case 'CLOSED': return Colors.brown;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final isStaffOrAdmin = authState is AuthAuthenticated && 
      (authState.user.role == UserRole.ngoStaff || authState.user.role == UserRole.superAdmin || authState.user.role == UserRole.ngoAdmin);

    final filtered = _searchController.text.isEmpty
        ? _beneficiaries
        : _beneficiaries.where((b) =>
            (b.name ?? '').toLowerCase().contains(_searchController.text.toLowerCase()) ||
            (b.cnic ?? '').contains(_searchController.text)).toList();

    return Stack(
      children: [
        Container(decoration: AppTheme.premiumGradient()),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('BENEFICIARY REGISTRY', style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppTheme.textMain,
            )),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by name or CNIC...',
                    prefixIcon: const Icon(Icons.person_search_rounded, size: 24),
                    fillColor: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              
              // Status Filters
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _statusOptions.length,
                  itemBuilder: (context, i) {
                    final s = _statusOptions[i];
                    final isSelected = _statusFilter == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(s, style: TextStyle(
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
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Ledger Section
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
                                  itemBuilder: (context, i) => _buildBeneficiaryTile(context, filtered[i]),
                                ),
                              ),
              ),
            ],
          ),
          floatingActionButton: isStaffOrAdmin ? FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(
                builder: (_) => const BeneficiaryRegistrationScreen(),
              ));
              if (result == true) _load();
            },
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
            label: const Text('ENROLL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            backgroundColor: AppTheme.primaryGreen,
            elevation: 8,
          ) : null,
        ),
      ],
    );
  }

  Widget _buildBeneficiaryTile(BuildContext context, BeneficiaryModel b) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(b.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
          child: Text(b.name.isNotEmpty ? b.name[0].toUpperCase() : '?',
              style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w900, fontSize: 18)),
        ),
        title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.2)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text('CNIC: ${b.cnic}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            _buildStatusBadge(b.status),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => BeneficiaryDetailScreen(beneficiaryId: b.id, beneficiary: b),
        )),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);
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
          Icon(Icons.people_rounded, size: 64, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No records match your criteria', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(_error ?? 'Network error'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _load, child: const Text('RETRY SYNC')),
        ],
      ),
    );
  }
}
