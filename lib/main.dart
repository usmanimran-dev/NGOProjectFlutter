import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo/presentation/features/reports/bloc/report_bloc.dart';
import 'package:demo/injection_container.dart' as di;
import 'package:demo/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:demo/presentation/features/auth/bloc/auth_event.dart';
import 'package:demo/presentation/features/auth/bloc/auth_state.dart';
import 'package:demo/presentation/features/beneficiary/bloc/beneficiary_bloc.dart';
import 'package:demo/presentation/features/assistance/bloc/assistance_bloc.dart';
import 'package:demo/core/theme/app_theme.dart';
import 'package:demo/presentation/features/auth/screens/login_screen.dart';
import 'package:demo/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:demo/presentation/shared/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const NGOApp());
}

class NGOApp extends StatelessWidget {
  const NGOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(AppStarted()),
        ),
        BlocProvider(
          create: (_) => di.sl<BeneficiaryBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<AssistanceBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<ReportBloc>()..add(GetMonthlySummaryRequested(DateTime.now().year, DateTime.now().month)),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NGO Assistance System',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light, // Locked to Light for Premium Glassmorphism consistency
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return MainShell(
                title: '${state.user.role.toString().split('.').last.toUpperCase()} Portal',
                body: const DashboardScreen(),
              );
            }
            // For AuthInitial, AuthLoading, or AuthError -> stay on LoginScreen
            // LoginScreen handles its own Loading state internally in the button
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
