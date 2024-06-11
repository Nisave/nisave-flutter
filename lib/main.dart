import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'state/provider_manager.dart';
import 'navigation/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:nisave/models/shared_preferences_manager.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesManager.initialize(); // Initialize SharedPreferences
 // Required for asynchronous init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Use the super parameters key to follow best practices
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ProviderManager.getProviders(), // This function should return a list of providers
      child: MaterialApp(
        title: 'Nisave Jamii',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(),
        onGenerateRoute: generateRoute,
        // Handle undefined routes
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Not Found'))));
        },
      ),
    );
  }
}
