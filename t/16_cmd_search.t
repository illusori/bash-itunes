#!/bin/bash

# TODO: test: itunes search
# TODO: test: itunes search [all] <search>
# TODO: test: itunes search {track | tracks | song | songs} <search>
# TODO: test: itunes search {album | albums} <search>

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

plan tests $((5 + (2 * tests_per_track_displayed)))

function mock_osascript() {
    record_sent_command "$*"
    if [[ "$*" =~ 'search playlist "Library" for "kathy"' ]]; then
        echo "$mock_track_1_data
$mock_track_4_data"
    fi
}

# test: itunes search <search>
dispatch_mocked_command "search" "kathy"

is "$stderr" "" "stderr should be empty"
like "${sent_commands[0]}" 'search playlist "Library" for "kathy"' "first sent command should contain search for 'kathy'"
like "${sent_commands[0]}" 'only all' "first sent command should restrict search to 'all'"
like "${sent_commands[0]}" 'tell application "iTunes"' "first sent command should contain 'tell application \"iTunes\"'"

like "$stdout" "Searching for tracks with anything containing \"kathy\"" "stdout should tell user what is being search for"
test_track_displayed "$stdout" "mock_track_1" "stdout"
test_track_displayed "$stdout" "mock_track_4" "stdout"
