#!/bin/bash

# test: itunes pause

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

plan tests 4

# test: itunes pause
dispatch_mocked_command "pause"

is "$stderr" "" "stderr should be empty"
like "${sent_commands[0]}" 'pause' "sent command should contain 'pause'"
like "${sent_commands[0]}" "tell application \"$itunes_app\"" "sent command should contain 'tell application \"$itunes_app\"'"

is "$stdout" "Pausing iTunes." "stdout should tell user what happened"
