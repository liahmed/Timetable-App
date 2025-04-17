import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'theme/theme.dart';
import 'screens/get_started_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_courses_screen.dart';
import 'screens/timetable_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Track',
      theme:
          themeProvider.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => GetStartedScreen(),
        '/home': (context) => HomeScreen(),
        '/add_courses': (context) => AddCoursesScreen(),
        '/timetable': (context) => TimetableScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
