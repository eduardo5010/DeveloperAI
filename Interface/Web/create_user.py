from app import app, db, User
import hashlib

def create_user(username, password):
    with app.app_context():
        if User.query.filter_by(username=username).first():
            print(f"❌ Usuário '{username}' já existe.")
            return
        hashed = hashlib.sha256(password.encode()).hexdigest()
        user = User(username=username, password_hash=hashed)
        db.session.add(user)
        db.session.commit()
        print(f"✅ Usuário '{username}' criado com sucesso.")

if __name__ == "__main__":
    import getpass
    username = input("👤 Nome de usuário: ")
    password = getpass.getpass("🔒 Senha: ")
    create_user(username, password)
