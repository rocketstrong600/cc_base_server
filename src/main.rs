#![allow(dead_code)]
use axum::{
    http::{header, HeaderValue, StatusCode},
    response::{Html, IntoResponse, Response},
    routing::{get, post},
    Json, Router,
};
// use serde::{Deserialize, Serialize};

use tera::Context;
use tera::Tera;

use lazy_static::lazy_static;

lazy_static! {
    pub static ref TEMPLATES: Tera = {
        let mut tera = match Tera::new("templates/**/*.lua") {
            Ok(t) => t,
            Err(e) => {
                println!("Parsing error(s): {}", e);
                ::std::process::exit(1);
            }
        };
        tera
    };
}

struct Lua<T>(T);

impl<T> IntoResponse for Lua<T>
where
    T: IntoResponse,
{
    fn into_response(self) -> Response {
        (
            [(header::CONTENT_TYPE, HeaderValue::from_static("text/lua"))],
            self.0,
        )
            .into_response()
    }
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(root))
        .route("/install", get(install))
        .route("/login", get(login))
        .route("/home", get(home));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:35535")
        .await
        .unwrap();

    axum::serve(listener, app).await.unwrap();
}

async fn root() -> Json<&'static str> {
    Json("{\"status\": \"OK\"}")
}

async fn install() -> Lua<String> {
    let mut context = Context::new();
    let install_lua = TEMPLATES.render("install.lua", &context).unwrap();
    Lua(install_lua)
}

async fn login() -> Lua<String> {
    println!("Login Requested");
    let mut context = Context::new();

    let login_lua = TEMPLATES.render("login.lua", &context).unwrap();
    Lua(login_lua)
}

async fn home() -> Lua<String> {
    println!("Home Requested");
    let mut context = Context::new();
    let home_lua = TEMPLATES.render("home.lua", &context).unwrap();
    Lua(home_lua)
}
