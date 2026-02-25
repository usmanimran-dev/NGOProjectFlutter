import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:demo/presentation/features/auth/bloc/auth_state.dart';
import 'package:demo/domain/entities/user_entity.dart';
import 'package:demo/presentation/features/beneficiary/screens/beneficiary_search_screen.dart';
import 'package:demo/presentation/features/reports/bloc/report_bloc.dart';
import 'package:demo/presentation/shared/responsive_layout.dart';
import 'package:demo/domain/entities/report_summary_entity.dart';
import 'package:demo/core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          return Stack(
            children: [
              Container(decoration: AppTheme.premiumGradient()),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: _buildAppBar(context, user),
                body: (user.role == UserRole.superAdmin || user.role == UserRole.ngoAdmin)
                    ? _AdminDashboard(user: user)
                    : user.role == UserRole.ngoStaff
                        ? _StaffDashboard(user: user)
                        : _VendorDashboard(user: user),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, UserEntity user) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DASHBOARD', style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppTheme.primaryGreen,
          )),
          Text(user.role.name.toUpperCase(), style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
          )),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textMain),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
          child: Text(user.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

// ═══════════════════════════════
// ║       ADMIN DASHBOARD       ║
// ═══════════════════════════════
class _AdminDashboard extends StatelessWidget {
  final UserEntity user;
  const _AdminDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        if (state is ReportInitial) {
          context.read<ReportBloc>().add(GetMonthlySummaryRequested(DateTime.now().year, DateTime.now().month));
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ReportLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ReportError) {
          return _ErrorState(
            message: state.message,
            onRetry: () => context.read<ReportBloc>().add(
              GetMonthlySummaryRequested(DateTime.now().year, DateTime.now().month)
            ),
          );
        }
        if (state is ReportLoaded) {
          final s = state.summary;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WelcomeCard(name: user.name, role: 'System Administrator'),
                const SizedBox(height: 32),

                Text('LATEST ANALYTICS', style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: AppTheme.textSecondary,
                )),
                const SizedBox(height: 16),

                _StatGrid(summary: s),
                const SizedBox(height: 32),

                Text('FINANCIAL PERFORMANCE', style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: AppTheme.textSecondary,
                )),
                const SizedBox(height: 16),

                _FinancialCard(summary: s),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

// ═══════════════════════════════
// ║       STAFF DASHBOARD       ║
// ═══════════════════════════════
class _StaffDashboard extends StatelessWidget {
  final UserEntity user;
  const _StaffDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeCard(name: user.name, role: 'Field Operations Staff'),
              const SizedBox(height: 32),

              if (state is ReportLoaded) ...[
                _StatGrid(summary: state.summary, isStaff: true),
                const SizedBox(height: 32),
              ],

              Text('QUICK ACTIONS', style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: AppTheme.textSecondary,
              )),
              const SizedBox(height: 16),
              
              _PremiumActionCard(
                icon: Icons.person_add_rounded,
                title: 'New Enrollment',
                subtitle: 'Verify CNIC and register beneficiary',
                color: AppTheme.primaryGreen,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeneficiarySearchScreen())),
              ),
              const SizedBox(height: 16),
              _PremiumActionCard(
                icon: Icons.manage_search_rounded,
                title: 'Beneficiary Audit',
                subtitle: 'Review history and verification status',
                color: AppTheme.accentBlue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeneficiarySearchScreen())),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════
// ║       VENDOR DASHBOARD      ║
// ═══════════════════════════════
class _VendorDashboard extends StatelessWidget {
  final UserEntity user;
  const _VendorDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeCard(name: user.name, role: 'Official Service Provider'),
          const SizedBox(height: 40),
          
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
                    decoration: AppTheme.glassDecoration(opacity: 0.8),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.qr_code_scanner_rounded, size: 64, color: AppTheme.primaryGreen),
                        ),
                        const SizedBox(height: 24),
                        Text('VERIFY & REDEEM', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1)),
                        const SizedBox(height: 8),
                        Text('Scan QR or process ID to record delivery', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.flash_on_rounded),
                            label: const Text('START SCANNING'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════
// ║       SUPPORT WIDGETS       ║
// ═══════════════════════════════

class _WelcomeCard extends StatelessWidget {
  final String name;
  final String role;
  const _WelcomeCard({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: AppTheme.glassDecoration(opacity: 0.9).copyWith(
            gradient: LinearGradient(
              colors: [AppTheme.primaryGreen.withOpacity(0.1), Colors.white.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back,', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                        const SizedBox(height: 4),
                        Text(name, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(role.toUpperCase(), style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final ReportSummaryEntity summary;
  final bool isStaff;
  const _StatGrid({required this.summary, this.isStaff = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isStaff ? 2 : (constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1));
        final width = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
        
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _AnimatedStatTile(
              width: width,
              icon: Icons.people_rounded,
              label: 'BENEFICIARIES',
              value: summary.totalBeneficiaries.toString(),
              color: AppTheme.accentBlue,
            ),
            _AnimatedStatTile(
              width: width,
              icon: Icons.check_circle_rounded,
              label: 'DELIVERED',
              value: summary.totalRedeemed.toString(),
              color: AppTheme.primaryGreen,
            ),
            _AnimatedStatTile(
              width: width,
              icon: Icons.access_time_filled_rounded,
              label: 'PENDING',
              value: summary.pendingRedemption.toString(),
              color: Colors.orange,
            ),
            if (!isStaff)
              _AnimatedStatTile(
                width: width,
                icon: Icons.payments_rounded,
                label: 'TOTAL BUDGET',
                value: '₨ ${summary.totalAmount}',
                color: AppTheme.deepGreen,
              ),
          ],
        );
      },
    );
  }
}

class _AnimatedStatTile extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _AnimatedStatTile({required this.width, required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 20),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: AppTheme.textMain)),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final ReportSummaryEntity summary;
  const _FinancialCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          _FinancialRow(label: 'Total Allocation', value: '₨ ${summary.totalAmount}', isBold: true),
          _divider(),
          _FinancialRow(label: 'Processed & Delivered', value: '₨ ${summary.redeemedAmount}', color: AppTheme.primaryGreen),
          _divider(),
          _FinancialRow(label: 'Awaiting Redemption', value: '₨ ${summary.pendingAmount}', color: Colors.orange),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              ),
              FractionallySizedBox(
                widthFactor: 0.7, // Mocked rate
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.secondaryGreen, AppTheme.primaryGreen]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Progress', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(summary.redemptionRate, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w900, color: AppTheme.primaryGreen)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Divider(height: 1, color: Colors.grey.withAlpha(20)),
  );
}

class _FinancialRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;
  const _FinancialRow({required this.label, required this.value, this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
          color: color ?? AppTheme.textMain,
          fontSize: isBold ? 18 : 16,
        )),
      ],
    );
  }
}

class _PremiumActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _PremiumActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Sync Interrupted', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: const Text('RETRY SYNC')),
        ],
      ),
    );
  }
}
