import 'package:flutter/material.dart';

class DailyEntryScreen extends StatelessWidget {
  const DailyEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_calendar_rounded, size: 48),
          SizedBox(height: 12),
          Text(
            'Saisi Quotidien',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text('Enregistrer les donnees quotidiennes de l\'elevage.'),
        ],
      ),
    );
  }
}
