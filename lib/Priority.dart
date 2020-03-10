import 'package:flutter/material.dart';

class Priority {
  static const LOW = "Low";
  static const MEDIUM = "Medium";
  static const HIGH = "High";

  static MaterialColor getColor(String priority) {
    switch (priority) {
      case LOW:
        return Colors.green;
      case MEDIUM:
        return Colors.orange;
      case HIGH:
        return Colors.red;
    }
    return Colors.grey;
  }
}
