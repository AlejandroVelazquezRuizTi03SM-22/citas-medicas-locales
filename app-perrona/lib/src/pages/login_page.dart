import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final auth = AuthService();

  bool loading = false;
  String? error;
  bool isRegister = false; // <-- alterna entre login y registro

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      if (isRegister) {
        await auth.signUpWithEmail(
          emailCtrl.text.trim(),
          passCtrl.text,
          nameCtrl.text.trim(),
        );
      } else {
        await auth.signInWithEmail(emailCtrl.text.trim(), passCtrl.text);
      }
    } on Exception catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await auth.signInWithGoogle();
      // Opcional: si es la primera vez con Google, podrías
      // crear el doc users/{uid} con displayName:
      final u = FirebaseAuth.instance.currentUser;
      if (u != null) {
        await FirebaseFirestore.instance.collection('users').doc(u.uid).set({
          'name': u.displayName ?? 'Usuario',
          'email': u.email,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      setState(() => error = 'No se pudo iniciar con Google');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // … usa el layout full-screen que ya tenías, solo agregamos el toggle y el campo nombre …
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PetCare Feeder & Health',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 24),

                // Toggle simple
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Iniciar sesión')),
                    ButtonSegment(value: true, label: Text('Crear cuenta')),
                  ],
                  selected: {isRegister},
                  onSelectionChanged: (s) =>
                      setState(() => isRegister = s.first),
                ),
                const SizedBox(height: 16),

                if (isRegister) ...[
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      loading
                          ? 'Cargando…'
                          : (isRegister ? 'Crear cuenta' : 'Iniciar sesión'),
                    ),
                  ),
                ),
                const Divider(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.login),
                    onPressed: loading ? null : _loginWithGoogle,
                    label: const Text('Continuar con Google'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
