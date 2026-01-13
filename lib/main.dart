import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

// Core
import 'themes/app_themes.dart';
import 'core/providers/theme_provider.dart';
import 'core/widgets/main_navigation.dart';
import 'core/config/windows_accessibility_config.dart';
import 'core/config/windows_error_handler.dart';
import 'config/api_config.dart';

// Pages
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';

// Services
import 'features/auth/services/auth_service.dart';

// Preinscription - Routes gérées dans MainNavigation
import 'features/preinscription/presentation/preinscription_routes.dart';
import 'package:mycampus/features/preinscription/presentation/pages/preinscription_info_page.dart';
import 'features/preinscription/presentation/pages/preinscription_form_page.dart';

// Messaging - Routes gérées dans MainNavigation
import 'features/messaging/presentation/pages/conversation_page.dart';

// Preinscription Validation
import 'features/preinscription_validation/providers/preinscription_validation_provider.dart';
import 'features/preinscription_validation/services/preinscription_validation_repository_impl.dart';
import 'features/preinscription_validation/services/preinscription_validation_remote_datasource.dart';

// Settings
import 'features/settings/settings_routes.dart';
import 'features/settings/controllers/settings_controller.dart';

// Faculty
import 'features/faculty/presentation/faculty_routes.dart';

// Program
import 'features/program/presentation/program_routes.dart';

// Department
import 'features/department/presentation/department_routes.dart';

// Course
import 'features/course/presentation/course_routes.dart';

// User Management - Routes gérées dans MainNavigation
import 'features/user_management/providers/user_management_provider.dart';
import 'features/user_management/data/repositories/user_management_repository.dart';
import 'features/user_management/data/datasources/user_management_remote_datasource.dart';

// Notifications - Routes gérées dans MainNavigation
import 'features/notifications/providers/notification_provider.dart';

// Student Management - Routes gérées dans MainNavigation
import 'features/student_management/providers/student_provider.dart';
import 'features/student_management/presentation/student_management_routes.dart';
import 'features/student_management/providers/enhanced_student_provider.dart';
import 'features/student_management/data/datasources/enhanced_student_remote_datasource.dart';

// Preinscriptions Management - Routes gérées dans MainNavigation
import 'features/preinscriptions_management/providers/preinscription_provider.dart';

// Announcements Management - Routes gérées dans MainNavigation
import 'features/announcements_management/presentation/providers/announcement_provider.dart';
import 'features/announcements_management/data/repositories/announcement_repository_impl.dart';
import 'features/announcements_management/data/datasources/announcement_remote_datasource.dart';

// Messaging - Repository
import 'features/messaging/data/repositories/group_repository.dart';
import 'features/messaging/data/datasources/group_remote_datasource.dart';

// Profile - Routes gérées dans MainNavigation
import 'features/profile/providers/profile_provider.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';

void main() async {
  // Configuration de la gestion des erreurs
  _setupErrorHandling();
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable accessibility features that cause viewId errors on Windows
  WindowsAccessibilityConfig.configureAccessibility();
  
  // Initialisation des données de formatage de date
  await initializeDateFormatting('fr_FR', null);
  
  // Initialisation des préférences partagées
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(prefs: prefs),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<SettingsController>(
          create: (_) => SettingsController(),
        ),
        ChangeNotifierProvider<UserManagementProvider>(
          create: (_) => UserManagementProvider(
            repository: UserManagementRepositoryImpl(
              remoteDataSource: UserManagementRemoteDataSourceImpl(
                client: http.Client(),
              ),
            ),
          ),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider<StudentProvider>(
          create: (_) => StudentProviderFactory.create(),
        ),
        ChangeNotifierProvider<EnhancedStudentProvider>(
          create: (_) => EnhancedStudentProvider(
            repository: EnhancedStudentRemoteDataSource(
              client: http.Client(),
            ),
            authService: AuthService(),
          ),
        ),
        ChangeNotifierProvider<PreinscriptionProvider>(
          create: (_) => PreinscriptionProvider(),
        ),
        ChangeNotifierProvider<PreinscriptionValidationProvider>(
          create: (_) => PreinscriptionValidationProvider(
            PreinscriptionValidationRepositoryImpl(
              remoteDataSource: PreinscriptionValidationRemoteDataSource(
                client: http.Client(),
                authService: AuthService(),
              ),
            ),
          ),
        ),
        ChangeNotifierProvider<AnnouncementProvider>(
          create: (_) => AnnouncementProvider(
            AnnouncementRepositoryImpl(
              remoteDataSource: AnnouncementRemoteDataSource(
                client: http.Client(),
              ),
            ),
          ),
        ),
        Provider<GroupRepositoryImpl>(
          create: (_) => GroupRepositoryImpl(
            remoteDataSource: GroupRemoteDataSourceImpl(
              client: http.Client(),
              authService: AuthService(),
            ),
          ),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(
            repository: ProfileRepositoryImpl(
              remoteDataSource: ProfileRemoteDataSource(
                client: http.Client(),
                authService: AuthService(),
                baseUrl: ApiConfig.baseUrl,
              ),
            ),
            authService: AuthService(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Configure la gestion globale des erreurs
void _setupErrorHandling() {
  // Gestion des erreurs Flutter synchrones
  FlutterError.onError = (FlutterErrorDetails details) {
    // Filter out all Windows accessibility-related errors using comprehensive handler
    if (WindowsErrorHandler.shouldFilterError(details.exception)) {
      WindowsErrorHandler.handleAccessibilityError();
      return;
    }
    
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    }
  };

  // Gestion des erreurs asynchrones
  PlatformDispatcher.instance.onError = (error, stack) {
    // Filter out all Windows accessibility-related errors using comprehensive handler
    if (WindowsErrorHandler.shouldFilterError(error)) {
      WindowsErrorHandler.handleAccessibilityError();
      return true;
    }
    
    if (kDebugMode) {
      debugPrint('Async Error: $error');
      debugPrint('Stack trace: $stack');
    }
    return true;
  };
}

/// Écran d'erreur personnalisé
class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;
  
  const ErrorScreen({
    super.key,
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erreur'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Oups, une erreur est survenue',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (kDebugMode) ...[
              Card(
                color: Colors.grey[200],
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SelectableText(
                    errorDetails.exceptionAsString(),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
              if (errorDetails.stack != null)
                Card(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SelectableText(
                      errorDetails.stack.toString(),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ),
            ] else
              const Text(
                'Une erreur inattendue s\'est produite. Veuillez réessayer plus tard.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour à la page de connexion'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {

        return MaterialApp(
          title: 'MyCampus',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme(),
          darkTheme: AppThemes.darkTheme(),
          themeMode: themeProvider.themeMode,
          
          // Completely disable accessibility features on Windows
          useInheritedMediaQuery: false,
          
          // Disable accessibility features on Windows to prevent viewId errors
          builder: (context, widget) {
            // Apply Windows-specific accessibility configuration
            if (WindowsAccessibilityConfig.shouldReduceAccessibilityFeatures) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  accessibleNavigation: false,
                  disableAnimations: false,
                  invertColors: false,
                  highContrast: false,
                  boldText: false,
                ),
                child: Semantics(
                  enabled: false, // Completely disable semantics on Windows
                  child: widget ?? const SizedBox(),
                ),
              );
            }
            
            // Configuration du gestionnaire d'erreurs
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
              if (kDebugMode) {
                return ErrorScreen(errorDetails: errorDetails);
              }
              return ErrorScreen(
                errorDetails: FlutterErrorDetails(
                  exception: 'Une erreur est survenue',
                  library: 'widgets',
                  context: ErrorDescription('while building the app'),
                ),
              );
            };

            // Afficher un indicateur de chargement si le widget est null
            if (widget == null) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return widget!;
          },
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('fr', 'FR'), // French
            const Locale('en', 'US'), // English
          ],
          // Configuration des routes principales
          initialRoute: '/login',
          routes: <String, WidgetBuilder>{
            '/login': (BuildContext context) => const LoginPage(),
            '/register': (BuildContext context) => const RegisterPage(),
            '/dashboard': (BuildContext context) => const MainNavigation(),
            // Routes de préinscription - redirigées vers MainNavigation
            '/preinscription': (BuildContext context) => const MainNavigation(),
            '/preinscription/info': (BuildContext context) => const PreinscriptionInfoPage(),
            '/preinscription/uy1': (BuildContext context) => const MainNavigation(),
            '/preinscription/falsh': (BuildContext context) => const MainNavigation(),
            '/preinscription/fs': (BuildContext context) => const MainNavigation(),
            '/preinscription/fse': (BuildContext context) => const MainNavigation(),
            '/preinscription/fmsb': (BuildContext context) => const MainNavigation(),
            '/preinscription/iut': (BuildContext context) => const MainNavigation(),
            '/preinscription/enspy': (BuildContext context) => const MainNavigation(),
            // Routes des paramètres
            ...SettingsRoutes.getRoutes(),
            // Routes des facultés
            ...FacultyRoutes.getRoutes(),
            // Routes des programmes
            ...ProgramRoutes.getRoutes(),
            // Routes des départements
            ...DepartmentRoutes.getRoutes(),
            // Routes des cours
            ...CourseRoutes.getRoutes(),
            // Routes principales via MainNavigation
            '/profile': (BuildContext context) => const MainNavigation(),
            '/settings': (BuildContext context) => const MainNavigation(),
            '/user-management': (BuildContext context) => const MainNavigation(),
            '/student-management': (BuildContext context) => const MainNavigation(),
            '/messaging': (BuildContext context) => const MainNavigation(),
            '/notifications': (BuildContext context) => const MainNavigation(),
            '/institutions': (BuildContext context) => const MainNavigation(),
            '/university': (BuildContext context) => const MainNavigation(),
            '/courses': (BuildContext context) => const MainNavigation(),
            '/programs': (BuildContext context) => const MainNavigation(),
            '/departments': (BuildContext context) => const MainNavigation(),
            '/faculties': (BuildContext context) => const MainNavigation(),
            '/preinscriptions-management': (BuildContext context) => const MainNavigation(),
            '/announcements': (BuildContext context) => const MainNavigation(),
          },
          // Utilisation de onGenerateRoute pour les routes dynamiques
          onGenerateRoute: (RouteSettings settings) {
            debugPrint('Tentative de navigation vers: ${settings.name}');
            
            // Gestion des routes de préinscription - rediriger vers MainNavigation avec la route spécifiée
            if (settings.name != null && settings.name!.startsWith('/preinscription') && settings.name != '/preinscription/info') {
              return MaterialPageRoute(
                builder: (context) => MainNavigation(initialRoute: settings.name),
                settings: settings,
              );
            }
            
            // Gestion des routes principales - rediriger vers MainNavigation avec la route spécifiée
            final mainRoutes = [
              '/profile', '/settings', '/user-management', '/student-management', '/messaging', 
              '/notifications', '/institutions', '/university', '/courses',
              '/programs', '/departments', '/faculties', '/preinscriptions-management', '/announcements'
            ];
            
            if (settings.name != null && mainRoutes.contains(settings.name)) {
              return MaterialPageRoute(
                builder: (context) => MainNavigation(initialRoute: settings.name),
                settings: settings,
              );
            }
            
            // Gestion des routes de formulaire avec paramètres
            if (settings.name != null && 
                settings.name!.startsWith(PreinscriptionRoutes.preinscriptionForm)) {
              final type = ModalRoute.of(context)?.settings.arguments as String? ?? 
                    (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?)?['type'] ??
                    'Général';
              return MaterialPageRoute(
                builder: (context) => PreinscriptionFormPage(formationType: type),
                settings: settings,
              );
            }
            
            // Gestion de la route de conversation avec paramètres
            if (settings.name == '/conversation') {
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null && args.containsKey('userId') && args.containsKey('userName')) {
                return MaterialPageRoute(
                  builder: (context) => ConversationPage(
                    userId: args['userId'],
                    userName: args['userName'],
                    userAvatar: args['userAvatar'],
                  ),
                  settings: settings,
                );
              }
            }
            
            // Gestion des routes de facultés avec paramètres
            if (settings.name != null && settings.name!.startsWith(FacultyRoutes.facultyDetails)) {
              return FacultyRoutes.generateFacultyDetailsRoute(settings);
            }
            
            // Gestion des routes de gestion des étudiants
            if (settings.name != null && settings.name!.startsWith('/student-management')) {
              final route = StudentManagementRoutes.generateRoute(settings);
              if (route != null) return route;
            }
            
            if (settings.name == FacultyRoutes.facultyCreate) {
              return FacultyRoutes.generateFacultyCreateRoute(settings);
            }
            
            if (settings.name != null && settings.name!.startsWith(FacultyRoutes.facultyEdit)) {
              return FacultyRoutes.generateFacultyEditRoute(settings);
            }
            
            // Si la route n'est pas reconnue, retourne une page d'erreur
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Erreur de navigation')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Page non trouvée'),
                      const SizedBox(height: 20),
                      Text('Route: ${settings.name ?? 'N/A'}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Retour'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Page non trouvée'),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Page non trouvée',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/');
                        },
                        child: const Text('Retour à l\'accueil'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}