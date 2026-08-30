import 'package:coachyp/colors.dart';
import 'package:flutter/material.dart';

class Sportschooser extends StatelessWidget {
  final String sports;
  final IconData SportIcon;
  final bool isSelected; // <-- NEW

  const Sportschooser({
    Key? key,
    required this.sports,
    required this.SportIcon,
    this.isSelected = false, // <-- Default value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 80,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(20),
              color: isSelected ? Colors.blueAccent : AppColors.s2, // <-- Color depends on isSelected
            ),
            child: Icon(
              SportIcon,
              size: 30,
              color: AppColors.background,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 7.0),
            child: ShaderMask(
              shaderCallback: (bounds) {
                return myLinearGradient().createShader(bounds);
              },
              child: Text(
                " $sports ",
                style: const TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 20,
                  fontFamily: 'Jersey15',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
