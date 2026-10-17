import 'package:flutter/widgets.dart';

class Responsive {
  Responsive._();

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static bool isTablet(BuildContext context) => width(context) >= 700;

  static bool isWide(BuildContext context) => width(context) >= 1000;

  static int gridColumns(BuildContext context) {
    final screenWidth = width(context);

    if (screenWidth >= 1100) return 5;
    if (screenWidth >= 800) return 4;
    if (screenWidth >= 600) return 3;

    return 2;
  }
}
