from flask import Flask, request, jsonify
from flask_cors import CORS
from db import get_connection
from werkzeug.security import generate_password_hash

app = Flask(__name__)
CORS(app)

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    correo = data.get('correo')
    contrasena = data.get('contrasena')
    tipo = data.get('tipo_usuario')

    try:
        conn = get_connection()
        with conn.cursor() as cursor:
            sql = "SELECT * FROM usuarios WHERE correo=%s AND contrasena=%s AND tipo=%s"
            cursor.execute(sql, (correo, contrasena, tipo))
            user = cursor.fetchone()
            if user:
                return jsonify({"success": True, "tipo": user['tipo'], "id": user['id']})
            else:
                return jsonify({"success": False, "message": "Credenciales inválidas"}), 401
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    nombre = data.get('nombre')
    apellido = data.get('apellido')
    correo = data.get('correo')
    contrasena = data.get('contrasena')
    numero = data.get('numero')
    tipo = data.get('tipo_usuario')

    if not all([nombre, apellido, correo, contrasena, numero, tipo]):
        return jsonify({"success": False, "error": "Faltan campos obligatorios"}), 400

    try:
        conn = get_connection()
        with conn.cursor() as cursor:
            sql = "INSERT INTO usuarios (nombre, apellido, correo, contrasena, numero, tipo) VALUES (%s, %s, %s, %s, %s, %s)"
            cursor.execute(sql, (nombre, apellido, correo, contrasena, numero, tipo))
            conn.commit()
            return jsonify({"success": True, "message": "Usuario registrado correctamente"}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/')
def home():
    return 'API de login activa'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
