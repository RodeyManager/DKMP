"""DKMP 企业知识库管理平台 — 登录服务入口。

运行:python app.py 后访问 http://127.0.0.1:5000/login
"""
import os

from flask import Flask, flash, redirect, render_template, request, session, url_for
from werkzeug.security import check_password_hash, generate_password_hash

app = Flask(__name__)
app.secret_key = os.environ.get("DKMP_SECRET_KEY", "dev-only-secret-key")

# 内存用户表:字段结构对齐后续接入数据库的 users 表(id/username/password_hash/display_name)
USERS = {
    "admin": {
        "id": 1,
        "username": "admin",
        "password_hash": generate_password_hash("admin123"),
        "display_name": "管理员",
    },
}


def current_user():
    """从会话恢复当前登录用户;未登录或用户不存在时返回 None。"""
    return USERS.get(session.get("username"))


@app.route("/")
def index():
    user = current_user()
    if user is None:
        return redirect(url_for("login"))
    return (
        f"<h1>欢迎回来,{user['display_name']}</h1>"
        f"<p><a href=\"{url_for('logout')}\">退出登录</a></p>"
    )


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "")
        user = USERS.get(username)
        if user and check_password_hash(user["password_hash"], password):
            session.clear()
            session["username"] = user["username"]
            return redirect(url_for("index"))
        flash("用户名或密码错误", "error")
    return render_template("login.html")


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=True)
