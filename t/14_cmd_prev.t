#!/bin/bash

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

plan tests 9

function mock_osascript() {
    record_sent_command "$*"
    if [[ "$*" =~ 'of current track' ]]; then
        echo "Apoptygma Berzerk
Kathy's Song
Welcome To Earth \"Extra bit for testing\"

100
6:35"
    elif [[ "$*" =~ 'player position' ]]; then
        echo "60"
    fi
}

clear_sent_commands
mock_function "_osascript" "mock_osascript"
start_output_capture

_dispatch "prev"

finish_output_capture stdout stderr
restore_mocked_function "_osascript"
read_sent_commands

like "${sent_commands[0]}" 'previous track' "first sent command should contain 'previous track'"
like "${sent_commands[0]}" 'tell application "iTunes"' "first sent command should contain 'tell application \"iTunes\"'"
like "${sent_commands[1]}" 'of current track' "second sent command should be fetch of 'current track'"
like "${sent_commands[1]}" 'tell application "iTunes"' "second sent command should contain 'tell application \"iTunes\"'"
like "${sent_commands[2]}" 'player position as integer' "third sent command should contain 'player position as integer'"
like "${sent_commands[2]}" 'tell application "iTunes"' "third sent command should contain 'tell application \"iTunes\"'"

like "$stdout" "Skipping to previous track" "stdout should tell user that track is being skipped backwards"
like "$stdout" "Kathy's Song" "stdout should contain summary of new track"
is "$stderr" "" "stderr should be empty"
