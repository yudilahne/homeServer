import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'models/stored_session.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'services/local_session_store.dart';

class ProjectPulseApp extends StatefulWidget {
  const ProjectPulseApp({super.key});

  @override
  State<ProjectPulseApp> createState() => _ProjectPulseAppState();
}

class _ProjectPulseAppState extends State<ProjectPulseApp> {
  final LocalSessionStore _sessionStore = LocalSessionStore();
  StoredSession? _session;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final storedSession = await _sessionStore.read();

    if (!mounted) {
      return;
    }

    setState(() {
      _session = storedSession;
      _isLoading = false;
    });
  }

  Future<void> _handleLogin(StoredSession session) async {
    await _sessionStore.save(session);

    if (!mounted) {
      return;
    }

    setState(() {
      _session = session;
    });
  }

  Future<void> _handleLogout() async {
    await _sessionStore.clear();

    if (!mounted) {
      return;
    }

    setState(() {
      _session = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isLoading
          ? const _SplashScreen()
          : _session == null
              ? LoginScreen(onLoggedIn: _handleLogin)
              : HomeShell(
                  session: _session!,
                  onLoggedOut: _handleLogout,
                ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
