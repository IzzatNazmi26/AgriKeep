import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrikeep/pages/splash_screen.dart';
import 'package:agrikeep/pages/welcome_page.dart';
import 'package:agrikeep/pages/auth/login_page.dart';
import 'package:agrikeep/pages/auth/signup_page.dart';
import 'package:agrikeep/pages/auth/forgot_password_page.dart';
import 'package:agrikeep/pages/auth/profile_setup_page.dart';
import 'package:agrikeep/pages/dashboard_page.dart';
import 'package:agrikeep/pages/recommendations_page.dart';
import 'package:agrikeep/pages/cultivation_activities_page.dart';
import 'package:agrikeep/pages/cultivation_detail_page.dart';
import 'package:agrikeep/pages/harvest_entry_page.dart';
import 'package:agrikeep/pages/records_page.dart';
import 'package:agrikeep/pages/analytics_page.dart';
import 'package:agrikeep/pages/crop_information_page.dart';
import 'package:agrikeep/pages/profile_page.dart';
import 'package:agrikeep/pages/settings_page.dart';
import 'package:agrikeep/pages/providers/auth_provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  AppState _appState = AppState.splash;
  String _currentPage = 'dashboard'; // Added back for navigation

  void _setAppState(AppState state) {
    print("🔄 Changing app state from $_appState to $state");
    setState(() => _appState = state);
  }

  void _setCurrentPage(String page) {
    print("📱 Setting current page to: $page");
    setState(() => _currentPage = page);
  }

  void _handleLogin() {
    _setAppState(AppState.app);
  }

  void _handleSignUp() {
    _setAppState(AppState.profileSetup);
  }

  void _handleProfileSetupComplete() {
    _setAppState(AppState.app);
  }

  void _handleLogout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.signOut();
    _setAppState(AppState.welcome);
    _setCurrentPage('dashboard');
  }

  @override
  Widget build(BuildContext context) {
    print("🎨 Building App with state: $_appState, page: $_currentPage");

    // 1. SPLASH SCREEN - Show for 2 seconds, then check auth
    if (_appState == AppState.splash) {
      return SplashScreen(
        onComplete: () {
          print("✅ Splash screen complete");
          // Wait for next frame to ensure providers are ready
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            print("🔐 Auth status: ${authProvider.isAuthenticated}");

            if (authProvider.isAuthenticated) {
              _setAppState(AppState.app);
            } else {
              _setAppState(AppState.welcome);
            }
          });
        },
      );
    }

    // 2. WELCOME PAGE
    if (_appState == AppState.welcome) {
      return WelcomePage(
        onGetStarted: () => _setAppState(AppState.login),
      );
    }

    // 3. LOGIN PAGE
    if (_appState == AppState.login) {
      return LoginPage(
        onLogin: _handleLogin,
        onSignUp: () => _setAppState(AppState.signup),
        onForgotPassword: () => _setAppState(AppState.forgotPassword),
      );
    }

    // 4. SIGNUP PAGE
    if (_appState == AppState.signup) {
      return SignUpPage(
        onSignUp: _handleSignUp,
        onBackToLogin: () => _setAppState(AppState.login),
      );
    }

    // 5. FORGOT PASSWORD
    if (_appState == AppState.forgotPassword) {
      return ForgotPasswordPage(
        onBackToLogin: () => _setAppState(AppState.login),
      );
    }

    // 6. PROFILE SETUP
    if (_appState == AppState.profileSetup) {
      return ProfileSetupPage(
        onComplete: _handleProfileSetupComplete,
      );
    }

    // 7. MAIN APP WITH NAVIGATION
    if (_appState == AppState.app) {
      return _buildMainApp();
    }

    // Fallback - should never reach here
    return const Scaffold(
      body: Center(child: Text('Something went wrong')),
    );
  }

  Widget _buildMainApp() {
    switch (_currentPage) {
      case 'dashboard':
        return DashboardPage(onNavigate: _setCurrentPage);
      case 'recommendations':
        return RecommendationsPage(onBack: () => _setCurrentPage('dashboard'));
      case 'cultivation':
        return CultivationActivitiesPage(
          onBack: () => _setCurrentPage('dashboard'),
          onNavigate: _setCurrentPage,
        );
      case 'cultivation-detail':
        return CultivationDetailPage(
          onBack: () => _setCurrentPage('cultivation'),
          onAddActivity: () => _setCurrentPage('weekly-activity'),
          onHarvest: () => _setCurrentPage('harvest-entry'),
        );
      case 'weekly-activity':
        return Scaffold(
          appBar: AppBar(
            title: const Text('Weekly Activity'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _setCurrentPage('cultivation-detail'),
            ),
          ),
          body: const Center(child: Text('Weekly Activity Page')),
        );
      case 'harvest-entry':
        return HarvestEntryPage(
          onBack: () => _setCurrentPage('cultivation-detail'),
          onSave: () => _setCurrentPage('cultivation'),
        );
      case 'records':
        return RecordsPage(
          onBack: () => _setCurrentPage('dashboard'),
          onNavigate: _setCurrentPage,
        );
      case 'crop-info':
        return CropInformationPage(onBack: () => _setCurrentPage('dashboard'));
      case 'analytics':
        return AnalyticsPage(onBack: () => _setCurrentPage('dashboard'));
      case 'profile':
        return ProfilePage(
          onBack: () => _setCurrentPage('dashboard'),
          onLogout: _handleLogout,
          onNavigate: _setCurrentPage,
        );
      case 'settings':
        return SettingsPage(onBack: () => _setCurrentPage('profile'));
      default:
        return DashboardPage(onNavigate: _setCurrentPage);
    }
  }
}

enum AppState {
  splash,
  welcome,
  login,
  signup,
  forgotPassword,
  profileSetup,
  app,
}