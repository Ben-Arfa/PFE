import 'package:flutter/material.dart';
import 'package:kiwo/shared/presentation/theme/theme_provider.dart';

class ProfileSectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileSectionWidget({
    required this.title,
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: t.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
