import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'providers/bus_provider.dart';
import 'providers/location_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    debugPrint('Environment variables loaded successfully');
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BusProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ), // Add ThemeProvider
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Bus Track',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(), // Default light theme
            darkTheme: ThemeData.dark(), // Default dark theme
            themeMode:
                themeProvider.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light, // Use ThemeProvider's state
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
