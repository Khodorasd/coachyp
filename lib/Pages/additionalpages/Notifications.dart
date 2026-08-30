
import 'package:coachyp/colors.dart';
import 'package:flutter/material.dart';


class Notificationspage extends StatelessWidget {
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: ShaderMask(
          shaderCallback: (bounds) => myLinearGradient().createShader(bounds),
          child: const Text(
            " UserName ",
            style: TextStyle(
              color: Colors.amberAccent,
              fontSize: 40, // Reduced from 50 to prevent overflow
              fontFamily: 'Jersey15',
            ),
          ),
        ),
        
      ),
      body: Center(
        child: Text("notification"),
      ),
      backgroundColor: AppColors.primary,
     
    );
     }
}