#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testDetect()
{
  touch ${BUILD_DIR}/Cargo.toml

  detect

  assertAppDetected "Rust"
}

testNoDetectMissingCargoToml()
{
  detect

  assertNoAppDetected
}

testNoDetectCargoTomlAsDir()
{
  mkdir -p ${BUILD_DIR}/Cargo.toml

  detect

  assertNoAppDetected
}
