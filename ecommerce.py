from flask import Flask
import psycopg2

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        host="localhost",
        database="shopdb",
        user="kokakohyo",
        password=""
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

    html = "<h1>Welcome to CloudCommerce!</h1>"
    for product in products:
        html += f"<p>{product[1]} - ${product[2]}</p>"
    return html

if __name__ == "__main__":
    app.run(debug=True)
