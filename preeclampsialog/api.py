from flask import Flask, request, jsonify
import joblib
import numpy as np

app = Flask(__name__)

# Cargar modelo y scaler
modelo = joblib.load("modelo_preeclampsia.joblib")
scaler = joblib.load("scaler_preeclampsia.pkl")

@app.route("/predict", methods=["POST"])
def predict():
    datos = request.get_json()
    
    try:
        # Verificar campos requeridos
        campos_requeridos = [
            "embarazos", "partos_viables", "edad_gestacional", "edad",
            "imc", "diabetes", "hipertension", "presion_sistolica",
            "presion_diastolica", "hemoglobina"
        ]
        
        if not all(campo in datos for campo in campos_requeridos):
            faltantes = [campo for campo in campos_requeridos if campo not in datos]
            return jsonify({
                "error": f"Campos requeridos faltantes: {faltantes}",
                "status": "error"
            }), 400

        # Preparar datos de entrada
        entrada = np.array([[
            datos["embarazos"],
            datos["partos_viables"],
            datos["edad_gestacional"],
            datos["edad"],
            datos["imc"],
            datos["diabetes"],
            datos["hipertension"],
            datos["presion_sistolica"],
            datos["presion_diastolica"],
            datos["hemoglobina"]
        ]])

        # Escalar los datos
        entrada_scaled = scaler.transform(entrada)

        # Realizar predicción
        probabilidades = modelo.predict_proba(entrada_scaled)[0]
        nivel_riesgo = int(np.argmax(probabilidades)) + 1  # Convertir 0,1,2 a 1,2,3
        confianza = round(np.max(probabilidades) * 100, 2)

        # Generar respuesta
        response = {
            "nivel_riesgo": nivel_riesgo,
            "probabilidades": {
                "Riesgo_1": round(probabilidades[0] * 100, 2),
                "Riesgo_2": round(probabilidades[1] * 100, 2),
                "Riesgo_3": round(probabilidades[2] * 100, 2)
            },
            #"confianza": confianza,
            "recomendacion": generar_tratamiento(nivel_riesgo, probabilidades),
            "status": "success"
        }

        return jsonify(response)

    except Exception as e:
        return jsonify({
            "error": str(e),
            "status": "error"
        }), 500

def generar_tratamiento(nivel, probabilidades):
    diferencia = abs(probabilidades[0] - probabilidades[2])
    
    if nivel == 1:
        if probabilidades[0] >= 0.8:
            return "Control prenatal estandar con visitas mensuales."
        return "Control prenatal con monitoreo cada 3 semanas."
    
    elif nivel == 2:
        if diferencia < 0.2:
            return "Control quincenal con pruebas complementarias."
        return "Evaluacion medica especializada cada 2 semanas."
    
    elif nivel == 3:
        if probabilidades[2] >= 0.85:
            return "Referencia urgente a especialista. Considerar hospitalizacion."
        return "Atención especializada con control semanal."
    
    return "Recomendacion no disponible para este nivel de riesgo."

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)