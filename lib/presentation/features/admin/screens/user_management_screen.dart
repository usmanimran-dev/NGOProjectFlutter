import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo/data/datasources/remote_data_source.dart';
import 'package:demo/data/models/user_model.dart';
import 'package:demo/injection_container.dart' as di;
import 'package:demo/core/theme/app_theme.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _remote = di.sl<RemoteDataSource>();
  List<UserModel> _users = [];
  bool _loading = true;
  String? _error;
  String _roleFilter = 'ALL';

  final _roles = ['SUPER_ADMIN', 'NGO_ADMIN', 'NGO_STAFF', 'VENDOR_ADMIN', 'VENDOR_USER', 'FIELD_VERIFIER'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _users = await _remote.getUsers(role: _roleFilter == 'ALL' ? null : _roleFilter);
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'NGO_ADMIN': case 'SUPER_ADMIN': return Colors.purple;
      case 'NGO_STAFF': return AppTheme.primaryGreen;
      case 'VENDOR_ADMIN': case 'VENDOR_USER': return AppTheme.accentBlue;
      case 'FIELD_VERIFIER': return Colors.orange;
      default: return Colors.grey;
    }
  }

  // ── Staff Enrollment Dialog ──
  void _showEnrollDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'NGO_STAFF';
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: EdgeInsets.only(
              left: 28, right: 28, top: 28,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person_add_rounded, color: AppTheme.primaryGreen, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text('ENROLL NEW STAFF', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildField(nameCtrl, 'Full Name', Icons.person_rounded),
                  const SizedBox(height: 14),
                  _buildField(emailCtrl, 'Email Address', Icons.email_rounded),
                  const SizedBox(height: 14),
                  _buildField(passCtrl, 'Password', Icons.lock_rounded, obscure: true),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: const Icon(Icons.badge_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: ['NGO_STAFF', 'VENDOR_ADMIN', 'FIELD_VERIFIER']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.replaceAll('_', ' '), style: const TextStyle(fontSize: 14))))
                      .toList(),
                    onChanged: (v) => setModalState(() => selectedRole = v!),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: submitting ? null : () async {
                        if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('All fields are required'),
                            backgroundColor: Colors.redAccent,
                          ));
                          return;
                        }
                        setModalState(() => submitting = true);
                        try {
                          await _remote.createUser({
                            'full_name': nameCtrl.text.trim(),
                            'email': emailCtrl.text.trim(),
                            'password': passCtrl.text,
                            'role': selectedRole,
                          });
                          if (mounted) Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${nameCtrl.text} enrolled successfully!'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                            backgroundColor: AppTheme.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ));
                          _load();
                        } catch (e) {
                          setModalState(() => submitting = false);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.redAccent,
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: submitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('ENROLL', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
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
            title: Text('STAFF & PERMISSIONS', style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppTheme.textMain,
            )),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: ['ALL', ..._roles].map((r) {
                    final isSelected = _roleFilter == r;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilterChip(
                        label: Text(r.replaceAll('_', ' '), style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        )),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryGreen,
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,
                        onSelected: (_) { setState(() => _roleFilter = r); _load(); },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.1)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _buildErrorPlaceholder()
                        : _users.isEmpty
                            ? _buildEmptyPlaceholder(theme)
                            : RefreshIndicator(
                                onRefresh: _load,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  itemCount: _users.length,
                                  itemBuilder: (context, i) => _buildUserTile(context, _users[i]),
                                ),
                              ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showEnrollDialog,
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            label: const Text('ENROLL STAFF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
            backgroundColor: AppTheme.primaryGreen,
            elevation: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel u) {
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
          CircleAvatar(
            radius: 24,
            backgroundColor: _roleColor(u.roleName).withOpacity(0.1),
            child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                style: TextStyle(color: _roleColor(u.roleName), fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                Text(u.email, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          _buildRoleBadge(u.roleName),
          const SizedBox(width: 8),
          Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey.withOpacity(0.4)),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _roleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(role.replaceAll('_', ' '), style: TextStyle(
          fontSize: 9, color: _roleColor(role), fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sync_problem_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text('Syncing error: $_error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _load, child: const Text('RETRY SYNC')),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 64, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('No personnel found in this division', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}
