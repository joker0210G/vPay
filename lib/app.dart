import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vpay/core/constants/themes.dart';
import 'package:vpay/features/account/providers/theme_provider.dart';
import 'package:vpay/features/auth/presentation/screens/auth_screen.dart';
import 'package:vpay/features/auth/providers/auth_provider.dart';
import 'package:vpay/features/auth/providers/auth_state.dart';
// Removed duplicate import of auth_provider.dart
import 'package:vpay/features/home/presentation/screens/home_screen.dart';
import 'package:vpay/features/task/presentation/screens/task_detail_screen.dart';
import 'package:vpay/features/task/presentation/screens/my_tasks_screen.dart';
import 'package:vpay/features/task/presentation/screens/ratings_screen.dart';
import 'package:vpay/features/account/presentation/screens/personalization_screen.dart';
import 'package:vpay/features/account/presentation/screens/edit_profile_screen.dart'; // Import EditProfileScreen
import 'package:vpay/features/task/presentation/screens/create_task_screen.dart';

// 1. Define route names 
class AppRoutes {
  static const home = 'home';
  static const auth = 'auth';
  static const taskDetails = 'taskDetails';
  static const myTasks = 'myTasks';
  static const ratings = 'ratings';
  static const personalization = 'personalization';
  static const createTask = 'createTask';
  static const editProfile = 'editProfile'; // Add editProfile route name
}

// 2. Riverpod provider for router 
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth',
    redirect: (context, state) {
      final authState = ref.watch(authProvider);
      final isLoggedIn = authState.user != null;
      final isLoading = authState.isLoading;
      final location = state.uri.path;

      if (isLoading) return null;

      // Handle root path explicitly
      if (location == '/') {
        return isLoggedIn
          ? '/home'
          : '/auth';
      }

      // Auth redirect logic
      if (!isLoggedIn) {
        return location == '/auth' ? null : '/auth';
      } else if (location == '/auth') {
        return '/home';
      }
      return null;
    },
    routes: [
      // 3. Define all named routes 
      GoRoute(
        name: AppRoutes.home,
        path: '/home',
        pageBuilder: (context, state) => const MaterialPage(
          child: HomeScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.auth,
        path: '/auth',
        pageBuilder: (context, state) => const MaterialPage(
          child: AuthScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.taskDetails,
        path: '/task-details/:task_id',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: TaskDetailScreen(taskId: state.pathParameters['task_id'] ?? ''), // Changed task_id to taskId
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        name: AppRoutes.myTasks,
        path: '/my-tasks',
        pageBuilder: (context, state) => const MaterialPage(
          child: MyTasksScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.ratings,
        path: '/ratings',
        pageBuilder: (context, state) => const MaterialPage(
          child: RatingsScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.personalization,
        path: '/personalization',
        pageBuilder: (context, state) => const MaterialPage(
          child: PersonalizationScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.createTask,
        path: '/create-task',
        pageBuilder: (context, state) => const MaterialPage(
          child: CreateTaskScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.editProfile, // Use the new constant
        path: '/edit-profile', // Path used in account_screen.dart
        pageBuilder: (context, state) => const MaterialPage(
          child: EditProfileScreen(),
        ),
      ),
    ],
    errorPageBuilder: (context, state) => const MaterialPage(
      child: Scaffold(
        body: Center(
          child: Text('Page not found'),
        ),
      ),
    ),
    debugLogDiagnostics: true, // Helps debug routing issues
  );
});

class AppWidget extends ConsumerWidget {
  const AppWidget({super.key}); // Added const

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final router = ref.watch(routerProvider); // Renamed _router to router
    
    // Add listener for auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.user != null && (previous?.user == null)) {
        // Navigate to home when user logs in
        router.go('/home'); // Use new name
      } else if (next.user == null && previous?.user != null) {
        // Navigate to auth when user logs out
        router.go('/auth'); // Use new name
      }
    });

    final themeState = authState.user != null
      ? ref.watch(themeProvider(authState.user!.id))
      : const AsyncValue.data(null);

    return MaterialApp.router(
      title: 'vPay',
      theme: themeState.when(
        data: (theme) => theme?.theme ?? appTheme(),
        loading: () => appTheme(),
        error: (error, stack) {
          debugPrint('Theme loading error: $error');
          return appTheme();
        },
      ),
      routerConfig: router, // Use new name
      debugShowCheckedModeBanner: false,
    );
  }
}
