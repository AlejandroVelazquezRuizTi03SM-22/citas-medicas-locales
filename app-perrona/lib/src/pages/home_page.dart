import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Stream<String> _nameStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 'Usuario';
          final data = doc.data() ?? {};
          final n = (data['name'] as String?)?.trim();
          return (n == null || n.isEmpty) ? 'Usuario' : n;
        });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Sesión no encontrada')));
    }

    return StreamBuilder<String>(
      stream: _nameStream(user.uid),
      builder: (context, snap) {
        final name = snap.data;
        final loading =
            snap.connectionState == ConnectionState.waiting && name == null;

        return Scaffold(
          backgroundColor: const Color(0xFFEFEFEF),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 2,
            title: const Text(
              'PetCare',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                tooltip: 'Cerrar sesión',
                icon: const Icon(Icons.logout),
                onPressed: () => FirebaseAuth.instance.signOut(),
              ),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Header de bienvenida
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(
                                    Icons.pets,
                                    size: 28,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hola, ${name ?? 'Usuario'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey[800],
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Bienvenido a PetCare Feeder & Health',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Grid de accesos rápidos (placeholders)
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, c) {
                                final isWide = c.maxWidth > 900;
                                final isMedium = c.maxWidth > 600;
                                final crossAxisCount = isWide
                                    ? 4
                                    : (isMedium ? 2 : 1);

                                return GridView.count(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 1.2,
                                  children: const [
                                    _HomeCard(
                                      icon: Icons.monitor_heart,
                                      title: 'Salud',
                                      subtitle: 'Indicadores básicos',
                                    ),
                                    _HomeCard(
                                      icon: Icons.restaurant,
                                      title: 'Comedero',
                                      subtitle: 'Control y raciones',
                                    ),
                                    _HomeCard(
                                      icon: Icons.map,
                                      title: 'Ubicación',
                                      subtitle: 'GPS del collar',
                                    ),
                                    _HomeCard(
                                      icon: Icons.notifications_active,
                                      title: 'Alertas',
                                      subtitle: 'IA y recordatorios',
                                    ),
                                    _HomeCard(
                                      icon: Icons.analytics,
                                      title: 'Dashboard',
                                      subtitle: 'Tendencias y registros',
                                    ),
                                    _HomeCard(
                                      icon: Icons.settings,
                                      title: 'Ajustes',
                                      subtitle: 'Cuenta y seguridad',
                                    ),
                                    _HomeCard(
                                      icon: Icons.chat_bubble_outline,
                                      title: 'Chatbot',
                                      subtitle: 'Ayuda inmediata',
                                    ),
                                    _HomeCard(
                                      icon: Icons.shopping_bag_outlined,
                                      title: 'Entregas',
                                      subtitle: 'Reposición automática',
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {}, // TODO: navega al módulo correspondiente
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: Colors.grey[800]),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 6),
              Text(subtitle, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
