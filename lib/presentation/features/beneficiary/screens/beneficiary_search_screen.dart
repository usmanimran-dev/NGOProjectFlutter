import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo/presentation/features/beneficiary/bloc/beneficiary_bloc.dart';
import 'package:demo/domain/entities/beneficiary_entity.dart';
import 'package:demo/presentation/features/beneficiary/screens/beneficiary_detail_screen.dart';
import 'package:demo/presentation/shared/responsive_layout.dart';
import 'package:demo/core/theme/app_theme.dart';

class BeneficiarySearchScreen extends StatefulWidget {
  const BeneficiarySearchScreen({super.key});

  @override
  State<BeneficiarySearchScreen> createState() => _BeneficiarySearchScreenState();
}

class _BeneficiarySearchScreenState extends State<BeneficiarySearchScreen> {
  final _cnicController = TextEditingController();

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
            title: Text('SEARCH RECORDS', style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppTheme.textMain,
            )),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 32 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Glassmorphism Search Card
                    _buildSearchCard(theme),
                    const SizedBox(height: 32),

                    // Results area
                    Expanded(
                      child: BlocBuilder<BeneficiaryBloc, BeneficiaryState>(
                        builder: (context, state) {
                          if (state is BeneficiaryLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is BeneficiaryVerified) {
                            return ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                Text('SEARCH RESULT', style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  color: AppTheme.textSecondary,
                                )),
                                const SizedBox(height: 16),
                                _buildResultCard(context, state.beneficiary),
                              ],
                            );
                          } else if (state is BeneficiaryError) {
                            return _buildErrorState(theme, state.message);
                          }

                          // Empty state
                          return _buildEmptyState(theme);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCard(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.glassDecoration(opacity: 0.9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Identity Verification', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              TextField(
                controller: _cnicController,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Enter CNIC (XXXXX-XXXXXXX-X)',
                  prefixIcon: const Icon(Icons.badge_rounded, size: 22),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                      onPressed: _onSearchPressed,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _onSearchPressed(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, BeneficiaryEntity b) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                child: Text(
                  b.name.isNotEmpty ? b.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text('CNIC: ${b.cnic}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              _buildStatusBadge(theme, b.isVerified),
            ],
          ),
          const SizedBox(height: 24),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ActionIconButton(
                  icon: Icons.assignment_ind_rounded,
                  label: 'DETAILS',
                  color: AppTheme.accentBlue,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => BeneficiaryDetailScreen(
                        beneficiaryId: b.id,
                        beneficiary: b,
                      ),
                    ));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionIconButton(
                  icon: Icons.inventory_2_rounded,
                  label: 'DISPENSE',
                  color: AppTheme.primaryGreen,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isVerified ? AppTheme.primaryGreen : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.pending_actions_rounded,
            size: 14,
            color: isVerified ? AppTheme.primaryGreen : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            isVerified ? 'VERIFIED' : 'PENDING',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: isVerified ? AppTheme.primaryGreen : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: Icon(Icons.badge_rounded, size: 48, color: Colors.grey.withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          Text('Search Registry', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Enter beneficiary CNIC to access their\nsecure records and assistance eligibility.', 
            textAlign: TextAlign.center, 
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_accounts_rounded, size: 56, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text('No Record Found', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {}, // Trigger registration flow?
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              child: const Text('ENROLL NEW BENEFICIARY'),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchPressed() {
    if (_cnicController.text.isNotEmpty) {
      context.read<BeneficiaryBloc>().add(VerifyCnicRequested(_cnicController.text.trim()));
    }
  }

  @override
  void dispose() {
    _cnicController.dispose();
    super.dispose();
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionIconButton({required this.icon, required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(letterSpacing: 1, fontSize: 13, fontWeight: FontWeight.w800)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
