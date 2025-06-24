
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'user_registration_form.dart'; 
import 'historial.dart';
import 'login_screen.dart';
import 'gestante_dashboard.dart';
import 'medico_dashboard.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaterniCare - Riesgo Prenatal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF667EEA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667EEA)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/gestante-dashboard': (context) => const GestanteDashboard(),
        '/medico-dashboard': (context) => const MedicoDashboard(),
        '/home': (context) => HomeScreen(), // Tu pantalla original
      },
    );
  }
}

// Tu HomeScreen original se mantiene igual para cuando necesites acceder a las funciones existentes
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _localCsvPath;

  @override
  void initState() {
    super.initState();
    initCsv();
  }

  Future<void> initCsv() async {
    Directory dir = await getApplicationDocumentsDirectory();
    _localCsvPath = '${dir.path}/dataset1.csv';
    File file = File(_localCsvPath);

    if (!await file.exists()) {
      final rawData = await rootBundle.loadString("assets/dataset1.csv");
      await file.writeAsString(rawData);
    }
  }

  void _addUser(List<dynamic> newUser) async {
    final file = File(_localCsvPath);
    final sink = file.openWrite(mode: FileMode.append);
    sink.writeln(ListToCsvConverter().convert([newUser]));
    await sink.flush();
    await sink.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MaterniCare - Registrar Diagnóstico'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context, 
                '/login', 
                (route) => false
              );
            },
          ),
        ],
      ),
      body: UserRegistrationForm(onSubmit: _addUser),
    );
  }
}