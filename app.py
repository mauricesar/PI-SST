import os
from datetime import datetime

from flask import Flask, flash, redirect, render_template, request, url_for
from flask_sqlalchemy import SQLAlchemy


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

    class SurveyResponse(db.Model):  # type: ignore[name-defined]
        __tablename__ = "survey_responses"

        id = db.Column(db.Integer, primary_key=True)
        satisfaction = db.Column(db.String(50), nullable=False)
        safety_perception = db.Column(db.String(50), nullable=False)
        support_access = db.Column(db.String(50), nullable=False)
        comments = db.Column(db.Text, nullable=True)
        created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    with app.app_context():
        db.create_all()

    @app.route("/")
    def index() -> str:
        return render_template("index.html")

    @app.route("/survey", methods=["GET", "POST"])
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
    def dashboard() -> str:
        total = SurveyResponse.query.count()
        satisfaction_counts = _count_by_field(SurveyResponse.satisfaction)
        safety_counts = _count_by_field(SurveyResponse.safety_perception)
        support_counts = _count_by_field(SurveyResponse.support_access)

        return render_template(
            "dashboard.html",
            total=total,
            satisfaction_counts=satisfaction_counts,
            safety_counts=safety_counts,
            support_counts=support_counts,
        )

    def _count_by_field(column):
        data = (
            db.session.query(column, db.func.count(SurveyResponse.id))
            .group_by(column)
            .order_by(db.func.count(SurveyResponse.id).desc())
            .all()
        )
        return [(label, count) for label, count in data]

    return app


if __name__ == "__main__":
    app = create_app()
    app.run(debug=True)