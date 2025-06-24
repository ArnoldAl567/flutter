
import 'package:flutter/material.dart';
import 'main.dart';

class MedicoDashboard extends StatefulWidget {
  const MedicoDashboard({super.key});

  @override
  State<MedicoDashboard> createState() => _MedicoDashboardState();
}

class _MedicoDashboardState extends State<MedicoDashboard> {
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
                      // Stats Grid
                      _buildStatsGrid(),
                      const SizedBox(height: 25),
                      
                      // Menu Items
                      _buildMenuItem(
                        icon: Icons.search,
                        title: 'Buscar Paciente',
                        subtitle: 'Por nombre, DNI o código',
                        onTap: () => _buscarPaciente(),
                      ),
                      _buildMenuItem(
                        icon: Icons.analytics,
                        title: 'Estadísticas',
                        subtitle: 'Análisis de riesgo general',
                        onTap: () => _verEstadisticas(),
                      ),
                      _buildMenuItem(
                        icon: Icons.admin_panel_settings,
                        title: 'Panel Administrativo',
                        subtitle: 'Acceder a funciones completas',
                        onTap: () => _panelAdmin(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Patients List
                      Expanded(child: _buildPatientsList()),
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
              '👩‍⚕️',
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dra. Ana Pérez',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Ginecología - CMP 12345',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
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

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('24', 'Pacientes'),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard('3', 'Riesgo Alto'),
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

  Widget _buildPatientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pacientes Recientes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: ListView(
            children: [
              _buildPatientCard(
                'María González',
                '28 semanas • Última evaluación: 15 Jun',
                'Riesgo 2',
                Colors.orange,
              ),
              _buildPatientCard(
                'Carmen López',
                '32 semanas • Última evaluación: 14 Jun',
                'Riesgo 2',
                Colors.orange,
              ),
              _buildPatientCard(
                'Rosa Martín',
                '24 semanas • Última evaluación: 13 Jun',
                'Riesgo 1',
                Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(String name, String info, String risk, Color riskColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  risk,
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            info,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _buscarPaciente() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Búsqueda de pacientes en desarrollo')),
    );
  }

  void _verEstadisticas() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estadísticas en desarrollo')),
    );
  }

  void _panelAdmin() {
    // Navegar a tu HomeScreen existente (panel administrativo)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }
}