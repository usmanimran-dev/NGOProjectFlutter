import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:demo/presentation/features/auth/bloc/auth_event.dart';
import 'package:demo/presentation/features/auth/bloc/auth_state.dart';
import 'package:demo/presentation/shared/responsive_layout.dart';
import 'package:demo/presentation/features/admin/screens/admin_approval_screen.dart';
import 'package:demo/presentation/features/beneficiary/screens/beneficiary_list_screen.dart';
import 'package:demo/presentation/features/assistance/screens/assistance_case_screen.dart';
import 'package:demo/presentation/features/vendor/screens/vendor_list_screen.dart';
import 'package:demo/presentation/features/entitlement/screens/entitlement_list_screen.dart';
import 'package:demo/presentation/features/admin/screens/user_management_screen.dart';
import 'package:demo/presentation/features/reports/screens/report_dashboard_screen.dart';
import 'package:demo/presentation/features/admin/screens/audit_log_screen.dart';
import 'package:demo/core/theme/app_theme.dart';
import 'package:demo/domain/entities/user_entity.dart';

class MainShell extends StatefulWidget {
  final Widget body;
  final String title;

  const MainShell({
    super.key,
    required this.body,
    required this.title,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  void _showWelcomeDialog() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      final user = state.user;
      final roleColor = _getRoleColor(user.role);
      final roleIcon = _getRoleIcon(user.role);
      final roleName = _getRoleName(user.role);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(roleIcon, color: roleColor, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome, ${user.name}!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              const SizedBox(height: 12),
              Text(
                'You have successfully logged in as\n$roleName.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: roleColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('CONTINUE TO PORTAL', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Color _getRoleColor(dynamic role) {
    final roleStr = role.toString().toLowerCase();
    if (roleStr.contains('admin')) return AppTheme.accentBlue;
    if (roleStr.contains('staff')) return AppTheme.primaryGreen;
    if (roleStr.contains('vendor')) return Colors.teal;
    return AppTheme.primaryGreen;
  }

  IconData _getRoleIcon(dynamic role) {
    final roleStr = role.toString().toLowerCase();
    if (roleStr.contains('admin')) return Icons.admin_panel_settings_rounded;
    if (roleStr.contains('staff')) return Icons.badge_rounded;
    if (roleStr.contains('vendor')) return Icons.storefront_rounded;
    return Icons.person_rounded;
  }

  String _getRoleName(dynamic role) {
    final roleStr = role.toString().split('.').last.toUpperCase().replaceAll('_', ' ');
    return roleStr;
  }

  // ── All possible nav items with screen indices ──
  static const _allNavItems = [
    _NavItem(Icons.grid_view_rounded, 'DASHBOARD', 0),
    _NavItem(Icons.people_alt_rounded, 'BENEFICIARIES', 1),
    _NavItem(Icons.volunteer_activism_rounded, 'ASSISTANCE', 2),
    _NavItem(Icons.storefront_rounded, 'PARTNERS', 3),
    _NavItem(Icons.account_balance_wallet_rounded, 'ENTITLEMENTS', 4),
    _NavItem(Icons.verified_user_rounded, 'APPROVALS', 5),
    _NavItem(Icons.admin_panel_settings_rounded, 'PERSONNEL', 6),
    _NavItem(Icons.analytics_rounded, 'ANALYTICS', 7),
    _NavItem(Icons.history_edu_rounded, 'AUDIT LOGS', 8),
  ];

  /// Returns nav items filtered by the current user's role
  /// Based on NGO Assistance Management System role diagram:
  /// - NGO Staff: Register Beneficiaries, Upload Docs, Manage Verification, Assign Vendors, Monitor Cycles, Reports
  /// - NGO Admin: Approve Beneficiaries, Define Assistance, Manage Roles, Onboard Vendors, Audit
  /// - Vendor: View Assigned Beneficiaries, Verify Identity, Mark Delivered
  /// - Field Verifier: Perform Verification, Upload Notes
  List<_NavItem> get _navItems {
    final state = context.read<AuthBloc>().state;
    if (state is! AuthAuthenticated) return _allNavItems;
    final role = state.user.role;
    switch (role) {
      case UserRole.ngoStaff:
        // Staff: Dashboard, Beneficiaries (register), Assistance, Entitlements, Analytics
        return _allNavItems.where((item) =>
          item.screenIndex == 0 || // Dashboard
          item.screenIndex == 1 || // Beneficiaries (register & manage)
          item.screenIndex == 2 || // Assistance (manage cases)
          item.screenIndex == 4 || // Entitlements (monitor cycles)
          item.screenIndex == 7    // Analytics (reports)
        ).toList();
      case UserRole.vendorAdmin:
      case UserRole.vendorUser:
        // Vendor: Dashboard, Beneficiaries (assigned only), Analytics (own store report)
        return _allNavItems.where((item) =>
          item.screenIndex == 0 || // Dashboard
          item.screenIndex == 1 || // Beneficiaries (assigned)
          item.screenIndex == 7    // Analytics (own store)
        ).toList();
      case UserRole.fieldVerifier:
        // Field Verifier: Dashboard, Beneficiaries (verification)
        return _allNavItems.where((item) =>
          item.screenIndex == 0 || // Dashboard
          item.screenIndex == 1    // Beneficiaries (verify)
        ).toList();
      default:
        // Admin / Super Admin: ALL items (approve, manage roles, onboard vendors, audit)
        return _allNavItems;
    }
  }

  Widget get _currentBody {
    final items = _navItems;
    if (_selectedIndex >= items.length) {
      return widget.body;
    }
    final screenIndex = items[_selectedIndex].screenIndex;
    switch (screenIndex) {
      case 0: return widget.body;
      case 1: return const BeneficiaryListScreen();
      case 2: return const AssistanceCaseScreen();
      case 3: return const VendorListScreen();
      case 4: return const EntitlementListScreen();
      case 5: return const AdminApprovalScreen();
      case 6: return const UserManagementScreen();
      case 7: return const ReportDashboardScreen();
      case 8: return const AuditLogScreen();
      default: return widget.body;
    }
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
          body: ResponsiveLayout(
            mobile: (context) => _buildMobileLayout(theme),
            desktop: (context) => _buildDesktopLayout(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    final items = _navItems;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(items[_selectedIndex < items.length ? _selectedIndex : 0].label, style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w900, 
          letterSpacing: 1.5,
          color: AppTheme.textMain,
        )),
        actions: [_UserAvatarButton(onLogout: _logout)],
      ),
      body: _currentBody,
      drawer: _buildDrawer(theme),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return Row(
      children: [
        // ── Premium Sidebar ──
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 280,
              decoration: AppTheme.glassDecoration(opacity: 0.8).copyWith(
                borderRadius: BorderRadius.zero,
                border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Column(
                children: [
                  _buildSidebarHeader(theme),
                  const SizedBox(height: 24),
                  Expanded(child: _buildNavList(theme)),
                  _buildSidebarFooter(theme),
                ],
              ),
            ),
          ),
        ),
        
        // ── Content Area ──
        Expanded(
          child: Column(
            children: [
              _buildTopBar(theme),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentBody,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.2), blurRadius: 15)],
            ),
            child: const Icon(Icons.volunteer_activism_rounded, color: AppTheme.primaryGreen, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NGO', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1, color: AppTheme.deepGreen)),
              Text('COMPASSION', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 2, color: AppTheme.primaryGreen)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavList(ThemeData theme) {
    final items = _navItems;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final isSelected = _selectedIndex == i;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _selectedIndex = i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(item.icon, size: 22, color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary),
                    const SizedBox(width: 16),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isSelected ? AppTheme.primaryGreen : AppTheme.textMain,
                      ),
                    ),
                    if (isSelected) ...[
                      const Spacer(),
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebarFooter(ThemeData theme) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                child: Text(user?.name[0] ?? '?', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryGreen)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? 'Loading...', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.2)),
                    Text(user?.email ?? '', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              IconButton(onPressed: _logout, icon: const Icon(Icons.logout_rounded, size: 20, color: AppTheme.textSecondary)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Row(
        children: [
          Text(_navItems[_selectedIndex < _navItems.length ? _selectedIndex : 0].label, style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900, 
            letterSpacing: -1,
            color: AppTheme.textMain,
          )),
          const Spacer(),
          _GreetingWidget(),
        ],
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildSidebarHeader(theme),
          const Divider(),
          Expanded(child: _buildNavList(theme)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('SIGN OUT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: Colors.redAccent)),
            onTap: _logout,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _logout() {
    context.read<AuthBloc>().add(LogoutRequested());
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int screenIndex;
  const _NavItem(this.icon, this.label, this.screenIndex);
}

class _GreetingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'GOOD MORNING';
    IconData icon = Icons.wb_twilight_rounded;
    if (hour >= 12 && hour < 17) {
      greeting = 'GOOD AFTERNOON';
      icon = Icons.wb_sunny_rounded;
    } else if (hour >= 17) {
      greeting = 'GOOD EVENING';
      icon = Icons.nightlight_round_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.orangeAccent),
          const SizedBox(width: 8),
          Text(greeting, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _UserAvatarButton extends StatelessWidget {
  final VoidCallback onLogout;
  const _UserAvatarButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
        child: const Icon(Icons.person_rounded, size: 18, color: AppTheme.primaryGreen),
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    onLogout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
