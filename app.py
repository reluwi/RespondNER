from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2 
from psycopg2.extras import DictCursor
import os
import pandas as pd 
from datetime import datetime

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
        df = pd.read_csv('updated_tweets.csv')
        
        # 1. Convert the 'Date' column to actual datetime objects for proper sorting.
        df['datetime_obj'] = pd.to_datetime(df['Date'], errors='coerce')
        # 2. Drop any rows where the date could not be parsed.
        df.dropna(subset=['datetime_obj'], inplace=True)
        # 3. Sort the entire DataFrame by the new datetime column, latest first.
        df.sort_values(by='datetime_obj', ascending=False, inplace=True)
        # 4. Take the top 15 most recent posts.
        sample_df = df.head(20)
 
        
        # Fill any empty cells (NaN) with empty strings to prevent errors
        sample_df = sample_df.fillna('')
        
        posts_data = []
        
        # Process each row to match the desired format
        for index, row in sample_df.iterrows():
            entities = []

            formatted_timestamp = row['datetime_obj'].strftime('%Y-%m-%d %H:%M')

            # 2. Check each new entity column and build the string
            if row['Location']:
                entities.append(f"[Location: {row['Location']}]")
            
            if row['People']:
                # Handle multiple people separated by commas
                people = row['People'].split(',')
                for person in people:
                    if person.strip():
                        entities.append(f"[People: {person.strip()}]")

            if row['Organization']:
                # Handle multiple organizations separated by commas
                orgs = row['Organization'].split(',')
                for org in orgs:
                    if org.strip():
                        entities.append(f"[Organization: {org.strip()}]")

            if row['Emergency Terms']:
                # Handle multiple terms separated by commas
                terms = row['Emergency Terms'].split(',')
                for term in terms:
                    if term.strip():
                        entities.append(f"[Emergency: {term.strip()}]")
            
            if row['Resources Needed']:
                # Handle multiple needs separated by commas
                needs = row['Resources Needed'].split(',')
                for need in needs:
                    if need.strip():
                        entities.append(f"[Needs: {need.strip()}]")

            # 3. Create the final JSON object using the new column names
            post = {
                "timestamp": formatted_timestamp, # Using the 'Date' column
                "extractedPost": row['Text Content'], # Using the 'Text Content' column
                "namedEntities": ", ".join(entities) if entities else "No entities found"
            }
            posts_data.append(post)
            
        return jsonify(posts_data)

    except FileNotFoundError:
        return jsonify({"error": "tweets.csv not found on the server."}), 404
    except Exception as e:
        print(f"An error occurred in /get_mock_posts: {e}")
        return jsonify({"error": "Failed to process mock data."}), 500

@app.route('/login', methods=['POST'])
def login():
    """Handles user login requests with improved logic and robustness."""
    conn = None
    try:
        data = request.get_json()
        # Use .strip() to remove any leading/trailing whitespace from user input
        email = data.get('email', '').strip()
        user_password = data.get('password', '')

        if not email or not user_password:
            return jsonify({"success": False, "message": "Email and password are required."}), 400

        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=DictCursor)

        query = "SELECT password FROM users WHERE email = %s"
        cursor.execute(query, (email,))
        result = cursor.fetchone()

        # This is the clear and correct logic flow
        if result is not None:
            # We found a user with that email
            stored_password = result['password']
            if user_password == stored_password:
                # The password matches! Success.
                return jsonify({"success": True, "message": "Login successful."})
            else:
                # Password does not match. Failure.
                return jsonify({"success": False, "message": "Invalid credentials."})
        else:
            # No user found with that email. Failure.
            return jsonify({"success": False, "message": "Invalid credentials."})

    except Exception as e:
        print(f"An error occurred during login: {e}")
        return jsonify({"success": False, "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# --- ENDPOINT TO FETCH ALL USER ACCOUNTS ---
@app.route('/get_all_users', methods=['GET'])
def get_all_users():
    """Fetches a list of all users from the database."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=DictCursor)
        
        # We are selecting 'is_admin' to determine the account type.
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

# --- NEW ENDPOINT TO DELETE USERS ---
@app.route('/delete_users', methods=['DELETE']) # Using the correct DELETE verb
def delete_users():
    """Deletes users based on a list of IDs."""
    conn = None
    try:
        data = request.get_json()
        ids_to_delete = data.get('ids')

        if not ids_to_delete or not isinstance(ids_to_delete, list):
            return jsonify({"success": False, "message": "A list of user IDs is required."}), 400

        conn = get_db_connection()
        cursor = conn.cursor()

        # The 'ANY' operator is an efficient way to check against a list in PostgreSQL
        query = "DELETE FROM users WHERE id = ANY(%s)"
        # We pass the list of IDs as a tuple to the query to prevent SQL injection
        cursor.execute(query, (ids_to_delete,))
        
        rows_deleted = cursor.rowcount # Get the number of rows affected
        conn.commit() # Commit the transaction to save the changes

        return jsonify({
            "success": True, 
            "message": f"{rows_deleted} account(s) deleted successfully."
        }), 200

    except Exception as e:
        if conn:
            conn.rollback()
        print(f"Delete users error: {e}")
        return jsonify({"success": False, "message": "An internal server error occurred."}), 500
    finally:
        if conn:
            conn.close()

# --- NEW ENDPOINT TO UPDATE A USER ---
@app.route('/update_user/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    """Updates an existing user's information."""
    conn = None
    try:
        data = request.get_json()
        email = data.get('email')
        username = data.get('username')
        agency_name = data.get('agency_name')
        new_password = data.get('password')

        if not all([email, username, agency_name]):
            return jsonify({"success": False, "message": "All fields except password are required."}), 400

        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if the new email is already taken by another user
        cursor.execute("SELECT id FROM users WHERE email = %s AND id != %s", (email, user_id))
        if cursor.fetchone():
            return jsonify({"success": False, "message": "This email is already in use by another account."}), 409

        if new_password and new_password != '••••••••':
            # If a new password was provided, update it along with the other fields.
            query = """
                UPDATE users
                SET email = %s, username = %s, agency_name = %s, password = %s
                WHERE id = %s
            """
            params = (email, username, agency_name, new_password, user_id)
        else:
            # If no new password was provided, only update the other fields.
            query = """
                UPDATE users
                SET email = %s, username = %s, agency_name = %s
                WHERE id = %s
            """
            params = (email, username, agency_name, user_id)
        
        cursor.execute(query, params)
        
        conn.commit()

        return jsonify({"success": True, "message": "Account updated successfully."}), 200

    except Exception as e:
        if conn: conn.rollback()
        print(f"Update user error: {e}")
        return jsonify({"success": False, "message": "An internal server error occurred."}), 500
    finally:
        if conn: conn.close()

# This allows you to run the app by executing `python app.py`
if __name__ == '__main__':
    # host='0.0.0.0' makes the server accessible from your network
    app.run(host='0.0.0.0', port=5000, debug=True)