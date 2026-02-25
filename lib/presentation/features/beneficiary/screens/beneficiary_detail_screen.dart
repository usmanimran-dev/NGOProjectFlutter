import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo/domain/entities/beneficiary_entity.dart';
import 'package:demo/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:demo/presentation/features/auth/bloc/auth_state.dart';
import 'package:demo/domain/entities/user_entity.dart';
import 'package:demo/presentation/features/beneficiary/bloc/beneficiary_bloc.dart';
import 'package:demo/data/models/user_model.dart';
import 'package:intl/intl.dart';

class BeneficiaryDetailScreen extends StatelessWidget {
  final String beneficiaryId;
  final BeneficiaryEntity beneficiary;

  const BeneficiaryDetailScreen({super.key, required this.beneficiaryId, required this.beneficiary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final isVerifier = authState is AuthAuthenticated && authState.user.role == UserRole.fieldVerifier;
    final isPending = beneficiary.status.toUpperCase() == 'PENDING';
    
    return Stack(
      children: [
        Container(decoration: AppTheme.premiumGradient()),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('BENEFICIARY PROFILE', style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppTheme.textMain,
            )),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Profile Glass Card ──
                _buildProfileHeader(theme),
                const SizedBox(height: 24),

                // ── Information Sections ──
                _buildSectionTitle(theme, 'IDENTITY & CONTACT'),
                _buildInfoCard(theme, [
                  _InfoRow(icon: Icons.badge_rounded, label: 'CNIC', value: beneficiary.cnic, isHighlight: true),
                  if (beneficiary.fatherOrHusbandName != null)
                    _InfoRow(icon: Icons.person_outline_rounded, label: 'Relative', value: beneficiary.fatherOrHusbandName!),
                  _InfoRow(icon: Icons.phone_android_rounded, label: 'Mobile', value: beneficiary.mobile ?? 'Not Provided'),
                  _InfoRow(icon: Icons.location_on_rounded, label: 'Address', value: '${beneficiary.address ?? ""}, ${beneficiary.city ?? ""}'),
                ]),
                
                const SizedBox(height: 32),
                _buildSectionTitle(theme, 'ASSISTANCE HISTORY'),
                _buildAssistanceList(theme),

                const SizedBox(height: 32),
                _buildSectionTitle(theme, 'SYSTEM METADATA'),
                _buildInfoCard(theme, [
                  _InfoRow(icon: Icons.history_rounded, label: 'Enrolled On', value: beneficiary.createdAt != null ? DateFormat('MMMM dd, yyyy').format(beneficiary.createdAt!) : 'N/A'),
                  _InfoRow(icon: Icons.verified_user_rounded, label: 'Staff Agent', value: beneficiary.createdByName ?? 'Field Agent'),
                ]),
                const SizedBox(height: 40),
                if (isVerifier && isPending) ...[
                  _buildSectionTitle(theme, 'FIELD VERIFICATION'),
                  _buildVerifierActions(context),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifierActions(BuildContext context) {
    return BlocConsumer<BeneficiaryBloc, BeneficiaryState>(
      listener: (context, state) {
        if (state is BeneficiaryStatusUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Status updated to ${state.beneficiary.status}', style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: AppTheme.primaryGreen,
          ));
          Navigator.pop(context, true); // Go back and refresh list
        } else if (state is BeneficiaryError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${state.message}'),
            backgroundColor: Colors.redAccent,
          ));
        }
      },
      builder: (context, state) {
        if (state is BeneficiaryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.read<BeneficiaryBloc>().add(UpdateBeneficiaryStatusRequested(beneficiaryId, 'REJECTED')),
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text('REJECT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.read<BeneficiaryBloc>().add(UpdateBeneficiaryStatusRequested(beneficiaryId, 'VERIFIED')),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('MARK VERIFIED', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: AppTheme.glassDecoration(opacity: 0.9),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                child: Text(
                  beneficiary.name.isNotEmpty ? beneficiary.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 36, color: AppTheme.primaryGreen, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 16),
              Text(beneficiary.name, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              _buildStatusBadge(beneficiary.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        color: AppTheme.textSecondary,
      )),
    );
  }

  Widget _buildInfoCard(ThemeData theme, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAssistanceList(ThemeData theme) {
    if (beneficiary.assistanceCases == null || beneficiary.assistanceCases!.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, color: Colors.grey.withOpacity(0.3), size: 40),
            const SizedBox(height: 12),
            const Text('No Active Assistance Cases', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return Column(
      children: beneficiary.assistanceCases!.map((c) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.volunteer_activism_rounded, color: AppTheme.primaryGreen, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.assistanceType.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  Text('Provisioned by ${c.vendorName ?? "Assigned Vendor"}', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₨ ${c.monthlyAmount}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryGreen)),
                Text(c.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c.status == 'ACTIVE' ? Colors.green : Colors.grey)),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'APPROVED' || status == 'VERIFIED') color = AppTheme.primaryGreen;
    if (status == 'PENDING') color = Colors.orange;
    if (status == 'REJECTED') color = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlight;
  const _InfoRow({required this.icon, required this.label, required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isHighlight ? AppTheme.primaryGreen : AppTheme.textSecondary.withOpacity(0.6)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary.withOpacity(0.6), letterSpacing: 0.5)),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w600, color: AppTheme.textMain)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
