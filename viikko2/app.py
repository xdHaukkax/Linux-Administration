from flask import Flask, render_template_string
import sqlite3
import os

app = Flask(__name__)

DB_PATH = "/var/www/viikko2/visitors.db"


def get_visits():
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)

    with sqlite3.connect(DB_PATH) as db:
        db.execute("""
            CREATE TABLE IF NOT EXISTS visits (
                id INTEGER PRIMARY KEY,
                count INTEGER NOT NULL
            )
        """)

        db.execute("""
            INSERT OR IGNORE INTO visits (id, count)
            VALUES (1, 0)
        """)

        db.execute("""
            UPDATE visits SET count = count + 1
            WHERE id = 1
        """)

        result = db.execute(
            "SELECT count FROM visits WHERE id = 1"
        ).fetchone()

        return result[0]


@app.route("/")
def home():
    visits = get_visits()

    return render_template_string("""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Week 2 - CSC Pouta</title>
        <style>
            body {
                margin: 0;
                font-family: Arial, sans-serif;
                background: #edf2f7;
                color: #243247;
            }
            header {
                background: #17365d;
                color: white;
                text-align: center;
                padding: 45px 20px;
            }
            main {
                max-width: 850px;
                margin: 35px auto;
                padding: 20px;
            }
            .card {
                background: white;
                padding: 25px;
                margin-bottom: 20px;
                border-radius: 12px;
                box-shadow: 0 3px 12px #00000012;
            }
            h2 { color: #1769aa; }
            .counter {
                font-size: 48px;
                font-weight: bold;
                color: #1769aa;
                text-align: center;
            }
            a { color: #1769aa; }
            footer {
                text-align: center;
                padding: 25px;
            }
        </style>
    </head>
    <body>
        <header>
            <h1>My Week 2 Web Application</h1>
            <p>CSC Pouta | Ubuntu | Python Flask | Nginx</p>
        </header>

        <main>
            <section class="card">
                <h2>Welcome!</h2>
                <p>
                    This application runs on a virtual machine
                    hosted by CSC Pouta cloud infrastructure.
                </p>
            </section>

            <section class="card">
                <h2>Visitor Counter</h2>
                <div class="counter">{{ visits }}</div>
                <p style="text-align:center">Total page visits</p>
            </section>

            <section class="card">
                <h2>Database and Persistence</h2>
                <p>
                    The application uses SQLite to store the
                    visitor counter in a persistent database file
                    named visitors.db.
                </p>
                <p>
                    The counter is increased and saved every time
                    the page is loaded.
                </p>
            </section>

            <section class="card">
                <h2>Restart Test</h2>
                <p>
                    Server restart persistence test:
                    <strong>Pending verification.</strong>
                </p>
            </section>

            <section class="card">
                <h2>Source Code</h2>
                <p>
                    GitHub repository:
                    <a href="https://github.com/xdHaukkax/Linux-Administration">
                        View source code
                    </a>
                </p>
            </section>
        </main>

        <footer>
            Week 2 Cloud Computing Project | CSC Pouta
        </footer>
    </body>
    </html>
    """, visits=visits)


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8000)
