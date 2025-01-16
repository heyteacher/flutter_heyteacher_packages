import 'package:flutter/material.dart';

class ThemeSwitcher extends InheritedWidget {
  final ThemeSwitcherWidgetState data;

  const ThemeSwitcher({
    super.key,
    required this.data,
    required super.child,
  });

  static ThemeSwitcherWidgetState of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<ThemeSwitcher>()
            as ThemeSwitcher)
        .data;
  }

  @override
  bool updateShouldNotify(ThemeSwitcher oldWidget) {
    return this != oldWidget;
  }
}

class ThemeSwitcherWidget extends StatefulWidget {
  final ThemeData initialTheme;
  final Widget child;

  const ThemeSwitcherWidget(
      {super.key, required this.initialTheme, required this.child});

  @override
  ThemeSwitcherWidgetState createState() => ThemeSwitcherWidgetState();
}

class ThemeSwitcherWidgetState extends State<ThemeSwitcherWidget> {
  ThemeData? themeData;

  void switchTheme(ThemeData theme) {
    setState(() {
      themeData = theme;
    });
  }

  void switchInitialTheme() {
    setState(() {
      themeData = widget.initialTheme;
    });
  }

  void switchColorSurface(Color surface) {
    setState(() {
      if (themeData != null) {
        themeData = themeData!.copyWith(
            colorScheme: themeData!.colorScheme.copyWith(surface: surface));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    themeData = themeData ?? widget.initialTheme;
    return ThemeSwitcher(
      data: this,
      child: widget.child,
    );
  }
}
