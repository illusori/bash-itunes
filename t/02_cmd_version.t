#!/bin/bash

# test: itunes version

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

plan tests 3

# test: itunes version
dispatch_mocked_command "version"

like "$stdout" " version " "version should be displayed"
is "$stderr" "" "stderr should be empty"
test_no_commands_sent
