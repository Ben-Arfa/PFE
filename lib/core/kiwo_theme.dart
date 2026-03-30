// lib/core/kiwo_theme.dart
//
// Wrapper universel : écoute ThemeProvider et rebuild l'enfant.
// Usage : KiwoThemeWrapper(child: MonEcran())
// Ou dans build() : final t = ThemeProvider.instance;

import 'package:flutter/material.dart';
import 'theme_provider.dart';

class KiwoThemeWrapper extends StatefulWidget {
  final Widget child;
  const KiwoThemeWrapper({required this.child, super.key});

  @override
  State<KiwoThemeWrapper> createState() => _KiwoThemeWrapperState();
}

class _KiwoThemeWrapperState extends State<KiwoThemeWrapper> {
  @override
  void initState() {
    super.initState();
    ThemeProvider.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    ThemeProvider.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
