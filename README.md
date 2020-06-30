
> Deprecated, please don't use this. It's far, far too old.

# heroku-buildpack-rust

[![Build Status](https://travis-ci.org/Hoverbear/heroku-buildpack-rust.svg?branch=master)](https://travis-ci.org/Hoverbear/heroku-buildpack-rust)

**Features:**

* Cached `multirust`, Rust toolchain.
* Caching of previous build artifacts to (potentially dramatically) speed up
similar builds.
* Configurable version selection inside of the `Cargo.toml`, or by specifying the `$RUST_VERSION` environment variable.

## Configuration

You can use any override you would pass `multirust` for this buildpack.

We currently (ab)use the `cargo`'s "target" feature to set the version desired.
Unfortunately because of this there are sometimes (harmless) `cargo` warnings
about an unused value in the `toml` file.

Example:

```toml
[package]
name = "foo"
version = "0.1.0"
authors = ["Andrew Hobden <andrew@hoverbear.org>"]

[dependencies]
iron = "*"

[target.heroku]
version = "nightly"
```

## Instructions

```bash
APP="rust-buildpack-test" && \
cargo new --bin $APP      && \
cd $APP                   && \
git init                  && \
heroku create $APP --buildpack https://github.com/Hoverbear/heroku-buildpack-rust && \
echo "web: target/release/$APP" > Procfile
```

## Example App

After following the instructions above, in `Cargo.toml` add:

```toml
[dependencies]
iron = "*"
```

In `src/main.rs` let's use a simple [iron](http://ironframework.io/) demo:

```rust
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
```

Now the following steps:

```bash
git add src/main.rs Cargo.toml Procfile && \
git commit -m "Init"                    && \
git push heroku master
```

Heroku should then build your application. Finally, you *may* need to start your
application's `web` dyno with:

```bash
heroku ps:scale web=1
```

Now you can visit [`https://$APP.herokuapp.com/`](https://rust-buildpack-test.herokuapp.com/)
and see your application!

## Testing

If you have Docker, you can test this buildpack by doing the following:

```bash
make
```

The `Makefile` defines how to pull down the testrunner and build the appropriate
docker container, then test the buildpack.
