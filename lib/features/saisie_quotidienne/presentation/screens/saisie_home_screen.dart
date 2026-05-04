import 'package:flutter/material.dart';
import '../../../../features/gestions_des_lots_des_volailles/data/repositories/lot_repository_impl.dart';
import '../../../../features/gestions_des_lots_des_volailles/data/services/lot_service.dart';
import '../../../../features/gestions_des_lots_des_volailles/domain/entities/flock_lot.dart';
import 'daily_entries_screen.dart';

class SaisieHomeScreen extends StatelessWidget {
  SaisieHomeScreen({super.key});

  final _lotRepo = LotRepositoryImpl(LotService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saisie quotidiennes')),
      body: StreamBuilder<List<FlockLot>>(
        stream: _lotRepo.watchLots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final lots = (snapshot.data ?? []).where((l) => l.isActive).toList();
          if (lots.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Aucun lot actif à saisir.'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lots.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final lot = lots[i];
              return Card(
                child: ListTile(
                  title: Text(lot.identifier),
                  subtitle: Text(
                    '${lot.poultryTypeName} · ${lot.buildingName}',
                  ),
                  trailing: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DailyEntriesScreen(lot: lot),
                      ),
                    ),
                    child: const Text('Saisir'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
