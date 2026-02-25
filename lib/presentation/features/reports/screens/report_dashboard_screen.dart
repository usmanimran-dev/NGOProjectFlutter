import 'package:flutter/material.dart';
import 'package:demo/data/datasources/remote_data_source.dart';
import 'package:demo/injection_container.dart' as di;
import 'package:demo/core/theme/app_theme.dart';

class ReportDashboardScreen extends StatefulWidget {
  const ReportDashboardScreen({super.key});

  @override
  State<ReportDashboardScreen> createState() => _ReportDashboardScreenState();
}

class _ReportDashboardScreenState extends State<ReportDashboardScreen> {
  final _remote = di.sl<RemoteDataSource>();
  Map<String, dynamic>? _summary;
  bool _loading = true;
  String? _error;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _summary = await _remote.getMonthlySummary(_selectedYear, _selectedMonth);
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent, // Let Shell's gradient show through
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorPlaceholder()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilterHeader(theme),
                        const SizedBox(height: 32),
                        
                        Text('MONTHLY SUMMARY', style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900, 
                          color: AppTheme.textSecondary,
                          letterSpacing: 1.5,
                        )),
                        const SizedBox(height: 16),
                        _buildSummaryGrid(theme),
                        const SizedBox(height: 32),

                        Text('DETAILED REPORTING', style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900, 
                          color: AppTheme.textSecondary,
                          letterSpacing: 1.5,
                        )),
                        const SizedBox(height: 16),
                        _buildDetailedData(theme),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFilterHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range_rounded, color: AppTheme.primaryGreen),
          const SizedBox(width: 16),
          _buildDropdown(_selectedMonth, List.generate(12, (i) => i + 1), (v) {
            setState(() => _selectedMonth = v!);
            _load();
          }, labelBuilder: (m) => _monthName(m)),
          const SizedBox(width: 24),
          _buildDropdown(_selectedYear, [2024, 2025, 2026, 2027], (v) {
            setState(() => _selectedYear = v!);
            _load();
          }),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(T value, List<T> items, ValueChanged<T?> onChanged, {String Function(T)? labelBuilder}) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textMain, fontSize: 14),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(labelBuilder?.call(i) ?? '$i'))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSummaryGrid(ThemeData theme) {
    if (_summary == null) return const SizedBox();
    
    final totalBeneficiaries = _summary?['total_beneficiaries'] ?? _summary?['totalBeneficiaries'] ?? 0;
    final totalAmount = _summary?['total_amount'] ?? _summary?['totalAmount'] ?? 0;
    final redeemed = _summary?['redeemed_count'] ?? _summary?['redeemedCount'] ?? 0;
    final pending = _summary?['pending_count'] ?? _summary?['pendingCount'] ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _SummaryTile(title: 'Beneficiaries', value: '$totalBeneficiaries', icon: Icons.group_rounded, color: AppTheme.accentBlue),
        _SummaryTile(title: 'Disbursed', value: 'PKR $totalAmount', icon: Icons.payments_rounded, color: AppTheme.primaryGreen),
        _SummaryTile(title: 'Redeemed', value: '$redeemed', icon: Icons.verified_rounded, color: Colors.teal),
        _SummaryTile(title: 'Pending', value: '$pending', icon: Icons.hourglass_top_rounded, color: Colors.orange),
      ],
    );
  }

  Widget _buildDetailedData(ThemeData theme) {
    if (_summary == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: _summary!.entries.map((e) {
            final isLast = e.key == _summary!.keys.last;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.08))),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(e.key.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(
                      fontSize: 10, 
                      fontWeight: FontWeight.w900, 
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    )),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('${e.value}', style: const TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.w900, 
                      color: AppTheme.textMain,
                    )),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.analytics_outlined, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(_error ?? 'Sync error'),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _load, child: const Text('RETRY REPORT')),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
    return months[month - 1];
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryTile({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textMain, letterSpacing: -0.5)),
              const SizedBox(height: 2),
              Text(title.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.8)),
            ],
          ),
        ],
      ),
    );
  }
}
