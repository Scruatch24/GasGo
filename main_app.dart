// lib/screens/main_app.dart
import 'package:flutter/material.dart';
import '../auth_service.dart';
import 'driver/driver_main_screen.dart';
import 'owner/owner_main_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return FutureBuilder<String?>(
      future: authService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.local_gas_station,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  CircularProgressIndicator(color: Color(0xFF1E88E5)),
                ],
              ),
            ),
          );
        }
        
        final role = snapshot.data ?? 'driver';
        
        if (role == 'owner') {
          return OwnerMainScreen();
        } else {
          return DriverMainScreen();
        }
      },
    );
  }
}