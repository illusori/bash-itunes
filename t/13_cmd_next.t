#!/bin/bash

# test: itunes next

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

plan tests $(((4 + (1 * tests_per_current_track_fetched) + (1 * tests_per_track_displayed))))

function mock_osascript() {
    record_sent_command "$*"
    if [[ "$*" =~ 'of current track' ]]; then
        echo "$mock_track_1_data"
    elif [[ "$*" =~ 'player position' ]]; then
        echo "60"
    fi
}

# test: itunes next
dispatch_mocked_command "next"

is "$stderr" "" "stderr should be empty"
like "${sent_commands[0]}" 'next track' "first sent command should contain 'next track'"
like "${sent_commands[0]}" "tell application \"$itunes_app\"" "first sent command should contain 'tell application \"iTunes\"'"

test_send_commands_current_track_fetch "1" "second" "next"

like "$stdout" "Skipping to next track" "stdout should tell user that track is being skipped"
test_track_displayed "$stdout" "mock_track_1" "stdout"
