import 'package:flutter/material.dart';
import 'main.dart';
import 'historial.dart';

class GestanteDashboard extends StatefulWidget {
  const GestanteDashboard({super.key});

  @override
  State<GestanteDashboard> createState() => _GestanteDashboardState();
}

class _GestanteDashboardState extends State<GestanteDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667EEA), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Risk Indicator
                      _buildRiskIndicator(),
                      const SizedBox(height: 20),
                      
                      // Stats Grid
                      _buildStatsGrid(),
                      const SizedBox(height: 25),
                      
                      // Menu Items
                      Expanded(
                        child: ListView(
                          children: [
                            _buildMenuItem(
                              icon: Icons.edit_note,
                              title: 'Nueva Evaluación',
                              subtitle: 'Realizar nueva evaluación de riesgo',
                              onTap: () => _nuevaEvaluacion(),
                            ),
                            _buildMenuItem(
                              icon: Icons.bar_chart,
                              title: 'Mi Historial',
                              subtitle: 'Ver todas mis evaluaciones',
                              onTap: () => _verHistorial(),
                            ),
                            _buildMenuItem(
                              icon: Icons.local_hospital,
                              title: 'Mi Médico',
                              subtitle: 'Dr. Ana Pérez - Ginecología',
                              onTap: () => _verMedico(),
                            ),
                            _buildMenuItem(
                              icon: Icons.notifications,
                              title: 'Recordatorios',
                              subtitle: 'Próxima cita: 20 Jun 2025',
                              onTap: () => _verRecordatorios(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: const Text(
              '👩',
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'María González',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Text(
                //   'Gestante - 28 semanas',
                //   style: TextStyle(
                //     color: Colors.white70,
                //     fontSize: 12,
                //   ),
                // ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context, 
                '/login', 
                (route) => false
              );
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔔', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'Último Resultado: Nivel de Riesgo 2',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Evaluación del 15 Jun 2025 - 14:30',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('7', 'Evaluaciones'),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard('2', 'Nivel Actual'),
        ),
      ],
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.blue[50],
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF667EEA),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _nuevaEvaluacion() {
    // Navegar a tu UserRegistrationForm existente
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void _verHistorial() {
    // Navegar a tu historial existente
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistorialDiagnosticos()),
    );
  }

  void _verMedico() {
    // Implementar vista de médico
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vista de médico en desarrollo')),
    );
  }

  void _verRecordatorios() {
    // Implementar recordatorios
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recordatorios en desarrollo')),
    );
  }
}