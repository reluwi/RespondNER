from werkzeug.security import generate_password_hash

plain_text_password = 'password123'

# Generate the secure hash
hashed_password = generate_password_hash(plain_text_password)

# Print it so you can copy it
print("\nYour new hashed password is:\n")
print(hashed_password)
print("\nCopy the entire string above (starting with 'pbkdf2:sha256...')\n")