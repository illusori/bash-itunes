#!/bin/bash

# test: itunes help

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

plan tests 3

# test: itunes help
dispatch_mocked_command "help"

like "$stdout" "Show this help and exit" "help text should be displayed"
is "$stderr" "" "stderr should be empty"
test_no_commands_sent
