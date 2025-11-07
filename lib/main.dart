import 'package:codepoetry/views/screens/home/home_screen.dart';
import 'package:codepoetry/views/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Services
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/connectivity_service.dart';

// Repositories
import 'repositories/poem_repository.dart';
import 'repositories/auth_repository.dart';

// ViewModels
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/poem_generator_viewmodel.dart';
import 'viewmodels/gallery_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';

// Theme
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize services
  final apiService = ApiService();
  apiService.initialize();

  final storageService = StorageService();
  await storageService.initialize();

  final connectivityService = ConnectivityService();
  await connectivityService.initialize();

  final authService = AuthService();

  // Create repositories
  final poemRepository = PoemRepository(
    apiService: apiService,
    storageService: storageService,
    connectivityService: connectivityService,
  );

  final authRepository = AuthRepository(
    authService: authService,
    storageService: storageService,
  );

  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider<ApiService>.value(value: apiService),
        Provider<StorageService>.value(value: storageService),
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider<ConnectivityService>.value(
          value: connectivityService,
        ),

        // Repositories
        Provider<PoemRepository>.value(value: poemRepository),
        Provider<AuthRepository>.value(value: authRepository),

        // ViewModels
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(authRepository)..initialize(),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => HomeViewModel(poemRepository)..initialize(),
        ),
        ChangeNotifierProvider<PoemGeneratorViewModel>(
          create: (_) => PoemGeneratorViewModel(poemRepository),
        ),
        ChangeNotifierProvider<GalleryViewModel>(
          create: (_) => GalleryViewModel(poemRepository),
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (_) => SettingsViewModel(storageService)..initialize(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch settings for theme mode
    final settingsViewModel = context.watch<SettingsViewModel>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Code Poetry',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsViewModel.themeMode,
      home: const SplashScreen(),
    );
  }
}