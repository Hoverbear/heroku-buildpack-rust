#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

PROJECT="rust-buildpack-test"

testBasic()
{
    mkdir -p $PROJECT/src
    cat > $PROJECT/Cargo.toml <<EOF
[package]
name = "$PROJECT"
version = "0.1.0"
authors = ["Andrew Hobden <andrew@hoverbear.org>"]

[dependencies]
iron = "*"
EOF

    cat > $PROJECT/src/main.rs <<EOF
extern crate iron;

use iron::prelude::*;
use iron::status;
use std::env;

fn main() {
    fn hello_world(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::Ok, "Hello World!")))
    }

    let url = format!("0.0.0.0:{}", env::var("PORT").unwrap());

    println!("Binding on {:?}", url);
    Iron::new(hello_world).http(&url[..]).unwrap();
    println!("Bound on {:?}", url);
}
EOF
    compile

    assertCaptured "-----> Installing rustup"
    assertCaptured "-----> Installing rust"

    rm -rf $PROJECT
}


testCaching()
{
    mkdir -p $PROJECT/src
    cat > $PROJECT/Cargo.toml <<EOF
[package]
name = "$PROJECT"
version = "0.1.0"
authors = ["Andrew Hobden <andrew@hoverbear.org>"]

[dependencies]
iron = "*"
EOF

    cat > $PROJECT/src/main.rs <<EOF
extern crate iron;

use iron::prelude::*;
use iron::status;
use std::env;

fn main() {
    fn hello_world(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::Ok, "Hello World!")))
    }

    let url = format!("0.0.0.0:{}", env::var("PORT").unwrap());

    println!("Binding on {:?}", url);
    Iron::new(hello_world).http(&url[..]).unwrap();
    println!("Bound on {:?}", url);
}
EOF
    touch "$CACHE_DIR/rustup"
    mkdir -p "$CACHE_DIR/rust/bin"
    touch "$CACHE_DIR/rust/bin/rustc"

    compile

    assertCaptured "-----> Pre-cached rustup"
    assertCaptured "-----> Pre-cached rust"

    rm -rf $PROJECT
}
