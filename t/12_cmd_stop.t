#!/bin/bash

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

plan tests 4

function mock_osascript() {
    record_sent_command "$*"
}

clear_sent_commands
mock_function "_osascript" "mock_osascript"
start_output_capture

_dispatch "stop"

finish_output_capture stdout stderr
restore_mocked_function "_osascript"
read_sent_commands

like "${sent_commands[0]}" 'stop' "sent command should contain 'stop'"
like "${sent_commands[0]}" 'tell application "iTunes"' "sent command should contain 'tell application \"iTunes\"'"

is "$stdout" "Stopping iTunes." "stdout should tell user what happened"
is "$stderr" "" "stderr should be empty"
