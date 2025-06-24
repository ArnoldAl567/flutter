// user_registration_form.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'db_helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class UserRegistrationForm extends StatefulWidget {
  final Function(List<String>) onSubmit;

  const UserRegistrationForm({super.key, required this.onSubmit});

  @override
  State<UserRegistrationForm> createState() => _UserRegistrationFormState();
}

class _UserRegistrationFormState extends State<UserRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController embarazoController = TextEditingController();
  final TextEditingController partoController = TextEditingController();
  final TextEditingController edadgestacionalController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController imcController = TextEditingController();
  final TextEditingController diabetesController = TextEditingController();
  final TextEditingController hipertensionController = TextEditingController();
  final TextEditingController presionsistolicaController = TextEditingController();
  final TextEditingController presiondiastolicaController = TextEditingController();
  final TextEditingController hemoglobinaController = TextEditingController();
  final TextEditingController nivelriesgoController = TextEditingController();
  final tratamientoController = TextEditingController();

String _nivelRiesgo = '';
Map<String, dynamic> _probabilidades = {};
String _recomendacion = '';
List<Map<String, dynamic>> _variablesInfluyentes = [];
bool _diagnosticoListo = false;


String _formatearNombreVariable(String variable) {
  final Map<String, String> nombres = {
    'embarazos': 'Embarazos',
    'partos_viables': 'Partos viables',
    'edad_gestacional': 'Edad gestacional',
    'edad': 'Edad',
    'imc': 'IMC',
    'diabetes': 'Diabetes',
    'hipertension': 'Hipertensión',
    'presion_sistolica': 'Presión sistólica',
    'presion_diastolica': 'Presión diastólica',
    'hemoglobina': 'Hemoglobina',
  };
  
  return nombres[variable] ?? variable;
}


  String? imcWarning; 
  String? pdWarning; 
  String? psWarning; 
  String? hemoglobinaWarning; 
  String? embarazoWarning;
  String? partoWarning;
  String? edadgestacionalWarning;
  String? edadWarning;

  // String _nivelRiesgo = '';
  // Map<String, dynamic> _probabilidades = {};
  

  String _diabetesDropdownValue = "0"; 
  String _hipertensionDropdownValue = "0"; 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          
        children: [
          Text("Registrar Nuevo Diagnostico", style: Theme.of(context).textTheme.titleLarge),

        TextFormField(
          controller: embarazoController,
          decoration: InputDecoration(
            labelText: 'N° embarazos',
            hintText: 'Ej: 4',
            errorText: embarazoWarning, // Muestra la advertencia como texto de error
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Solo números enteros
          ],
          onChanged: (value) {
            if (value.isNotEmpty) {
              final numero = int.tryParse(value) ?? 0;
              if (numero > 8) {
                setState(() {
                  embarazoWarning = '⚠️ El valor máximo recomendado es 8';
                });
              } else {
                setState(() {
                  embarazoWarning = null; // Limpia la advertencia
                });
              }
            } else {
              setState(() {
                embarazoWarning = null; // Limpia la advertencia si el campo está vacío
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese un número';
            }
            if (int.tryParse(value) == null) {
              return 'Solo se permiten números';
            }
            if (int.parse(value) < 0) {
              return 'No se permiten valores negativos';
            }
            return null; // Permite registrar cualquier número válido
          },
        ),

        TextFormField(
          controller: partoController,
          decoration: InputDecoration(
            labelText: 'N° partos viables',
            hintText: 'Ej: 2',
            errorText: partoWarning, // Para mostrar advertencias/errores
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Solo números enteros
          ],
          onChanged: (value) {
            if (value.isNotEmpty) {
              final partos = int.tryParse(value) ?? 0;
              final embarazos = int.tryParse(embarazoController.text) ?? 0;
              
              if (partos > 8) {
                setState(() {
                  partoWarning = '⚠️ El valor máximo recomendado es 8';
                });
              } else if (partos > embarazos) {
                setState(() {
                  partoWarning = '❌ No puede ser mayor al número de embarazos';
                });
              } else {
                setState(() {
                  partoWarning = null;
                });
              }
            } else {
              setState(() {
                partoWarning = null;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese un número';
            }
            if (int.tryParse(value) == null) {
              return 'Solo se permiten números enteros';
            }
            
            final partos = int.parse(value);
            final embarazos = int.tryParse(embarazoController.text) ?? 0;
            
            if (partos < 0) {
              return 'No se permiten valores negativos';
            }
            if (partos > embarazos) {
              return 'No puede ser mayor al número de embarazos'; // Error que bloquea el registro
            }
            return null;
          },
        ),

        TextFormField(
          controller: edadgestacionalController,
          decoration: const InputDecoration(
            labelText: 'Edad Gestacional (semanas)',
            hintText: 'Ej: 32.5',
          ),
          forceErrorText: edadgestacionalWarning,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')), // Solo números y 1 decimal
          ],
          onChanged: (value) {
            if (value.isNotEmpty) {
              final numericValue = double.tryParse(value);
              if (numericValue == null) {
                setState(() => edadgestacionalWarning = 'Solo se permiten números');
              } else if (numericValue < 20 || numericValue > 40) {
                setState(() => edadgestacionalWarning = 'Rango recomendado: 20-40 semanas');
              } else {
                setState(() => edadgestacionalWarning = null); // Valor válido
              }
            } else {
              setState(() => edadgestacionalWarning = null); // Campo vacío
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese la edad gestacional';
            }
            final numericValue = double.tryParse(value);
            if (numericValue == null) {
              return 'Solo se permiten números';
            }
            if (numericValue <= 0) {
              return 'Solo valores positivos';
            }
            if (numericValue < 20 || numericValue > 40) {
              return 'Debe ser entre 20 y 40 semanas'; // Bloquea el registro
            }
            return null; // Valor válido
          },
        ),

      TextFormField(
        controller: edadController,
        decoration: InputDecoration(
          labelText: 'Edad',
          hintText: 'Ej: 25',
          errorText: edadWarning, // Muestra la advertencia como texto de error
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Solo números enteros
          LengthLimitingTextInputFormatter(2), // Máximo 2 dígitos
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            final edad = int.tryParse(value) ?? 0;
            if (edad < 12 || edad > 48) {
              setState(() {
                edadWarning = '⚠️ Rango recomendado: 12-48 años';
              });
            } else {
              setState(() {
                edadWarning = null; // Limpia la advertencia
              });
            }
          } else {
            setState(() {
              edadWarning = null; // Limpia la advertencia si el campo está vacío
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ingrese la edad';
          }
          if (int.tryParse(value) == null) {
            return 'Solo se permiten números enteros';
          }
          if (int.parse(value) <= 0) {
            return 'No se permiten valores negativos';
          }
          return null; // Permite registrar cualquier número válido
        },
      ),

            TextFormField(
              controller: imcController,
              decoration: InputDecoration(
                labelText: 'IMC',
                hintText: 'Ej: 25.5',
                errorText: imcWarning, // Muestra la advertencia como un "error" (pero no bloquea)
              ),
              inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')), // Solo números y 1 decimal
              ],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final numericValue = double.tryParse(value);
                if (numericValue == null) {
                  imcWarning = null; // No mostrar advertencia si no es un número
                } else if (numericValue < 18.5) {
                  imcWarning = '⚠️ IMC bajo (menor a 18.5)';
                } else if (numericValue > 30) {
                  imcWarning = '⚠️ IMC alto (mayor a 30)';
                } else {
                  imcWarning = null; // No hay advertencia si está en rango normal
                }
                setState(() {}); 
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el IMC';
                }
                if (double.tryParse(value) == null) {
                  return 'Solo se permiten números';
                }
                return null; // Permite cualquier valor numérico
              },
            ),
            
            const SizedBox(height: 30),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '¿Tiene Diabetes?',
                border: OutlineInputBorder(),
              ),
              value: _diabetesDropdownValue,
              items: const [
                DropdownMenuItem(value: "0", child: Text("No")),
                DropdownMenuItem(value: "1", child: Text("Sí")),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _diabetesDropdownValue = newValue!; // '!' porque sabemos que no será null
                  diabetesController.text = newValue;
                });
              },
              validator: (value) => value == null ? 'Seleccione una opción' : null,
            ),

            const SizedBox(height: 30),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '¿Tiene un historial de hipertension?',

                border: OutlineInputBorder(),
              ),
              value: _hipertensionDropdownValue,
              items: const [
                DropdownMenuItem(value: "0", child: Text("No")),
                DropdownMenuItem(value: "1", child: Text("Sí")),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _hipertensionDropdownValue = newValue!; // '!' porque sabemos que no será null
                  hipertensionController.text = newValue;
                });
              },
              validator: (value) => value == null ? 'Seleccione una opción' : null,
            ),


            TextFormField(
              controller: presionsistolicaController,
              decoration: InputDecoration(
                labelText: 'Presion arterial sistolica (mmHg)',
                hintText: 'Ej: 140',
                errorText: psWarning, // Muestra la advertencia como un "error" (pero no bloquea)
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')), // Solo números y 1 decimal
              ],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final numericValue = double.tryParse(value);
                if (numericValue == null) {
                  psWarning = null; // No mostrar advertencia si no es un número
                } else if (numericValue >=140 && numericValue <= 159) {
                  psWarning = '⚠️ Presion alta (140-159)';
                } else if (numericValue >= 160) {
                  psWarning = '⚠️ Presion muy alta (mayor a 160)';
                } else {
                  psWarning = null; // No hay advertencia si está en rango normal
                }
                setState(() {}); 
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese la presion arterial sistolica';
                }
                if (double.tryParse(value) == null) {
                  return 'Solo se permiten números';
                }
                return null; // Permite cualquier valor numérico
              },
            ),

            TextFormField(
              controller: presiondiastolicaController,
              decoration: InputDecoration(
                labelText: 'Presion arterial diastolica (mmHg)',
                hintText: 'Ej: 100',
                errorText: pdWarning, // Muestra la advertencia como un "error" (pero no bloquea)
              ),
              inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')), // Solo números y 1 decimal
              ],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final numericValue = double.tryParse(value);
                if (numericValue == null) {
                  pdWarning = null; // No mostrar advertencia si no es un número
                } else if (numericValue >=90 && numericValue <= 109) {
                  pdWarning = '⚠️ Presion alta (90-109)';
                } else if (numericValue >= 110) {
                  pdWarning = '⚠️ Presion muy alta (mayor a 110)';
                } else {
                  pdWarning = null; // No hay advertencia si está en rango normal
                }
                setState(() {}); 
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese la presion arterial sistolica';
                }
                if (double.tryParse(value) == null) {
                  return 'Solo se permiten números';
                }
                return null; // Permite cualquier valor numérico
              },
            ),

            TextFormField(
              controller: hemoglobinaController,
              decoration: InputDecoration(
                labelText: 'Hemoglobina (g/dl)',
                hintText: 'Ej: 13',
                errorText: hemoglobinaWarning, 
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')), // Solo números y 1 decimal
              ],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final numericValue = double.tryParse(value);
                if (numericValue == null) {
                  hemoglobinaWarning = null; 
                } else if (numericValue < 11) {
                  hemoglobinaWarning = '⚠️ Anemia materna (menor a 11)';
                } else {
                  hemoglobinaWarning = null; 
                }
                setState(() {}); 
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese la presion arterial sistolica';
                }
                if (double.tryParse(value) == null) {
                  return 'Solo se permiten números';
                }
                return null; // Permite cualquier valor numérico
              },
            ),

          const SizedBox(height: 20),
            
ElevatedButton(
            onPressed: () async {
              final form = _formKey.currentState!;
              if (form.validate()) {
                try {
                  final newUser = {
                    "embarazos": int.tryParse(embarazoController.text) ?? 0,
                    "partos_viables": int.tryParse(partoController.text) ?? 0,
                    "edad_gestacional": double.tryParse(edadgestacionalController.text) ?? 0.0,
                    "edad": int.tryParse(edadController.text) ?? 0,
                    "imc": double.tryParse(imcController.text) ?? 0.0,
                    "diabetes": int.tryParse(diabetesController.text) ?? 0,
                    "hipertension": int.tryParse(hipertensionController.text) ?? 0,
                    "presion_sistolica": double.tryParse(presionsistolicaController.text) ?? 0.0,
                    "presion_diastolica": double.tryParse(presiondiastolicaController.text) ?? 0.0,
                    "hemoglobina": double.tryParse(hemoglobinaController.text) ?? 0.0,
                  };

                  final resultado = await obtenerNivelRiesgo(newUser);
                  print("Resultado completo: $resultado");

                  setState(() {
                    _nivelRiesgo = resultado['nivel_riesgo'];
                    _probabilidades = resultado['probabilidades'];
                    _recomendacion = resultado['recomendacion']; // Cambio de 'tratamiento' a 'recomendacion'
                    _variablesInfluyentes = resultado['variables_influyentes']; // Nueva variable
                    _diagnosticoListo = true; // mostrar botón guardar
                  });

                } catch (e) {
                  print("Error en la solicitud: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al obtener diagnóstico: $e')),
                  );
                }

                form.save();
                embarazoController.clear();
                partoController.clear();
                edadgestacionalController.clear();
                edadController.clear();
                imcController.clear();
                diabetesController.clear();
                hipertensionController.clear();
                presionsistolicaController.clear();
                presiondiastolicaController.clear();
                hemoglobinaController.clear();

              }
            },
            child: const Text('Diagnosticar'),
          ),

          const SizedBox(height: 20),

          // RESULTADOS
          if (_diagnosticoListo) ...[
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🩺 Nivel de Riesgo: Nivel $_nivelRiesgo',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 16),

                    const Text('📊 Probabilidades por nivel:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Riesgo 1: ${_probabilidades['riesgo_1']}%',
                        style: const TextStyle(fontSize: 15)),
                    Text('Riesgo 2: ${_probabilidades['riesgo_2']}%',
                        style: const TextStyle(fontSize: 15)),
                    Text('Riesgo 3: ${_probabilidades['riesgo_3']}%',
                        style: const TextStyle(fontSize: 15)),

                    const SizedBox(height: 16),

                    const Text('🔍 Variables más influyentes:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    if (_variablesInfluyentes.isNotEmpty)
                      for (var variable in _variablesInfluyentes)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _formatearNombreVariable(variable['variable']),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              Text(
                                '${variable['porcentaje']}%',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                    else
                      const Text('No hay variables disponibles',
                          style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic)),

                    const SizedBox(height: 16),

                    const Text('💊 Recomendación de Tratamiento:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(_recomendacion, style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                final fecha = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                final hora = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

                final diagnostico = {
                      'nivel_riesgo': _nivelRiesgo,
                      'riesgo_1': double.tryParse(_probabilidades['riesgo_1'].toString()) ?? 0.0,
                      'riesgo_2': double.tryParse(_probabilidades['riesgo_2'].toString()) ?? 0.0,
                      'riesgo_3': double.tryParse(_probabilidades['riesgo_3'].toString()) ?? 0.0,
                      'fecha': fecha,
                      'hora': hora,
                      'tratamiento': _recomendacion,
                };

                await DBHelper.insertarDiagnostico(diagnostico);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Diagnóstico guardado exitosamente')),
                );
              },
              child: const Text('Guardar diagnóstico'),
            ),

          ],

        ],
        ),
      ),
    );
  }
}



Future<Map<String, dynamic>> obtenerNivelRiesgo(Map<String, dynamic> datosPaciente) async {
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5002/predict'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(datosPaciente),
    );

    if (response.statusCode == 200) {
      final respuesta = json.decode(response.body);
      debugPrint('Respuesta del servidor: $respuesta');

      // Procesar variables influyentes
      List<Map<String, dynamic>> variablesInfluyentes = [];
      if (respuesta['variables_influyentes'] != null) {
        variablesInfluyentes = List<Map<String, dynamic>>.from(
          respuesta['variables_influyentes'].map((variable) => {
            'variable': variable['variable'] ?? '',
            'porcentaje': variable['porcentaje'] ?? 0.0,
          })
        );
      }

      return {
        'nivel_riesgo': respuesta['nivel_riesgo']?.toString() ?? '0',
        'probabilidades': {
          'riesgo_1': respuesta['probabilidades']?['Riesgo_1'] ?? 0.0,
          'riesgo_2': respuesta['probabilidades']?['Riesgo_2'] ?? 0.0,
          'riesgo_3': respuesta['probabilidades']?['Riesgo_3'] ?? 0.0,
        },
        'variables_influyentes': variablesInfluyentes,
        'recomendacion': respuesta['recomendacion'] ?? "No disponible",
        'success': true,
      };
    } else {
      debugPrint('Error del servidor: ${response.statusCode}');
      debugPrint('Respuesta del servidor: ${response.body}');
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    debugPrint("Error en obtenerNivelRiesgo: $e");
    debugPrint("StackTrace: $stackTrace");
    
    // Retornar estructura de error consistente
    return {
      'nivel_riesgo': '0',
      'probabilidades': {
        'riesgo_1': 0.0,
        'riesgo_2': 0.0,
        'riesgo_3': 0.0,
      },
      'variables_influyentes': <Map<String, dynamic>>[],
      'recomendacion': "Error al obtener recomendación: $e",
      'success': false,
      'error': e.toString(),
    };
  }
}
  //http://10.0.2.2:5000/predict
  //https://preeclampsia-1.onrender.com/predict
  