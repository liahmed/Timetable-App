import 'package:flutter/material.dart';
import 'package:timetableapp/screens/timetable_screen.dart';

class CourseSelectionBar extends StatefulWidget {
  final Function(String)? onDegreeSelected;
  final Function(String)? onSemesterSelected;
  final Function(String)? onSectionSelected;
  final VoidCallback? onSave;

  const CourseSelectionBar({
    super.key,
    this.onDegreeSelected,
    this.onSemesterSelected,
    this.onSectionSelected,
    this.onSave,
  });

  @override
  _CourseSelectionBarState createState() => _CourseSelectionBarState();
}

class _CourseSelectionBarState extends State<CourseSelectionBar> {
  String selectedDegree = "";
  String selectedSemester = "";
  String selectedSection = "";

  final List<String> degrees = [
    "BCS",
    "BAI",
    "BSE",
    "BCY",
    "BFT",
    "BSEE",
    "BSBA",
  ];
  final List<String> semesters = [
    "Semester 1",
    "Semester 2",
    "Semester 3",
    "Semester 4",
    "Semester 5",
    "Semester 6",
    "Semester 7",
    "Semester 8",
  ];
  final List<String> sections = [
    "Section A",
    "Section B",
    "Section C",
    "Section D",
    "Section E",
    "Section F",
    "Section G",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  text: "TRACK ",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1D1E),
                  ),
                  children: [
                    TextSpan(
                      text: "Add Courses",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.check, color: Color(0xFFC0EF7D), size: 28),
                onPressed: widget.onSave,
              ),
            ],
          ),
        ),

        // Degree Selection
        buildSelectionRow(degrees, selectedDegree, (value) {
          setState(() {
            selectedDegree = value;
            selectedSemester = "";
            selectedSection = "";
          });
          widget.onDegreeSelected?.call(value);
        }),

        const SizedBox(height: 8),

        // Semester Selection (Enabled when Degree is Selected)
        buildSelectionRow(semesters, selectedSemester, (value) {
          if (selectedDegree.isNotEmpty) {
            setState(() {
              selectedSemester = value;
              selectedSection = "";
            });
            widget.onSemesterSelected?.call(value);
          }
        }, enabled: selectedDegree.isNotEmpty),

        const SizedBox(height: 8),

        // Section Selection (Enabled when Semester is Selected)
        buildSelectionRow(sections, selectedSection, (value) {
          if (selectedSemester.isNotEmpty) {
            setState(() {
              selectedSection = value;
            });
            widget.onSectionSelected?.call(value);
          }
        }, enabled: selectedSemester.isNotEmpty),
      ],
    );
  }

  Widget buildSelectionRow(
    List<String> items,
    String selectedValue,
    Function(String) onTap, {
    bool enabled = true,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            items.map((item) {
              bool isSelected = item == selectedValue;
              return GestureDetector(
                onTap: enabled ? () => onTap(item) : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Color(0xFFC0EF7D)
                            : (enabled
                                ? Colors.transparent
                                : Colors.transparent),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
