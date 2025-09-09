// lib/screens/owner/edit_station_screen.dart
import 'package:flutter/material.dart';
import '../../models/station.dart';
import '../../l10n/app_localizations.dart';

class EditStationScreen extends StatelessWidget {
  final Station station;

  const EditStationScreen({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.edit ?? 'Edit Station'),
        backgroundColor: Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFF1E88E5).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  size: 50,
                  color: Color(0xFF1E88E5),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Edit ${station.name}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Station editing form\ncoming in Phase 1',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}