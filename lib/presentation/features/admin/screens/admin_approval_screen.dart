import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo/presentation/features/beneficiary/bloc/beneficiary_bloc.dart';
import 'package:demo/domain/entities/beneficiary_entity.dart';
import 'package:demo/presentation/shared/responsive_layout.dart';
import 'package:demo/core/theme/app_theme.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BeneficiaryBloc>().add(LoadPendingBeneficiariesRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Stack(
      children: [
        Container(decoration: AppTheme.premiumGradient()),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('PENDING VERIFICATIONS', style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppTheme.textMain,
            )),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => context.read<BeneficiaryBloc>().add(LoadPendingBeneficiariesRequested()),
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: BlocConsumer<BeneficiaryBloc, BeneficiaryState>(
            listener: _handleStateChanges,
            builder: (context, state) {
              if (state is BeneficiaryLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is BeneficiaryLoaded) {
                final pending = state.beneficiaries;
                if (pending.isEmpty) return _buildEmptyState(theme);

                return SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? 32 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(theme, pending.length),
                      const SizedBox(height: 24),
                      ...pending.map((b) => _ApprovalCard(
                            beneficiary: b,
                            onApprove: () => _showApproveDialog(b),
                            onReject: () => _handleAction(b.id, 'REJECTED'),
                          )),
                    ],
                  ),
                );
              }

              if (state is BeneficiaryError) {
                return _buildErrorState(theme, state.message);
              }

              return _buildErrorState(theme, 'Tap refresh to load pending applications');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(ThemeData theme, int count) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: AppTheme.glassDecoration(opacity: 0.8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.pending_actions_rounded, color: Colors.orange, size: 22),
              ),
              const SizedBox(width: 16),
              Text('$count APPLICATIONS AWAITING REVIEW', 
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
            ),
            child: const Icon(Icons.verified_rounded, size: 64, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 24),
          Text('Registry Verified', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('No new beneficiary applications found.', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<BeneficiaryBloc>().add(LoadPendingBeneficiariesRequested()),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('RETRY SYNC', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStateChanges(BuildContext context, BeneficiaryState state) {
    if (state is BeneficiaryStatusUpdated) {
      final status = state.beneficiary.status.toUpperCase();
      _showSuccess(context, 'Application ${status == 'APPROVED' ? "Approved" : "Rejected"} successfully');
      // Reload the pending list
      context.read<BeneficiaryBloc>().add(LoadPendingBeneficiariesRequested());
    } else if (state is BeneficiaryError) {
      _showError(context, state.message);
    }
  }

  void _showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
      backgroundColor: AppTheme.primaryGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _handleAction(String id, String status) {
    context.read<BeneficiaryBloc>().add(UpdateBeneficiaryStatusRequested(id, status));
  }

  void _showApproveDialog(BeneficiaryEntity b) {
    String selectedType = 'RATION';
    final amountCtrl = TextEditingController(text: '5000');
    final durationCtrl = TextEditingController(text: '12');
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Assign Assistance for ${b.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Assistance Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'RATION', child: Text('RATION')),
                    DropdownMenuItem(value: 'RENT', child: Text('RENT')),
                    DropdownMenuItem(value: 'MEDICAL', child: Text('MEDICAL')),
                    DropdownMenuItem(value: 'MARRIAGE', child: Text('MARRIAGE')),
                    DropdownMenuItem(value: 'EMERGENCY', child: Text('EMERGENCY')),
                  ],
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Amount (PKR)', 
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: durationCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (Months)', 
                    prefixIcon: Icon(Icons.calendar_month),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                context.read<BeneficiaryBloc>().add(UpdateBeneficiaryStatusRequested(
                  b.id, 'APPROVED',
                  assistanceData: {
                    'assistance_type': selectedType,
                    'monthly_amount': double.tryParse(amountCtrl.text.trim()) ?? 0,
                    'duration_months': int.tryParse(durationCtrl.text.trim()) ?? 12,
                    'start_month': DateTime.now().toIso8601String(),
                  },
                ));
              },
              child: const Text('APPROVE & ASSIGN', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final BeneficiaryEntity beneficiary;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalCard({required this.beneficiary, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                child: Text(beneficiary.name.isNotEmpty ? beneficiary.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primaryGreen)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(beneficiary.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.2)),
                    const SizedBox(height: 2),
                    Text('CNIC: ${beneficiary.cnic}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const _StatusBadge(label: 'PENDING', color: Colors.orange),
            ],
          ),

          const SizedBox(height: 16),

          // Detail chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (beneficiary.fatherOrHusbandName != null)
                _DetailChip(icon: Icons.person_outline, label: beneficiary.fatherOrHusbandName!),
              if (beneficiary.mobile != null)
                _DetailChip(icon: Icons.phone_outlined, label: beneficiary.mobile!),
              if (beneficiary.city != null)
                _DetailChip(icon: Icons.location_city_outlined, label: '${beneficiary.city}${beneficiary.area != null ? ' / ${beneficiary.area}' : ''}'),
              if (beneficiary.createdByName != null)
                _DetailChip(icon: Icons.badge_outlined, label: 'By: ${beneficiary.createdByName}'),
              if (beneficiary.createdAt != null)
                _DetailChip(icon: Icons.calendar_today_outlined, label: '${beneficiary.createdAt!.day}/${beneficiary.createdAt!.month}/${beneficiary.createdAt!.year}'),
            ],
          ),

          if (beneficiary.address != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.home_outlined, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(beneficiary.address!, 
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('REJECT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('APPROVE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }
}
