import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/child_login_screen.dart';
import '../screens/parent/parent_dashboard_screen.dart';
import '../screens/parent/add_task_screen.dart';
import '../screens/parent/task_approval_screen.dart';
import '../screens/parent/child_progress_screen.dart';
import '../screens/parent/settings_screen.dart';
import '../screens/child/child_home_screen.dart';
import '../screens/child/missions_screen.dart';
import '../screens/child/rewards_screen.dart';
import '../screens/child/profile_screen.dart';
import '../screens/child/celebration_screen.dart';

/// App router — defines all named routes
class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String roleSelection = '/role-selection';
  static const String childLogin = '/child-login';
  static const String parentDashboard = '/parent-dashboard';
  static const String addTask = '/add-task';
  static const String taskApproval = '/task-approval';
  static const String childProgress = '/child-progress';
  static const String parentSettings = '/parent-settings';
  static const String childHome = '/child-home';
  static const String missions = '/missions';
  static const String rewards = '/rewards';
  static const String profile = '/profile';
  static const String celebration = '/celebration';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        roleSelection: (_) => const RoleSelectionScreen(),
        childLogin: (_) => const ChildLoginScreen(),
        parentDashboard: (_) => const ParentDashboardScreen(),
        parentSettings: (_) => const ParentSettingsScreen(),
        addTask: (_) => const AddTaskScreen(),
        taskApproval: (_) => const TaskApprovalScreen(),
        childProgress: (_) => const ChildProgressScreen(),
        childHome: (_) => const ChildHomeScreen(),
        missions: (_) => const MissionsScreen(),
        rewards: (_) => const RewardsScreen(),
        profile: (_) => const ProfileScreen(),
        celebration: (_) => const CelebrationScreen(),
      };
}
