#!/bin/bash

# test: itunes stop

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

plan tests 4

# test: itunes stop
dispatch_mocked_command "stop"

is "$stderr" "" "stderr should be empty"
like "${sent_commands[0]}" 'stop' "sent command should contain 'stop'"
like "${sent_commands[0]}" 'tell application "iTunes"' "sent command should contain 'tell application \"iTunes\"'"

is "$stdout" "Stopping iTunes." "stdout should tell user what happened"
