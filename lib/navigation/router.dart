// lib/navigation/router.dart
import 'package:flutter/material.dart';
import 'package:nisave/Screens/AllContributionsScreen.dart';
import 'package:nisave/Screens/all_fundraisers_screen.dart';
import 'package:nisave/Screens/create_fundraiser.dart';
import 'package:nisave/Screens/forgot_password_screen.dart';
import 'package:nisave/Screens/home_screen.dart';
import 'package:nisave/Screens/login_landing.dart';
import 'package:nisave/Screens/register_landing.dart';
import 'package:nisave/screens/splash_screen.dart';
import 'package:nisave/screens/login_screen.dart';
import 'package:nisave/screens/register_screen.dart';
import 'package:nisave/screens/onboarding_screen.dart';
import 'route_paths.dart';
import 'package:nisave/state/app_state.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RoutePaths.login:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case RoutePaths.login_landing:
      return MaterialPageRoute(builder: (context) => const LoginLand());
      case RoutePaths.splash:
      return MaterialPageRoute(builder: (context) => const SplashScreen());
    case RoutePaths.register:
      return MaterialPageRoute(builder: (context) => const RegisterScreen());
    case RoutePaths.home:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
    case RoutePaths.register_landing:
      return MaterialPageRoute(
        builder: (context) => AppState().hasCompletedOnboarding ? const LoginLand() : const RegisterLand(), // Make sure this matches the class name exactly
      );
    case RoutePaths.onboarding:
      return MaterialPageRoute(builder: (context) => const OnboardingScreen());
          case RoutePaths.createFundraiserCube:
      return MaterialPageRoute(builder: (context) =>  const CreateFundraiserScreen());
      case RoutePaths.forgot_password_screen:
      return MaterialPageRoute(builder: (context) => ForgotPasswordScreen());
      case RoutePaths.fundraisers:
      return MaterialPageRoute(builder: (context) => const FundraisersScreen()); // Routing to Fundraisers Screen
    case RoutePaths.AllContributionsScreen:
      return MaterialPageRoute(builder: (context) => const AllContributionsScreen(fundraiserId: '',));
    default:
      return MaterialPageRoute(builder: (context) => const SplashScreen());
  }
}
