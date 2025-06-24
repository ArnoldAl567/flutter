from flask import Flask, request, jsonify
import pandas as pd
import joblib
import shap
import numpy as np
import google.generativeai as genai

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

        # Configurar clave API de Gemini
        genai.configure(api_key="AIzaSyDKabLnbIVYFA9RReNCbqEb6HxW9_39S-o")
        modelo_ia = genai.GenerativeModel(
            model_name="gemini-2.0-flash",
            generation_config={"max_output_tokens": 60}
        )

        columnas = campos_requeridos
        entrada_df = pd.DataFrame([[datos[col] for col in columnas]], columns=columnas)
        entrada_scaled = scaler.transform(entrada_df)

        # Predicción
        probabilidades = modelo.predict_proba(entrada_scaled)[0]
        nivel_riesgo = int(np.argmax(probabilidades)) + 1
        probabilidad_nivel = round(probabilidades[nivel_riesgo - 1] * 100, 2)

        # Recomendación IA
        prompt = (
            f"Dame un tratamiento para preeclampsia con nivel de riesgo {nivel_riesgo} "
            f"y una probabilidad del {probabilidad_nivel}%. "
            "Responde brevemente en aproximadamente 20 palabras.Y omite las tildes al momento de responder"
        )
        respuesta = modelo_ia.generate_content(prompt)

        # Variables influyentes SHAP - SECCIÓN CORREGIDA
        variables_importantes = []
        try:
            print("Iniciando análisis SHAP...")
            
            # Crear explainer
            explainer = shap.TreeExplainer(modelo)
            
            # Calcular SHAP values
            shap_values = explainer.shap_values(entrada_scaled)
            
            print("SHAP values tipo:", type(shap_values))
            print("SHAP values shape:", np.array(shap_values).shape if hasattr(shap_values, 'shape') else "Lista con longitud:", len(shap_values))
            
            # CORRECCIÓN: Manejo adecuado según el tipo de modelo
            if isinstance(shap_values, list):
                # Para modelos multiclase (XGBoost, RandomForest)
                print(f"Modelo multiclase detectado. Clases: {len(shap_values)}")
                
                # Usar la clase predicha (con mayor probabilidad)
                clase_predicha = np.argmax(probabilidades)
                shap_array = shap_values[clase_predicha]
                print(f"Usando SHAP values para clase {clase_predicha}")
                
            else:
                # Para modelos binarios
                print("Modelo binario detectado")
                shap_array = shap_values
            
            # CORRECCIÓN: Verificar dimensiones
            if len(shap_array.shape) == 2:
                impacto = np.abs(shap_array[0])  # Primera muestra
            else:
                impacto = np.abs(shap_array)
                
            print("Impacto SHAP:", impacto)
            print("Impacto shape:", impacto.shape)
            
            # CORRECCIÓN: Verificar que hay suficientes variables
            num_variables = min(3, len(impacto))
            top_indices = np.argsort(impacto)[-num_variables:][::-1]
            
            # Calcular impacto total para porcentajes
            impacto_total = np.sum(impacto)
            print(f"Impacto total: {impacto_total}")
            
            # CORRECCIÓN: Verificar que impacto_total > 0
            if impacto_total > 0:
                for idx in top_indices:
                    porcentaje = (impacto[idx] / impacto_total) * 100
                    variables_importantes.append({
                        "variable": columnas[idx],
                        "porcentaje": round(float(porcentaje), 1)
                    })
                    print(f"Variable {columnas[idx]}: impacto={impacto[idx]}, porcentaje={porcentaje}%")
            else:
                print("Advertencia: Impacto total es 0")
                
        except Exception as e:
            print(f"Error detallado en SHAP: {str(e)}")
            print(f"Tipo de error: {type(e).__name__}")
            
            # FALLBACK: Si SHAP falla, usar importancia del modelo
            try:
                if hasattr(modelo, 'feature_importances_'):
                    importancias = modelo.feature_importances_
                    top_indices = np.argsort(importancias)[-3:][::-1]
                    
                    for idx in top_indices:
                        variables_importantes.append({
                            "variable": columnas[idx],
                            "porcentaje": round(float(importancias[idx] * 100), 1)
                        })
                    print("Usando feature_importances_ como fallback")
                else:
                    print("Modelo no tiene feature_importances_")
            except Exception as e2:
                print(f"Error en fallback: {str(e2)}")

        # Respuesta final
        response = {
            "nivel_riesgo": nivel_riesgo,
            "probabilidades": {
                "Riesgo_1": round(probabilidades[0] * 100, 2),
                "Riesgo_2": round(probabilidades[1] * 100, 2),
                "Riesgo_3": round(probabilidades[2] * 100, 2)
            },
            "variables_influyentes": variables_importantes,
            "recomendacion": respuesta.text.strip()
        }

        print("Respuesta final:", response)
        return jsonify(response)

    except Exception as e:
        print(f"Error general: {str(e)}")
        return jsonify({
            "error": str(e),
            "status": "error"
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=True)