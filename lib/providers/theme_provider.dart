import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  bool _isToggling = false; //Preventing spam

  ThemeProvider()
    : _isDarkMode =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;

  ThemeData get currentTheme =>
      _isDarkMode ? ThemeData.dark() : ThemeData.light();

  void toggleTheme() {
    if (_isToggling) return; // Ignore rapid toggles
    _isToggling = true;

    // Schedule theme change in the next frame for a smoother transition
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _isDarkMode = !_isDarkMode;
      notifyListeners();
    });

    // Reset toggling state after a delay (matching animation time)
    Future.delayed(const Duration(milliseconds: 500), () {
      _isToggling = false;
    });
  }
}
