import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
  import '../screens/auth/login_screen.dart';
import '../screens/user/browse_canteens_screen.dart';
import '../screens/owner/menu_management_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(
      path: '/user/browse',
      builder: (context, state) => BrowseCanteensScreen(),
      redirect: (context, state) => _checkRole('user'),
    ),
    GoRoute(
      path: '/owner/menu',
      builder: (context, state) => MenuManagementScreen(),
      redirect: (context, state) => _checkRole('owner'),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => AdminDashboardScreen(),
      redirect: (context, state) => _checkRole('admin'),
    ),
  ],
);

String? _checkRole(String requiredRole) {
  // Get role from SharedPrefs
  return null;  // Or redirect to login if not match
}