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

def init_db():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS products (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            price NUMERIC
        );
    """)
    cur.execute("INSERT INTO products (name, price) SELECT 'Whey Protein', 45 WHERE NOT EXISTS (SELECT 1 FROM products WHERE name='Whey Protein');")
    cur.execute("INSERT INTO products (name, price) SELECT 'Dumbbells Set', 120 WHERE NOT EXISTS (SELECT 1 FROM products WHERE name='Dumbbells Set');")
    cur.execute("INSERT INTO products (name, price) SELECT 'Resistance Bands', 25 WHERE NOT EXISTS (SELECT 1 FROM products WHERE name='Resistance Bands');")
    cur.execute("INSERT INTO products (name, price) SELECT 'Pre-Workout', 35 WHERE NOT EXISTS (SELECT 1 FROM products WHERE name='Pre-Workout');")
    cur.execute("INSERT INTO products (name, price) SELECT 'Gym Gloves', 15 WHERE NOT EXISTS (SELECT 1 FROM products WHERE name='Gym Gloves');")
    conn.commit()
    cur.close()
    conn.close()

@app.route("/")
def home():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM products;")
    products = cur.fetchall()
    cur.close()
    conn.close()

    product_cards = ""
    for product in products:
        product_cards += f"""
        <div class="card">
            <h2>{product[1]}</h2>
            <p class="price">${product[2]}</p>
            <button>Add to Cart</button>
        </div>
        """

    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Lifty Factory</title>
        <style>
            * {{ margin: 0; padding: 0; box-sizing: border-box; }}
            body {{ background: #1a1a1a; color: #fff; font-family: Arial, sans-serif; }}
            nav {{ background: #111; padding: 20px 40px; display: flex; justify-content: space-between; align-items: center; }}
            nav h1 {{ color: #ff6b00; font-size: 24px; }}
            nav p {{ color: #aaa; font-size: 14px; }}
            .hero {{ text-align: center; padding: 60px 20px; background: linear-gradient(135deg, #111, #2a2a2a); }}
            .hero h2 {{ font-size: 48px; margin-bottom: 10px; }}
            .hero h2 span {{ color: #ff6b00; }}
            .hero p {{ color: #aaa; font-size: 18px; }}
            .products {{ display: flex; flex-wrap: wrap; gap: 20px; padding: 40px; justify-content: center; }}
            .card {{ background: #2a2a2a; border: 1px solid #333; border-radius: 12px; padding: 30px; width: 250px; text-align: center; transition: border 0.3s; }}
            .card:hover {{ border-color: #ff6b00; }}
            .card h2 {{ font-size: 18px; margin-bottom: 10px; }}
            .card .price {{ color: #ff6b00; font-size: 24px; font-weight: bold; margin-bottom: 20px; }}
            .card button {{ background: #ff6b00; color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; font-weight: bold; width: 100%; }}
            .card button:hover {{ background: #e05a00; }}
            footer {{ text-align: center; padding: 20px; background: #111; color: #555; font-size: 12px; }}
        </style>
    </head>
    <body>
        <nav>
            <h1>🏋️ Lifty Factory</h1>
            <p>Built on AWS • Powered by Flask</p>
        </nav>
        <div class="hero">
            <h2>Train <span>Harder.</span> Live <span>Stronger.</span></h2>
            <p>Premium gym equipment and supplements delivered to your door.</p>
        </div>
        <div class="products">
            {product_cards}
        </div>
        <footer>
            <p>© 2026 Lifty Factory. Powered by AWS Auto Scaling.</p>
        </footer>
    </body>
    </html>
    """
    return html

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)
