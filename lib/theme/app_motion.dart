import 'package:flutter/material.dart';

class AppMotion {
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration reveal = Duration(milliseconds: 600);
  static const Duration pulse = Duration(milliseconds: 1200);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
}
