import 'package:flutter/material.dart';

class Priority {
  static const LOW = "Low";
  static const MEDIUM = "Medium";
  static const HIGH = "High";

  static const PRIORITY_VALUE = {
    LOW: 3,
    MEDIUM: 2,
    HIGH: 1
  };

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
