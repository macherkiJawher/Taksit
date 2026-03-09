import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_utilisateurs_screen.dart';
import 'admin_echeanciers_screen.dart';
import 'admin_graphiques_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _index = 0;

  final _screens = const [
    AdminDashboardScreen(),
    AdminUtilisateursScreen(),
    AdminEcheancierScreen(),
    AdminGraphiquesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: "Utilisateurs"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: "Crédits"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Graphiques"),
        ],
      ),
    );
  }
}