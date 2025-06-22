from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2 
from psycopg2.extras import DictCursor
import os

# Initialize the Flask App
app = Flask(__name__)
# Enable CORS to allow requests from your Flutter app
CORS(app)

# We will use the full DATABASE_URL environment variable provided by Render
DATABASE_URL = os.environ.get('DATABASE_URL')

def get_db_connection():
    """Creates a database connection."""
    conn = psycopg2.connect(DATABASE_URL)
    return conn

@app.route('/login', methods=['POST'])
def login():
    """Handles user login requests."""
    conn = None
    try:
        data = request.get_json()
        email = data.get('email')
        user_password = data.get('password')

        if not email or not user_password:
            return jsonify({"success": False, "message": "Email and password are required."}), 400

        conn = get_db_connection()
        # The 'cursor_factory' makes it easier to work with results
        cursor = conn.cursor(cursor_factory=DictCursor)

        # Note: PostgreSQL uses '%s' for placeholders, just like mysql-connector
        query = "SELECT password FROM users WHERE email = %s"
        cursor.execute(query, (email,))
        result = cursor.fetchone()

        if result:
            stored_password = result['password'] # Access by column name
            if user_password == stored_password:
                return jsonify({"success": True, "message": "Login successful."})

        return jsonify({"success": False, "message": "Invalid credentials."})

    except Exception as e:
        # Print the specific error to the logs for debugging
        print(f"An error occurred: {e}")
        return jsonify({"success": False, "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# This allows you to run the app by executing `python app.py`
if __name__ == '__main__':
    # host='0.0.0.0' makes the server accessible from your network
    app.run(host='0.0.0.0', port=5000, debug=True)