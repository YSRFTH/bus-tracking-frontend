import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BusMarker extends StatelessWidget {
  final double heading;
  final bool isSelected;

  const BusMarker({
    super.key,
    required this.heading,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        if (isSelected) 
          const ScaleEffect(
            duration: Duration(milliseconds: 200),
            begin: Offset(1, 1),
            end: Offset(1.2, 1.2),
          ),
      ],
      child: Transform.rotate(
        angle: (heading * 3.14159) / 180, // Convert degrees to radians
        child: Icon(
          Icons.directions_bus,
          color: isSelected ? Colors.blue : Colors.red,
          size: 30,
        ),
      ),
    );
  }
} 