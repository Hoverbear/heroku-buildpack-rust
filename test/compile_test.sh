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
EOF
    cat > $BUILD_DIR/src/main.rs <<EOF
fn main() {
    println!("Hello world!");
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
}

testDefault()
{
    setup

    # Check Basic
    echo "Default: Testing Basic"
    compile
    assertCaptured "------> Installing Rustup."
    assertCaptured "------> Using \$RUSTC_CHANNEL as nightly (default)."
    assertCaptured "------> No cached Rust detected."
    assertCaptured "------> Installing latest Rust nightly."
    assertCaptured "------> Compiling Application."

    # Check Cache
    echo "Default: Testing Caching"
    compile
    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using \$RUSTC_CHANNEL as nightly (default)."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Pre-cached up-to-date Rust."
    assertCaptured "------> Compiling Application."

    cleanup
}

testNightly()
{
    export RUSTC_CHANNEL="nightly"
    setup

    # Check Basic
    echo "$RUSTC_CHANNEL: Testing Basic"
    compile
    assertCaptured "------> Installing Rustup."
    assertCaptured "------> Using \$RUSTC_CHANNEL as nightly."
    assertCaptured "------> No cached Rust detected."
    assertCaptured "------> Installing latest Rust nightly."
    assertCaptured "------> Compiling Application."

    # Check Cache
    echo "$RUSTC_CHANNEL: Testing Basic"
    compile
    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using \$RUSTC_CHANNEL as nightly."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Pre-cached up-to-date Rust."
    assertCaptured "------> Compiling Application."

    # Check Specific Date
    echo "$RUSTC_CHANNEL: Testing Specific Date"
    export RUSTC_DATE="2015-12-12"
    compile

    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using \$RUSTC_CHANNEL as nightly."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Pre-cached up-to-date Rust."
    assertCaptured "------> Compiling Application."

    # Check Updating.
    echo "$RUSTC_CHANNEL: Testing Updating"
    unset RUSTC_DATE
    compile

    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using \$RUSTC_CHANNEL as nightly."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Pre-cached up-to-date Rust."
    assertCaptured "------> Compiling Application."

    cleanup
    unset RUSTC_CHANNEL
}

testBeta()
{
    export RUSTC_CHANNEL="beta"
    setup

    # Check Basic.
    echo "$RUSTC_CHANNEL: Testing Basic"
    compile
    assertCaptured "------> Installing Rustup."
    assertCaptured "------> Using \$RUSTC_CHANNEL as beta."
    assertCaptured "------> No cached Rust detected."
    assertCaptured "------> Installing latest Rust beta."
    assertCaptured "------> Compiling Application."

    # Check Cache.
    echo "$RUSTC_CHANNEL: Testing Caching"
    compile
    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using \$RUSTC_CHANNEL as beta."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Pre-cached up-to-date Rust."
    assertCaptured "------> Compiling Application."

    # Check specific Date
    echo "$RUSTC_CHANNEL: Testing Specific Date"
    export RUSTC_DATE="2016-12-12"
    compile

    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using \$RUSTC_CHANNEL as beta."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Pre-cached up-to-date Rust."
    assertCaptured "------> Compiling Application."

    # Check Upgrading
    echo "$RUSTC_CHANNEL: Testing Upgrading"
    unset RUSTC_DATE
    compile

    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using \$RUSTC_CHANNEL as beta."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Pre-cached up-to-date Rust."
    assertCaptured "------> Compiling Application."

    cleanup
    unset RUSTC_CHANNEL
}

testStable()
{
    export RUSTC_CHANNEL="stable"
    setup

    # Check Basic
    echo "$RUSTC_CHANNEL: Testing Basic"
    compile
    assertCaptured "------> Installing Rustup."
    assertCaptured "------> Using \$RUSTC_CHANNEL as stable."
    assertCaptured "------> No cached Rust detected."
    assertCaptured "------> Installing latest Rust stable."
    assertCaptured "------> Compiling Application."

    # Check Caching
    echo "$RUSTC_CHANNEL: Testing Caching"
    compile
    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using \$RUSTC_CHANNEL as stable."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Compiling Application."

    # Check Specific Revision
    echo "$RUSTC_CHANNEL: Testing Specific Revision"
    export RUSTC_REVISION="1.4.0"
    compile

    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using \$RUSTC_CHANNEL as stable."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Rust revision not what is specified by \$RUSTC_REVISION."
    assertCaptured "------> Installing Rust revision 1.4.0."
    assertCaptured "------> Compiling Application."

    # Check Updating
    echo "$RUSTC_CHANNEL: Testing Updating"
    unset RUSTC_REVISION
    compile

    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using \$RUSTC_CHANNEL as stable."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Rust revision not specified, installing newest stable."
    assertCaptured "------> Compiling Application."

    cleanup
    unset RUSTC_CHANNEL
}
