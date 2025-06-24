import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  String _selectedUserType = '';

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate() && _selectedUserType.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'correo': _emailController.text.trim(),
          'contrasena': _passwordController.text.trim(),
          'numero': _numeroController.text.trim(),
          'tipo_usuario': _selectedUserType,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        Navigator.pop(context); // Vuelve a la pantalla de login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Error al registrar')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de usuario")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Nombre", _nombreController),
              const SizedBox(height: 15),
              _buildTextField("Apellido", _apellidoController),
              const SizedBox(height: 15),
              _buildTextField("Correo", _emailController),
              const SizedBox(height: 15),
              _buildTextField("Contraseña", _passwordController, isPassword: true),
              const SizedBox(height: 15),
              _buildTextField("Número", _numeroController),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildTypeButton("gestante", "🤱"),
                  const SizedBox(width: 10),
                  _buildTypeButton("medico", "👩‍⚕️"),
                ],
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _registerUser,
                child: const Text("Registrarse"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
    );
  }

  Widget _buildTypeButton(String type, String emoji) {
    final selected = _selectedUserType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedUserType = type),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '$emoji ${type[0].toUpperCase()}${type.substring(1)}',
              style: TextStyle(color: selected ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
