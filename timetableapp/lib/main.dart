import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Track/providers/theme_provider.dart';
import 'package:Track/providers/course_provider.dart';
import 'package:Track/theme/theme.dart';
import 'package:Track/screens/get_started_screen.dart';
import 'package:Track/screens/home_screen.dart';
import 'package:Track/screens/add_courses_screen.dart';
import 'package:Track/screens/timetable_screen.dart';
import 'package:Track/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CourseProvider()),
      ],
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
