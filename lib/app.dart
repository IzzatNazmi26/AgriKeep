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
import 'package:agrikeep/pages/crop_information_page.dart';
import 'package:agrikeep/pages/profile_page.dart';
import 'package:agrikeep/pages/settings_page.dart';
import 'package:agrikeep/pages/providers/auth_provider.dart';
import 'package:agrikeep/pages/weekly_act_page.dart';
import 'package:agrikeep/pages/add_cultivation_page.dart';
import 'package:agrikeep/pages/harvest_records_page.dart';
import 'package:agrikeep/models/cultivation.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  AppState _appState = AppState.splash;
  String _currentPage = 'dashboard';
  Map<String, dynamic>? _currentPageParams; // Store navigation parameters

  void _setAppState(AppState state) {
    print("🔄 Changing app state from $_appState to $state");
    setState(() => _appState = state);
  }

  void _setCurrentPage(String page, {Map<String, dynamic>? params}) {
    print("📱 Setting current page to: $page with params: $params");
    setState(() {
      _currentPage = page;
      _currentPageParams = params;
    });
  }

  void _handleLogin() {
    // Do nothing here
    // Firebase Auth + AuthProvider will handle state
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

    // Listen to auth provider
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated && _appState != AppState.app) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setAppState(AppState.app);
      });
    }

    if (!authProvider.isAuthenticated &&
        (_appState == AppState.app || _appState == AppState.welcome)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setAppState(AppState.login);
      });
    }

    // 1. SPLASH SCREEN
    if (_appState == AppState.splash) {
      return SplashScreen(
        onComplete: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final authProvider = context.read<AuthProvider>();

            if (authProvider.isAuthenticated) {
              _setAppState(AppState.app);
            } else {
              _setAppState(AppState.login);
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

    // Fallback
    return const Scaffold(
      body: Center(child: Text('Something went wrong')),
    );
  }

  Widget _buildMainApp() {
    // Handle dynamic cultivation-detail route with ID
    // In the _buildMainApp() method, update the cultivation-detail route handling:
    if (_currentPage.startsWith('cultivation-detail/')) {
      final parts = _currentPage.split('/');
      if (parts.length >= 2) {
        final cultivationId = parts[1];

        // Check if we have the cultivation data passed as params
        final cultivation = _currentPageParams?['cultivation'] as Cultivation?;

        if (cultivation != null) {
          return CultivationDetailPage(
            onBack: () => _setCurrentPage('cultivation'),
            onAddActivity: () => _setCurrentPage('weekly-activity', params: {
              'cultivationId': cultivationId,
              'cropName': cultivation.cropName,
            }),
            onHarvest: () => _setCurrentPage('harvest-entry', params: {
              'cultivationId': cultivationId,
              'cropName': cultivation.cropName,
              'cropId': cultivation.cropId,
            }),
            cropId: cultivation.cropId,
            cropName: cultivation.cropName,
            onNavigate: _setCurrentPage,
            cultivationId: cultivationId,
          );
        } else {
          // TODO: We might need to fetch the cultivation data here
          return CultivationDetailPage(
            onBack: () => _setCurrentPage('cultivation'),
            onAddActivity: () => _setCurrentPage('weekly-activity', params: {
              'cultivationId': cultivationId,
            }),
            onHarvest: () => _setCurrentPage('harvest-entry', params: {
              'cultivationId': cultivationId,
            }),
            cropId: 'TEMPORARY_CROP_ID_001', // Placeholder until we fetch data
            cropName: 'Loading...',
            onNavigate: _setCurrentPage,
            cultivationId: cultivationId,
          );
        }
      }
    }

    // Handle other routes
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
      case 'add-cultivation':
        return AddCultivationPage(
          onBack: () => _setCurrentPage('cultivation'),
        );
      case 'weekly-activity':
        final cultivationId = _currentPageParams?['cultivationId'] ?? 'TEMPORARY_ID_001';
        final cropName = _currentPageParams?['cropName'] ?? 'Crop'; // Get from params

        return WeeklyActivityPage(
          onBack: () => _setCurrentPage('cultivation-detail/$cultivationId'),
          cultivationId: cultivationId,
          cropName: cropName, // Use the real crop name from params
        );
      case 'harvest-entry':
        final harvestCultivationId = _currentPageParams?['cultivationId'];
        final cropId = _currentPageParams?['cropId'] ?? 'TEMPORARY_CROP_ID_001'; // Get from params
        final cropName = _currentPageParams?['cropName'] ?? 'Crop'; // Get from params

        return HarvestEntryPage(
          onBack: () => _setCurrentPage('cultivation-detail/$harvestCultivationId'),
          onSave: () => _setCurrentPage('cultivation-detail/$harvestCultivationId'),
          cropId: cropId, // Use the real crop ID from params
          cropName: cropName, // Use the real crop name from params
          cultivationId: harvestCultivationId,
        );
    // In app.dart, update the harvest-records route handling:
      case 'harvest-records':
        final cropId = _currentPageParams?['cropId'];
        final cropName = _currentPageParams?['cropName'];
        final cultivationId = _currentPageParams?['cultivationId'];

        print('📊 Navigating to harvest-records with params:');
        print('   cropId: $cropId');
        print('   cropName: $cropName');
        print('   cultivationId: $cultivationId');

        return HarvestRecordsPage(
          onBack: () {
            print('🔙 Back button pressed from harvest-records');
            print('   cultivationId from params: $cultivationId');

            // Always go back to cultivation detail if we have cultivationId
            if (cultivationId != null && cultivationId.isNotEmpty) {
              print('   Navigating back to cultivation-detail/$cultivationId');
              _setCurrentPage('cultivation-detail/$cultivationId');
            } else {
              print('   No cultivationId, navigating to cultivation list');
              _setCurrentPage('cultivation');
            }
          },
          cropId: cropId,
          cropName: cropName,
          cultivationId: cultivationId, // ADD THIS
        );
      case 'salesrecords':
        return RecordsPage(
          onBack: () => _setCurrentPage('dashboard'),
          onNavigate: _setCurrentPage,
        );
      case 'records':
        return RecordsPage(
          onBack: () => _setCurrentPage('dashboard'),
          onNavigate: _setCurrentPage,
        );
      case 'crop-info':
        return CropInformationPage(onBack: () => _setCurrentPage('dashboard'));
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