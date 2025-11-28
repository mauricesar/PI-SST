import os
from datetime import datetime
from functools import wraps
from sqlalchemy import text

from flask import (
    Flask,
    flash,
    g,
    redirect,
    render_template,
    request,
    session,
    url_for,
)
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import check_password_hash, generate_password_hash


def create_app() -> Flask:
    app = Flask(__name__)
    app.config["SECRET_KEY"] = os.environ.get("SECRET_KEY", "dev-secret-key")

    os.makedirs(app.instance_path, exist_ok=True)
    default_db_path = os.path.join(app.instance_path, "pi_sst.db")
    app.config["SQLALCHEMY_DATABASE_URI"] = os.environ.get(
        "DATABASE_URL", f"sqlite:///{default_db_path}"
    )
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    db = SQLAlchemy(app)

    class User(db.Model):  # type: ignore[name-defined]
        __tablename__ = "users"

        id = db.Column(db.Integer, primary_key=True)
        name = db.Column(db.String(120), nullable=False)
        preferred_name = db.Column(db.String(120), nullable=True)
        email = db.Column(db.String(255), unique=True, nullable=False)
        password_hash = db.Column(db.String(255), nullable=False)
        role = db.Column(db.String(20), nullable=False, default="user")

        def set_password(self, password: str) -> None:
            self.password_hash = generate_password_hash(password)

        def check_password(self, password: str) -> bool:
            return check_password_hash(self.password_hash, password)

    class SurveyResponse(db.Model):  # type: ignore[name-defined]
        __tablename__ = "survey_responses"

        id = db.Column(db.Integer, primary_key=True)
        satisfaction = db.Column(db.String(50), nullable=False)
        safety_perception = db.Column(db.String(50), nullable=False)
        support_access = db.Column(db.String(50), nullable=False)
        comments = db.Column(db.Text, nullable=True)
        created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    class OuvidoriaMessage(db.Model):  # type: ignore[name-defined]
        __tablename__ = "ouvidoria_messages"

        id = db.Column(db.Integer, primary_key=True)
        user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
        category = db.Column(db.String(40), nullable=False)
        title = db.Column(db.String(200), nullable=False)
        description = db.Column(db.Text, nullable=False)
        response = db.Column(db.Text, nullable=True)
        responded_at = db.Column(db.DateTime, nullable=True)
        created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

        user = db.relationship("User", backref=db.backref("messages", lazy=True))

    with app.app_context():
        db.create_all()

        with db.engine.connect() as conn:
            columns = [row[1] for row in conn.execute(text("PRAGMA table_info(users)"))]
            if "preferred_name" not in columns:
                conn.execute(text("ALTER TABLE users ADD COLUMN preferred_name VARCHAR(120)"))
                conn.commit()

        admin_email = os.environ.get("ADMIN_EMAIL", "admin@guidetec.local").lower()
        admin_name = os.environ.get("ADMIN_NAME", "Administrador GuiaTEC")
        admin_password = os.environ.get("ADMIN_PASSWORD", "admin123")
        admin_preferred = os.environ.get("ADMIN_PREFERRED_NAME", "ADM GuiaTEC")

        existing_admin = User.query.filter_by(email=admin_email).first()
        if existing_admin is None:
            seeded_admin = User(
                name=admin_name,
                preferred_name=admin_preferred or admin_name,
                email=admin_email,
                role="admin",
            )
            seeded_admin.set_password(admin_password)
            db.session.add(seeded_admin)
            db.session.commit()

    @app.before_request
    def load_logged_in_user() -> None:
        user_id = session.get("user_id")
        g.user = User.query.get(user_id) if user_id else None

    def login_required(view):
        @wraps(view)
        def wrapped_view(**kwargs):
            if g.user is None:
                flash("Faça login para acessar esta área.", "error")
                return redirect(url_for("login", next=request.path))
            return view(**kwargs)

        return wrapped_view

    def admin_required(view):
        @wraps(view)
        def wrapped_view(**kwargs):
            if g.user is None:
                flash("Faça login para acessar esta área.", "error")
                return redirect(url_for("login", next=request.path))
            if g.user.role != "admin":
                flash("Apenas usuários técnicos (ADM) podem acessar esta seção.", "error")
                return redirect(url_for("index"))
            return view(**kwargs)

        return wrapped_view

    @app.route("/")
    def index() -> str:
        return render_template("index.html")

    @app.route("/survey", methods=["GET", "POST"])
    @login_required
    def survey() -> str:
        if request.method == "POST":
            satisfaction = request.form.get("satisfaction")
            safety = request.form.get("safety_perception")
            support = request.form.get("support_access")
            comments = request.form.get("comments")

            if not satisfaction or not safety or not support:
                flash("Por favor, responda às perguntas obrigatórias.", "error")
                return redirect(url_for("survey"))

            response = SurveyResponse(
                satisfaction=satisfaction,
                safety_perception=safety,
                support_access=support,
                comments=comments,
            )
            db.session.add(response)
            db.session.commit()

            flash("Resposta registrada com sucesso!", "success")
            return redirect(url_for("survey"))

        return render_template("survey.html")

    @app.route("/dashboard")
    @admin_required
    def dashboard() -> str:
        total = SurveyResponse.query.count()
        satisfaction_counts = _count_by_field(SurveyResponse.satisfaction)
        safety_counts = _count_by_field(SurveyResponse.safety_perception)
        support_counts = _count_by_field(SurveyResponse.support_access)

        total_messages = OuvidoriaMessage.query.count()
        answered_messages = OuvidoriaMessage.query.filter(
            OuvidoriaMessage.responded_at.isnot(None)
        ).count()
        message_counts = _count_messages_by_type()

        return render_template(
            "dashboard.html",
            total=total,
            satisfaction_counts=satisfaction_counts,
            safety_counts=safety_counts,
            support_counts=support_counts,
            total_messages=total_messages,
            answered_messages=answered_messages,
            message_counts=message_counts,
        )

    @app.route("/guia")
    @admin_required
    def guide() -> str:
        return render_template("guide.html")

    @app.route("/ouvidoria", methods=["GET", "POST"])
    @login_required
    def ouvidoria() -> str:
        categories = ["Reclamação", "Ocorrência", "Sugestão", "Elogio"]

        if request.method == "POST":
            category = request.form.get("category", "").strip()
            title = request.form.get("title", "").strip()
            description = request.form.get("description", "").strip()

            if category not in categories:
                flash("Selecione um tipo de mensagem válido.", "error")
                return redirect(url_for("ouvidoria"))

            if not title or not description:
                flash("Preencha título e descrição para enviar sua mensagem.", "error")
                return redirect(url_for("ouvidoria"))

            message = OuvidoriaMessage(
                user_id=g.user.id,
                category=category,
                title=title,
                description=description,
            )
            db.session.add(message)
            db.session.commit()

            flash("Mensagem enviada para a ouvidoria!", "success")
            return redirect(url_for("ouvidoria"))

        return render_template("ouvidoria.html", categories=categories)

    @app.route("/ouvidoria/respostas", methods=["GET", "POST"])
    @admin_required
    def ouvidoria_respostas() -> str:
        categories = ["Reclamação", "Ocorrência", "Sugestão", "Elogio"]

        if request.method == "POST":
            message_id = request.form.get("message_id")
            response_text = request.form.get("response", "").strip()

            message = OuvidoriaMessage.query.get(message_id)
            if not message:
                flash("Mensagem não encontrada.", "error")
                return redirect(url_for("ouvidoria_respostas"))

            if not response_text:
                flash("Inclua uma resposta para enviar ao colaborador.", "error")
                return redirect(url_for("ouvidoria_respostas"))

            message.response = response_text
            message.responded_at = datetime.utcnow()
            db.session.commit()

            flash("Resposta registrada com sucesso!", "success")
            return redirect(url_for("ouvidoria_respostas"))

        messages = (
            OuvidoriaMessage.query.order_by(OuvidoriaMessage.created_at.desc())
            .all()
        )
        return render_template(
            "ouvidoria_respostas.html",
            messages=messages,
            categories=categories,
        )

    @app.route("/registrar", methods=["GET", "POST"])
    def register() -> str:
        if request.method == "POST":
            name = request.form.get("name", "").strip()
            preferred_name = request.form.get("preferred_name", "").strip()
            email = request.form.get("email", "").strip().lower()
            password = request.form.get("password", "")

            role = request.form.get("role", "user") if g.user and g.user.role == "admin" else "user"

            if not name or not email or not password:
                flash("Preencha nome, e-mail e senha.", "error")
                return redirect(url_for("register"))

            if not preferred_name:
                preferred_name = name

            if role not in {"admin", "user"}:
                role = "user"

            existing = User.query.filter_by(email=email).first()
            if existing:
                flash("Este e-mail já está cadastrado.", "error")
                return redirect(url_for("register"))

            user = User(name=name, preferred_name=preferred_name, email=email, role=role)
            user.set_password(password)
            db.session.add(user)
            db.session.commit()

            flash("Cadastro realizado com sucesso! Faça login para continuar.", "success")
            return redirect(url_for("login"))

        return render_template("register.html")

    @app.route("/login", methods=["GET", "POST"])
    def login() -> str:
        if request.method == "POST":
            email = request.form.get("email", "").strip().lower()
            password = request.form.get("password", "")
            next_url = request.form.get("next") or request.args.get("next")

            user = User.query.filter_by(email=email).first()
            if user and user.check_password(password):
                session.clear()
                session["user_id"] = user.id
                session["role"] = user.role
                session["user_name"] = user.preferred_name or user.name
                flash("Login realizado com sucesso!", "success")
                return redirect(next_url or url_for("index"))

            flash("Credenciais inválidas. Verifique e tente novamente.", "error")

        next_url = request.args.get("next", "")
        return render_template("login.html", next_url=next_url)

    @app.route("/logout")
    def logout() -> str:
        session.clear()
        flash("Você saiu da aplicação.", "success")
        return redirect(url_for("index"))

    def _count_by_field(column):
        data = (
            db.session.query(column, db.func.count(SurveyResponse.id))
            .group_by(column)
            .order_by(db.func.count(SurveyResponse.id).desc())
            .all()
        )
        return [(label, count) for label, count in data]

    def _count_messages_by_type():
        data = (
            db.session.query(
                OuvidoriaMessage.category, db.func.count(OuvidoriaMessage.id)
            )
            .group_by(OuvidoriaMessage.category)
            .order_by(db.func.count(OuvidoriaMessage.id).desc())
            .all()
        )
        return [(label, count) for label, count in data]

    return app


if __name__ == "__main__":
    app = create_app()
    app.run(debug=True)