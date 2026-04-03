import os
from flask import Flask
import psycopg2

app = Flask(__name__)

def get_db_connection():
    host = os.environ.get("DB_HOST", "NOT SET")
    name = os.environ.get("DB_NAME", "NOT SET")
    user = os.environ.get("DB_USER", "NOT SET")
    password = os.environ.get("DB_PASS", "NOT SET")
    conn = psycopg2.connect(
        host=host,
        database=name,
        user=user,
        password=password
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

@app.route("/debug")
def debug():
    return f"DB_HOST: {os.environ.get('DB_HOST', 'NOT SET')}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
```

Push to GitHub, then do instance refresh, then visit:
```
http://your-alb-url/debug
