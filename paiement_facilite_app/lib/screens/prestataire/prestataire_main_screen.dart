import 'package:flutter/material.dart';
import 'prestataire_home.dart';
import 'creer_echeancier_screen.dart';
import 'prestataire_echeanciers_screen.dart';

class PrestataireMainScreen extends StatefulWidget {
  const PrestataireMainScreen({super.key});

  @override
  State<PrestataireMainScreen> createState() => _PrestataireMainScreenState();
}

class _PrestataireMainScreenState extends State<PrestataireMainScreen> {
  int _index = 1;

  final screens = const [
    CreerEcheancierScreen(),
    PrestataireHome(),
    PrestataireEcheanciersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: "Créer",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Tous",
          ),
        ],
      ),
    );
  }
}
