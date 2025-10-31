from flask import Flask, render_template, request, redirect, url_for, session
from flask_sqlalchemy import SQLAlchemy
from urllib.parse import quote_plus
import os
import time
from datetime import datetime
import hashlib
import subprocess
import os

app = Flask(__name__)
app.secret_key = "developerai_secret_key"  # Troque por algo mais seguro em produção

PASSWORD_HASH = hashlib.sha256("admin123".encode()).hexdigest()

encoded_password = quote_plus("Eduardo85@42#")
app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://devai_user:{encoded_password}@localhost/devai_db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)

history_file = "command_history.log"

def run_command(cmd):
    try:
        result = subprocess.run(cmd, shell=True, text=True, capture_output=True)
        log = f"$ {cmd}\n{result.stdout}\n{result.stderr}"
        with open(history_file, "a") as f:
            f.write(log + "\n\n")
        return log

    except subprocess.CalledProcessError as e:
        return f"❌ Error:\n{e.output}"

def get_status():
    try:
    # Caminho correto: sobe dois níveis até DeveloperAI/version.txt
        base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
        version_path = os.path.join(base_dir, "version.txt")
        with open(version_path, "r") as f:
            version = f.read().strip()
    except Exception as e:
        version = f"Uknown: {e}"


    try:
        branch = subprocess.check_output(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            cwd=os.path.dirname(__file__),
            text=True
        ).strip()
    except Exception as e:
        branch = f"Unknown: {e}"

    try:
        commit = subprocess.check_output(
            ["git", "log", "-1", "--pretty=format:%h – %s (%cr)"],
            cwd=os.path.dirname(__file__),
            text=True
        ).strip()
    except Exception as e:
        commit = f"Unknown: {e}"

    return {
        "version": version,
        "branch": branch,
        "commit": commit
    }

def get_available_commands():
    return {
    "Build": "devai build",
    "Test": "devai test",
    "Upgrade": "yes | devai upgrade",
    "Status": "devai status",
    "Deploy": "devai deploy",
    "Clean": "devai clean",
    "Doc": "devai doc",
    "Changelog": "devai changelog",
    "Version": "devai version",
    "Release": "devai release",
    "Push": "devai push",
    "Help": "devai help"
}


command_history = []

def get_command_logs():
    return command_history

def add_command_log(command, output):
    command_history.append({
        "command": command,
        "output": output
    })

@app.route("/", methods=["GET", "POST"])
def index():
    if not session.get("authenticated"):
        return redirect(url_for("login"))

    status = get_status()
    available_commands = get_available_commands()
    logs = get_command_logs()
    output = ""

    if request.method == "POST":
        selected = request.form.get("command")
        cmd_map = get_available_commands()
        if selected in cmd_map:
            output = run_command(cmd_map[selected])
            add_command_log(selected, output)

    return render_template(
        "index.html",
        status=status,
        commands=list(available_commands.keys()),
        output=output,
        logs=logs
    )

def load_users():
    users = {}
    if os.path.exists("users.txt"):
        with open("users.txt") as f:
            for line in f:
                if ":" in line:
                    user, hashval = line.strip().split(":", 1)
                    users[user] = hashval
    return users

@app.route("/login", methods=["GET", "POST"])
def login():
    error = ""
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")
        user = User.query.filter_by(username=username).first()
        if user and user.password_hash == hashlib.sha256(password.encode()).hexdigest():
            session["authenticated"] = True
            session["user"] = username
            return redirect(url_for("index"))
        error = "Invalid username or password"
    return render_template("login.html", error=error)

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))

@app.route("/admin/users", methods=["GET", "POST"])
def admin_users():
    if not session.get("authenticated") or session.get("user") != "eduardo":
        return "❌ Acesso negado", 403

    message = ""
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")
        if len(password) < 6:
            message = "⚠️ A senha deve ter pelo menos 6 caracteres."
        elif User.query.filter_by(username=username).first():
            message = f"❌ Usuário '{username}' já existe."
        else:
            hashed = hashlib.sha256(password.encode()).hexdigest()
            user = User(username=username, password_hash=hashed)
            db.session.add(user)
            db.session.commit()
            message = f"✅ Usuário '{username}' criado com sucesso."
    return render_template("admin_users.html", message=message)

@app.route("/logs")
def logs():
    if os.path.exists(history_file):
        with open(history_file, "r") as f:
            return f.read()
    return "No logs yet."

if __name__ == "__main__":
    app.run(debug=True)

