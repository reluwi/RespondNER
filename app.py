from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2 
from psycopg2.extras import DictCursor
import os
import pandas as pd 

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

# --- NEW ENDPOINT TO FETCH USER DETAILS ---
@app.route('/get_user_details', methods=['GET'])
def get_user_details():
    """Fetches user details based on the email provided as a query parameter."""
    # Get the email from the URL query string (e.g., /get_user_details?email=test@example.com)
    email = request.args.get('email')

    if not email:
        return jsonify({"error": "Email parameter is required."}), 400

    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=DictCursor)
        
        # --- Select username AND is_admin ---
        cursor.execute("SELECT username, is_admin FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()

        if user:
            # --- Return both username and is_admin status ---
            return jsonify({
                "username": user['username'] if user['username'] else "User",
                "is_admin": user['is_admin']
            })
        else:
            return jsonify({"error": "User not found."}), 404

    except Exception as e:
        print(f"Get user details error: {e}")
        return jsonify({"error": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# --- NEW MOCK DATA ENDPOINT ---
@app.route('/get_mock_posts', methods=['GET'])
def get_mock_posts():
    """Reads test.csv and returns formatted mock data."""
    try:
        # Load the test data from the CSV file
        df = pd.read_csv('test.csv')
        
        # Take a random sample of 15 rows instead of the first 15.
        sample_size = 15
        if len(df) < sample_size:
            sample_df = df.sample(n=len(df))
        else:
            sample_df = df.sample(n=sample_size)
        
        posts_data = []
        
        # Fill any missing values in 'keyword' and 'location' with empty strings
        sample_df['keyword'] = sample_df['keyword'].fillna('')
        sample_df['location'] = sample_df['location'].fillna('')
        
        # Process each row to match the desired format
        for index, row in sample_df.iterrows():
            entities = []
            
            # Add location if it exists
            if row['location']:
                entities.append(f"[Location: {row['location']}]")
            
            # Add emergency type from 'keyword' if it exists
            if row['keyword']:
                # The keywords sometimes have '%20' for spaces, let's clean that up
                emergency_term = row['keyword'].replace('%20', ' ')
                entities.append(f"[Emergency: {emergency_term}]")
            
            # Create the final JSON object for this post
            post = {
                # We'll create a fake timestamp for display purposes
                "timestamp": f"2025-05-09 13:{59 - index}",
                "extractedPost": row['text'],
                "namedEntities": ", ".join(entities)
            }
            posts_data.append(post)
            
        return jsonify(posts_data)

    except FileNotFoundError:
        return jsonify({"error": "test.csv not found on the server."}), 404
    except Exception as e:
        print(f"An error occurred in /get_mock_posts: {e}")
        return jsonify({"error": "Failed to process mock data."}), 500

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

# --- NEW ENDPOINT TO FETCH ALL USER ACCOUNTS ---
@app.route('/get_all_users', methods=['GET'])
def get_all_users():
    """Fetches a list of all users from the database."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=DictCursor)
        
        # Note: We are selecting 'is_admin' to determine the account type.
        # We are NOT selecting the password. Never send passwords to the client.
        query = "SELECT id, email, username, is_admin, agency_name FROM users ORDER BY id ASC"
        cursor.execute(query)
        users = cursor.fetchall()

        # Convert the database rows into a list of JSON objects
        accounts_list = []
        for user in users:
            accounts_list.append({
                "id": user['id'],
                "accountType": "Admin" if user['is_admin'] else "Responder",
                "agencyName": user['agency_name'] if user['agency_name'] else "N/A",
                "email": user['email'],
                "name": user['username'],
                "password": "••••••••" # Send a fake password string for display purposes
            })
        
        return jsonify(accounts_list)

    except Exception as e:
        print(f"Get all users error: {e}")
        return jsonify({"error": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()
    
# --- NEW ENDPOINT TO ADD A USER ---
@app.route('/add_user', methods=['POST'])
def add_user():
    """Adds a new user to the database."""
    conn = None
    try:
        # Get the data from the request body
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')
        username = data.get('username')
        agency_name = data.get('agency_name')
        is_admin = data.get('is_admin', False) # Default to not admin

        # Basic validation
        if not all([email, password, username, agency_name]):
            return jsonify({"success": False, "message": "All fields are required."}), 400

        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Check if email already exists
        cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
        if cursor.fetchone():
            return jsonify({"success": False, "message": "An account with this email already exists."}), 409

        # Insert the new user
        query = """
            INSERT INTO users (email, password, username, agency_name, is_admin)
            VALUES (%s, %s, %s, %s, %s)
        """
        cursor.execute(query, (email, password, username, agency_name, is_admin))
        conn.commit() # Commit the transaction to save the changes

        return jsonify({"success": True, "message": "User added successfully."}), 201

    except Exception as e:
        # Rollback in case of error
        if conn:
            conn.rollback()
        print(f"Add user error: {e}")
        return jsonify({"success": False, "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# This allows you to run the app by executing `python app.py`
if __name__ == '__main__':
    # host='0.0.0.0' makes the server accessible from your network
    app.run(host='0.0.0.0', port=5000, debug=True)