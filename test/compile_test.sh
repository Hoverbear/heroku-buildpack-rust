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
    assertCaptured "------> Using channel as nightly (default)."
    assertCaptured "------> No cached Rust detected."
    assertCaptured "------> Installing latest Rust nightly."
    assertCaptured "------> Compiling Application."

    # Check Cache
    echo "Default: Testing Caching"
    compile
    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using channel as nightly (default)."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Pre-cached up-to-date Rust."
    assertCaptured "------> Compiling Application."

    cleanup
}

testNightly()
{
    setup
    cat >> $BUILD_DIR/Cargo.toml <<EOF
[target.heroku]
channel = "nightly"
EOF

    # Check Basic
    echo "Nightly: Testing Basic"
    compile
    assertCaptured "------> Installing Rustup."
    assertCaptured "------> Using channel as nightly."
    assertCaptured "------> No cached Rust detected."
    assertCaptured "------> Installing latest Rust nightly."
    assertCaptured "------> Compiling Application."

    # Check Cache
    echo "Nightly: Testing Caching"
    compile
    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using channel as nightly."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Pre-cached up-to-date Rust."
    assertCaptured "------> Compiling Application."

    # Check Specific Date
    echo "Nightly: Testing Specific Date"
    cat >> $BUILD_DIR/Cargo.toml <<EOF
date = "2015-12-12"
EOF
    compile

    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using channel as nightly."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Pre-cached up-to-date Rust."
    assertCaptured "------> Compiling Application."

    # Check Updating.
    echo "Nightly: Testing Updating"
    sed -i "$ d" $BUILD_DIR/Cargo.toml # Delete the last line.
    compile

    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using channel as nightly."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Pre-cached up-to-date Rust."
    assertCaptured "------> Compiling Application."

    cleanup
}

testBeta()
{
    setup
    cat >> $BUILD_DIR/Cargo.toml <<EOF
[target.heroku]
channel = "beta"
EOF

    # Check Basic.
    echo "Beta: Testing Basic"
    compile
    assertCaptured "------> Installing Rustup."
    assertCaptured "------> Using channel as beta."
    assertCaptured "------> No cached Rust detected."
    assertCaptured "------> Installing latest Rust beta."
    assertCaptured "------> Compiling Application."

    # Check Cache.
    echo "Beta: Testing Caching"
    compile
    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using channel as beta."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Pre-cached up-to-date Rust."
    assertCaptured "------> Compiling Application."

# TODO: This is currently not tested because I'm only able to find one version of the beta.
#     # Check specific Date
#     echo "Beta: Testing Specific Date"
#     cat >> $BUILD_DIR/Cargo.toml <<EOF
# date = "2015-12-10"
# EOF
#     compile
#
#     echo "$(cat $STD_OUT)"
#     echo "$(cat $STD_ERR)"
#
#     assertCaptured "------> Pre-cached Rustup."
#     assertCaptured "------> Using channel as beta."
#     assertCaptured "------> Cached Rust detected, checking..."
#     assertCaptured "------> Pre-cached up-to-date Rust."
#     assertCaptured "------> Compiling Application."
#
#     # Check Upgrading
#     echo "Beta: Testing Upgrading"
#     sed -i "$ d" $BUILD_DIR/Cargo.toml # Delete the last line.
#     compile
#
#     assertCaptured "------> Pre-cached Rustup."
#     assertCaptured "------> Using channel as beta."
#     assertCaptured "------> Cached Rust detected, checking..."
#     assertCaptured "------> Pre-cached up-to-date Rust."
#     assertCaptured "------> Compiling Application."

    cleanup
}

testStable()
{
    setup
    cat >> $BUILD_DIR/Cargo.toml <<EOF
[target.heroku]
channel = "stable"
EOF

    # Check Basic
    echo "Stable: Testing Basic"
    compile
    assertCaptured "------> Installing Rustup."
    assertCaptured "------> Using channel as stable."
    assertCaptured "------> No cached Rust detected."
    assertCaptured "------> Installing latest Rust stable."
    assertCaptured "------> Compiling Application."

    # Check Caching
    echo "Stable: Testing Caching"
    compile
    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using channel as stable."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Compiling Application."

    # Check Specific Revision
    echo "Stable: Testing Specific Revision"
    cat >> $BUILD_DIR/Cargo.toml <<EOF
revision = "1.4.0"
EOF
    compile

    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using channel as stable."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Rust revision not what is specified by \$RUSTC_REVISION."
    assertCaptured "------> Installing Rust revision 1.4.0."
    assertCaptured "------> Compiling Application."

    # Check Updating
    echo "Stable: Testing Updating"
    sed -i "$ d" $BUILD_DIR/Cargo.toml # Delete the last line.
    compile

    assertCaptured "------> Pre-cached Rustup."
    assertCaptured "------> Using channel as stable."
    assertCaptured "------> Cached Rust detected, checking..."
    assertCaptured "------> Rust revision not specified, installing newest stable."
    assertCaptured "------> Compiling Application."

    cleanup
}
