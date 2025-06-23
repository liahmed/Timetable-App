import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track/providers/theme_provider.dart';
import 'package:track/providers/course_provider.dart';
import 'package:track/theme/theme.dart';
import 'package:track/screens/get_started_screen.dart';
import 'package:track/screens/home_screen.dart';
import 'package:track/screens/add_courses_screen.dart';
import 'package:track/screens/timetable_screen.dart';
import 'package:track/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CourseProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Track',
      theme: themeProvider.isDarkMode
          ? AppTheme.darkTheme
          : AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const GetStartedScreen(),
        '/home': (context) => const HomeScreen(),
        '/add_courses': (context) => const AddCoursesScreen(),
        '/timetable': (context) => const TimetableScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
