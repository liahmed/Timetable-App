import 'package:flutter/material.dart';
import 'package:timetableapp/screens/add_courses_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    double titleFontSize = screenWidth * 0.09;
    double subtitleFontSize = screenWidth * 0.06;
    double bodyFontSize = screenWidth * 0.037;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.1),

              // Title Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.track_changes, size: 40, color: Colors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Track',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 150),

              // Feature Items
              FeatureItem(
                imagePath: 'assets/11.jpg',
                title: 'Keep Track',
                description:
                    'Turn on notifications for all your important lectures and updates.',
                subtitleFontSize: subtitleFontSize,
                bodyFontSize: bodyFontSize,
              ),
              SizedBox(height: 10),
              FeatureItem(
                imagePath: 'assets/12.jpg',
                title: 'Get Organized',
                description: 'Manage your schedule and stay updated with ease.',
                subtitleFontSize: subtitleFontSize,
                bodyFontSize: bodyFontSize,
              ),
              SizedBox(height: 10),
              FeatureItem(
                imagePath: 'assets/13.jpg',
                title: 'No Classes?',
                description: 'Join Plushes in their little weekly adventures.',
                subtitleFontSize: subtitleFontSize,
                bodyFontSize: bodyFontSize,
              ),

              const Spacer(),

              // Get Started Button
              Center(
                child: ElevatedButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCoursesScreen(),
                        ),
                      ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFFC0EF7D),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.2,
                      vertical: screenHeight * 0.02,
                    ),
                    textStyle: TextStyle(
                      fontSize: bodyFontSize * 1.4,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Get Started'),
                ),
              ),

              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final double subtitleFontSize;
  final double bodyFontSize;

  const FeatureItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.subtitleFontSize,
    required this.bodyFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath, width: 30, height: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F1D1E),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    color: const Color(0xFFA2A2A2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
