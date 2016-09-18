#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

PROJECT="rust-buildpack-test"

setup()
{
    mkdir -p $BUILD_DIR/src
    cat > $BUILD_DIR/Cargo.toml <<EOF
    [package]
    name = "$PROJECT"
    version = "0.1.0"
    authors = ["Andrew Hobden <andrew@hoverbear.org>"]

    [dependencies]
    rand = "*"
EOF
    cat > $BUILD_DIR/src/main.rs <<EOF
    extern crate rand;

    fn main() {
        let number = rand::random::<u64>();
        println!("Hello world! Some random number is {}", number);
    }

    #[test]
    fn it_works() {
        assert(true);
    }
EOF
}

cleanup()
{
    rm -rf $BUILD_DIR
    rm -rf $CACHE_DIR
    rm -rf /tmp/multirust-repo

    unset RUST_VERSION
}

testDefault()
{
    setup

    compile

    assertCaptured "-----> Fetching multirust"
    assertCaptured "-----> Setting version to \"nightly\" (default)"
    assertCaptured "-----> No cached crates detected"
    assertCaptured "-----> Compiling application"
    assertCaptured "-----> Caching build artifacts"

    compile

    assertCaptured "-----> Pre-existing multirust"
    assertCaptured "multirust: using existing install for"
    assertCaptured "-----> Deleting target/release/deps..."

    cleanup
}

testNightly()
{
    setup
    cat >> $BUILD_DIR/Cargo.toml <<EOF
    [target.heroku]
    version = "nightly"
EOF

    compile

    assertCaptured "-----> Fetching multirust"
    assertCaptured "-----> Setting version to \"nightly\""
    assertCaptured "-----> No cached crates detected"
    assertCaptured "-----> Compiling application"
    assertCaptured "-----> Caching build artifacts"

    cleanup
}

testBeta()
{
    setup
    cat >> $BUILD_DIR/Cargo.toml <<EOF
    [target.heroku]
    version = "beta"
EOF

    compile

    assertCaptured "-----> Fetching multirust"
    assertCaptured "-----> Setting version to \"beta\""
    assertCaptured "-----> No cached crates detected"
    assertCaptured "-----> Compiling application"
    assertCaptured "-----> Caching build artifacts"

    cleanup
}

testStable()
{
    setup
    cat >> $BUILD_DIR/Cargo.toml <<EOF
    [target.heroku]
    version = "stable"
EOF

    compile

    assertCaptured "-----> Fetching multirust"
    assertCaptured "-----> Setting version to \"stable\""
    assertCaptured "-----> No cached crates detected"
    assertCaptured "-----> Compiling application"
    assertCaptured "-----> Caching build artifacts"

    cleanup
}

testVersionEnvironmentOverride()
{
    setup

    export RUST_VERSION=nightly-2016-04-15
    compile

    assertCaptured "-----> Fetching multirust"
    assertCaptured "-----> Setting version to \"nightly-2016-04-15\""
    assertCaptured "-----> No cached crates detected"
    assertCaptured "-----> Compiling application"
    assertCaptured "-----> Caching build artifacts"

    cleanup
}
