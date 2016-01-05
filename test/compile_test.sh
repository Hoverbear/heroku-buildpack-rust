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
    rm -rf $CACHE_DIR
    rm -rf /tmp/multirust-repo
}

testDefault()
{
    setup

    compile

    assertCaptured "-----> Fetching multirust."
    assertCaptured "-----> Setting version to \"nightly\" (default)."
    assertCaptured "-----> Compiling Application."

    compile

    assertCaptured "-----> Pre-existing multirust."

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

    assertCaptured "-----> Fetching multirust."
    assertCaptured "-----> Setting version to \"nightly\"."
    assertCaptured "-----> Compiling Application."

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

    assertCaptured "-----> Fetching multirust."
    assertCaptured "-----> Setting version to \"beta\"."
    assertCaptured "-----> Compiling Application."

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

    assertCaptured "-----> Fetching multirust."
    assertCaptured "-----> Setting version to \"stable\"."
    assertCaptured "-----> Compiling Application."

    cleanup
}
