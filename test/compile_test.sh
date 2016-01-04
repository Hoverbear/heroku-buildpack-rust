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

    compile

    assertCaptured "-----> Fetching multirust."
    assertCaptured "-----> Setting override to \"nightly\" (default)."
    assertCaptured "-----> Compiling Application."

    cleanup
}

testNightly()
{
    setup
    cat >> $BUILD_DIR/Cargo.toml <<EOF
    [target.heroku]
    override = "nightly"
EOF

    compile

    assertCaptured "-----> Fetching multirust."
    assertCaptured "-----> Setting override to \"nightly\"."
    assertCaptured "-----> Compiling Application."

    cleanup
}

testBeta()
{
    setup
    cat >> $BUILD_DIR/Cargo.toml <<EOF
    [target.heroku]
    override = "beta"
EOF

    compile

    assertCaptured "-----> Fetching multirust."
    assertCaptured "-----> Setting override to \"beta\"."
    assertCaptured "-----> Compiling Application."

    cleanup
}

testStable()
{
    setup
    cat >> $BUILD_DIR/Cargo.toml <<EOF
    [target.heroku]
    override = "stable"
EOF

    compile

    assertCaptured "-----> Fetching multirust."
    assertCaptured "-----> Setting override to \"stable\"."
    assertCaptured "-----> Compiling Application."

    cleanup
}
