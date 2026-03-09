import 'package:flutter/material.dart';
import '../../models/register_request.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String role = "CLIENT";

  final nomCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final telCtrl = TextEditingController();
  final boutiqueCtrl = TextEditingController();
  final adresseCtrl = TextEditingController();

  void register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final req = RegisterRequest(
        nomComplet: nomCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        motDePasse: passCtrl.text.trim(),
        telephone: telCtrl.text.trim(),
        role: role,
        nomBoutique: role == "PRESTATAIRE" ? boutiqueCtrl.text.trim() : null,
        adresseBoutique: role == "PRESTATAIRE" ? adresseCtrl.text.trim() : null,
      );

      final msg = await AuthService.register(req);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomCtrl,
                decoration: const InputDecoration(labelText: "Nom complet"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Nom obligatoire" : null,
              ),

              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Email obligatoire";
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                    return "Format email invalide";
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: "Mot de passe"),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Mot de passe obligatoire";
                  if (v.length < 6) return "Minimum 6 caractères";
                  return null;
                },
              ),

              TextFormField(
                controller: telCtrl,
                decoration: const InputDecoration(labelText: "Téléphone"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Téléphone obligatoire" : null,
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: role,
                decoration: const InputDecoration(labelText: "Rôle"),
                items: const [
                  DropdownMenuItem(value: "CLIENT", child: Text("Client")),
                  DropdownMenuItem(value: "PRESTATAIRE", child: Text("Prestataire")),
                ],
                onChanged: (v) => setState(() => role = v!),
              ),

              if (role == "PRESTATAIRE") ...[
                TextFormField(
                  controller: boutiqueCtrl,
                  decoration: const InputDecoration(labelText: "Nom boutique"),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Champ obligatoire" : null,
                ),
                TextFormField(
                  controller: adresseCtrl,
                  decoration: const InputDecoration(labelText: "Adresse boutique"),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Champ obligatoire" : null,
                ),
              ],

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: register,
                  child: const Text("S'inscrire"),
                ),
              ),

              const SizedBox(height: 15),

            // 🔗 Lien vers LOGIN
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Déjà un compte ? "),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text("Se connecter"),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}
