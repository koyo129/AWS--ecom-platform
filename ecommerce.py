import os
from flask import Flask
import psycopg2

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        host=os.environ.get("DB_HOST"),
        database=os.environ.get("DB_NAME"),
        user=os.environ.get("DB_USER"),
        password=os.environ.get("DB_PASS")
    )
    return conn

@app.route("/")
def home():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM products;")
    products = cur.fetchall()
    cur.close()
    conn.close()

    html = "<h1>Welcome !</h1>"
    for product in products:
        html += f"<p>{product[1]} - ${product[2]}</p>"
    return html

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
