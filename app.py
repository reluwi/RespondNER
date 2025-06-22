from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
import os

# Initialize the Flask App
app = Flask(__name__)
# Enable CORS to allow requests from your Flutter app
CORS(app)

# Database configuration
db_config = {
    'host': os.environ.get('DB_HOST'),
    'user': os.environ.get('DB_USER'),
    'password': os.environ.get('DB_PASSWORD'),
    'database': os.environ.get('DB_DATABASE')
}

@app.route('/login', methods=['POST'])
def login():
    """Handles user login requests."""
    conn = None
    cursor = None
    try:
        # Get JSON data from the request body
        data = request.get_json()
        if not data or 'email' not in data or 'password' not in data:
            return jsonify({"success": False, "message": "Email and password are required."}), 400

        email = data['email']
        user_password = data['password']

        # Connect to the database
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        # Use a parameterized query to prevent SQL injection
        query = "SELECT password FROM users WHERE email = %s"
        cursor.execute(query, (email,))

        # Fetch the result
        result = cursor.fetchone()

        if result:
            db_password = result[0]
            # Verify the password (replace with hash check in a real app)
            if user_password == db_password:
                return jsonify({"success": True, "message": "Login successful."})
            else:
                return jsonify({"success": False, "message": "Invalid credentials."})
        else:
            # User not found
            return jsonify({"success": False, "message": "Invalid credentials."})

    except Error as e:
        print(f"Database error: {e}")
        return jsonify({"success": False, "message": "A database error occurred."}), 500
    except Exception as e:
        print(f"An error occurred: {e}")
        return jsonify({"success": False, "message": "An internal server error occurred."}), 500
    finally:
        # Ensure the connection is closed
        if cursor:
            cursor.close()
        if conn and conn.is_connected():
            conn.close()

# This allows you to run the app by executing `python app.py`
if __name__ == '__main__':
    # host='0.0.0.0' makes the server accessible from your network
    app.run(host='0.0.0.0', port=5000, debug=True)