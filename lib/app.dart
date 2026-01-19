import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrikeep/pages/splash_screen.dart';
import 'package:agrikeep/pages/welcome_page.dart';
import 'package:agrikeep/pages/auth/login_page.dart';
import 'package:agrikeep/pages/auth/signup_page.dart';
import 'package:agrikeep/pages/auth/forgot_password_page.dart';
import 'package:agrikeep/pages/dashboard_page.dart';
import 'package:agrikeep/pages/recommendations_page.dart';
import 'package:agrikeep/pages/cultivation_activities_page.dart';
import 'package:agrikeep/pages/cultivation_detail_page.dart';
import 'package:agrikeep/pages/harvest_entry_page.dart';
import 'package:agrikeep/pages/records_page.dart';
import 'package:agrikeep/pages/crop_information_page.dart';
import 'package:agrikeep/pages/profile_page.dart';
import 'package:agrikeep/pages/editprofile_page.dart';
import 'package:agrikeep/pages/providers/auth_provider.dart';
import 'package:agrikeep/pages/weekly_act_page.dart';
import 'package:agrikeep/pages/add_cultivation_page.dart';
import 'package:agrikeep/pages/harvest_records_page.dart';
import 'package:agrikeep/pages/activity_records_page.dart'; // ADD THIS
import 'package:agrikeep/models/cultivation.dart';
import 'package:agrikeep/models/activity.dart'; // ADD THIS
import 'package:agrikeep/models/harvest.dart'; // ADD THIS

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  AppState _appState = AppState.splash;
  String _currentPage = 'dashboard';
  Map<String, dynamic>? _currentPageParams;
  // ADD THIS: Prevent multiple navigation triggers
  bool _isHandlingAuthChange = false;


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
  }

  void _handleSignUp() {
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

    final authProvider = context.watch<AuthProvider>();

    // Handle authenticated user (already logged in)
    if (authProvider.isAuthenticated && _appState != AppState.app) {
      // Only navigate if we're NOT already in app state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setAppState(AppState.app);
      });
    }

    // Handle non-authenticated user
    if (!authProvider.isAuthenticated && _appState == AppState.app) {
      // If user was in app but now not authenticated (logged out), go to welcome
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setAppState(AppState.welcome);
      });
    }

    if (authProvider.isAuthenticated && _appState != AppState.app && !_isHandlingAuthChange) {
      _isHandlingAuthChange = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setAppState(AppState.app);
        _isHandlingAuthChange = false;
      });
    }

    // Handle non-authenticated user who was in app (logged out)
    if (!authProvider.isAuthenticated && _appState == AppState.app && !_isHandlingAuthChange) {
      _isHandlingAuthChange = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setAppState(AppState.welcome);
        _isHandlingAuthChange = false;
      });
    }

    // if (authProvider.isAuthenticated && _appState != AppState.app) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _setAppState(AppState.app);
    //   });
    // }
    //
    // if (!authProvider.isAuthenticated &&
    //     (_appState == AppState.app || _appState == AppState.welcome)) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _setAppState(AppState.login);
    //   });
    // }

    if (_appState == AppState.splash) {
      return SplashScreen(
        onComplete: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final authProvider = context.read<AuthProvider>();

            if (authProvider.isAuthenticated) {
              // User is already logged in - go straight to app
              _setAppState(AppState.app);
            } else {
              // User not logged in - go to welcome page
              _setAppState(AppState.welcome);
            }
          });
        },
      );
    }

    if (_appState == AppState.welcome) {
      return WelcomePage(
        onGetStarted: () => _setAppState(AppState.login),
      );
    }

    if (_appState == AppState.login) {
      return LoginPage(
        onLogin: () {
          // When login is successful, go to app
          _setAppState(AppState.app);
        },
        onSignUp: () => _setAppState(AppState.signup),
        onForgotPassword: () => _setAppState(AppState.forgotPassword),
      );
    }

    if (_appState == AppState.signup) {
      return SignUpPage(
        onSignUp: () {
          // When signup is successful, go to app
          _setAppState(AppState.app);
        },
        onBackToLogin: () => _setAppState(AppState.login),
      );
    }

    if (_appState == AppState.forgotPassword) {
      return ForgotPasswordPage(
        onBackToLogin: () => _setAppState(AppState.login),
      );
    }

    if (_appState == AppState.app) {
      // Check if user is actually authenticated
      if (!authProvider.isAuthenticated) {
        // If not authenticated, go back to welcome page
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _setAppState(AppState.welcome);
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      return _buildMainApp();
    }

    return const Scaffold(
      body: Center(child: Text('Something went wrong')),
    );
  }

  Widget _buildMainApp() {
    if (_currentPage.startsWith('cultivation-detail/')) {
      final parts = _currentPage.split('/');
      if (parts.length >= 2) {
        final cultivationId = parts[1];
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
          return CultivationDetailPage(
            onBack: () => _setCurrentPage('cultivation'),
            onAddActivity: () => _setCurrentPage('weekly-activity', params: {
              'cultivationId': cultivationId,
            }),
            onHarvest: () => _setCurrentPage('harvest-entry', params: {
              'cultivationId': cultivationId,
            }),
            cropId: 'TEMPORARY_CROP_ID_001',
            cropName: 'Loading...',
            onNavigate: _setCurrentPage,
            cultivationId: cultivationId,
          );
        }
      }
    }

    switch (_currentPage) {
      case 'dashboard':
        return DashboardPage(
          onNavigate: _setCurrentPage,
          onLogout: _handleLogout,
        );
      case 'recommendations':
        return RecommendationsPage(onBack: () => _setCurrentPage('dashboard'));
      case 'cultivation':
        return CultivationActivitiesPage(
          onBack: () => _setCurrentPage('dashboard'),
          onNavigate: _setCurrentPage,
        );
    // In app.dart, update the 'add-cultivation' case:

      case 'add-cultivation':
        final cultivation = _currentPageParams?['cultivation'] as Cultivation?;
        final isEditMode = _currentPageParams?['isEditMode'] ?? false;

        return AddCultivationPage(
          onBack: () => _setCurrentPage('cultivation'),
          cultivation: cultivation, // Pass the cultivation to edit
          isEditMode: isEditMode, // Pass edit mode flag
        );
      case 'weekly-activity':
        final cultivationId = _currentPageParams?['cultivationId'] ?? 'TEMPORARY_ID_001';
        final cropName = _currentPageParams?['cropName'] ?? 'Crop';

        return WeeklyActivityPage(
          onBack: () => _setCurrentPage('cultivation-detail/$cultivationId'),
          cultivationId: cultivationId,
          cropName: cropName,
        );
      case 'harvest-entry':
        final harvestCultivationId = _currentPageParams?['cultivationId'];
        final cropId = _currentPageParams?['cropId'] ?? 'TEMPORARY_CROP_ID_001';
        final cropName = _currentPageParams?['cropName'] ?? 'Crop';

        return HarvestEntryPage(
          onBack: () => _setCurrentPage('cultivation-detail/$harvestCultivationId'),
          onSave: () => _setCurrentPage('cultivation-detail/$harvestCultivationId'),
          cropId: cropId,
          cropName: cropName,
          cultivationId: harvestCultivationId,
        );
      case 'harvest-records':
        final cropId = _currentPageParams?['cropId'];
        final cropName = _currentPageParams?['cropName'];
        final cultivationId = _currentPageParams?['cultivationId'];

        return HarvestRecordsPage(
          onBack: () {
            if (cultivationId != null && cultivationId.isNotEmpty) {
              _setCurrentPage('cultivation-detail/$cultivationId');
            } else {
              _setCurrentPage('cultivation');
            }
          },
          cropId: cropId,
          cropName: cropName,
          cultivationId: cultivationId,
          onNavigate: _setCurrentPage, // ADD THIS
        );
      case 'harvest-edit':
        final harvest = _currentPageParams?['harvest'] as Harvest?;
        final cultivationId = _currentPageParams?['cultivationId'] ?? harvest?.cultivationId;
        final cropId = _currentPageParams?['cropId'] ?? harvest?.cropId;
        final cropName = _currentPageParams?['cropName'] ?? harvest?.cropName;

        return HarvestEntryPage(
          onBack: () {
            // Go back to harvest records page
            _setCurrentPage('harvest-records', params: {
              'cultivationId': cultivationId,
              'cropId': cropId,
              'cropName': cropName,
            });
          },
          onSave: () {
            // After saving, go back to harvest records page
            _setCurrentPage('harvest-records', params: {
              'cultivationId': cultivationId,
              'cropId': cropId,
              'cropName': cropName,
            });
          },
          cropId: cropId ?? 'TEMPORARY_CROP_ID_001',
          cropName: cropName ?? 'Crop',
          cultivationId: cultivationId,
          harvest: harvest, // Pass the harvest for edit mode
        );
      case 'activity-records':
        final cultivationId = _currentPageParams?['cultivationId'];
        final cropName = _currentPageParams?['cropName'];

        return ActivityRecordsPage(
          onBack: () {
            if (cultivationId != null && cultivationId.isNotEmpty) {
              _setCurrentPage('cultivation-detail/$cultivationId');
            } else {
              _setCurrentPage('cultivation');
            }
          },
          cultivationId: cultivationId ?? '',
          cropName: cropName,
          onNavigate: _setCurrentPage,
        );
      case 'activity-edit':
        final activity = _currentPageParams?['activity'] as Activity?;
        final cultivationId = _currentPageParams?['cultivationId'] ?? activity?.cultivationId;
        final cropName = _currentPageParams?['cropName'] ?? 'Crop';

        return WeeklyActivityPage(
          onBack: () {
            // Go back to activity records page
            _setCurrentPage('activity-records', params: {
              'cultivationId': cultivationId,
              'cropName': cropName,
            });
          },
          cultivationId: cultivationId ?? '',
          cropName: cropName,
          activity: activity, // Pass the activity for edit mode
        );
      case 'salesrecords':
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
          onNavigate: _setCurrentPage,
        );
      case 'profile-edit':
        return EditProfilePage(onBack: () => _setCurrentPage('profile'));
      default:
        return DashboardPage(
          onNavigate: _setCurrentPage,
          onLogout: _handleLogout,
        );
    }
  }
}

enum AppState {
  splash,
  welcome,
  login,
  signup,
  forgotPassword,
  app,
}