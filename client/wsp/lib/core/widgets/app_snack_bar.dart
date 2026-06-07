import 'package:flutter/material.dart';

extension AppSnackBar on BuildContext {
  void showAppSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }
}
