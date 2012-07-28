#!/bin/bash

# TODO: test: itunes search
# TODO: test: itunes search [all] <search>
# TODO: test: itunes search {track | tracks | song | songs} <search>
# TODO: test: itunes search {album | albums} <search>

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

tests_per_search=$((3 + $tests_per_search_fetched))

plan tests $(((1 * $tests_per_search) + (2 * tests_per_track_displayed)))

function mock_osascript() {
    record_sent_command "$*"
    if [[ "$*" =~ 'search playlist "Library" for "kathy"' ]]; then
        echo "$mock_track_1_data
$mock_track_4_data"
    fi
}

# test: itunes search <search>
test_name="'itunes search kathy'"
dispatch_mocked_command "search" "kathy"

is "$stderr" "" "stderr of $test_name should be empty"
test_send_commands_search_fetch 0 "first" "kathy" "only all" "$test_name"
like "$stdout" "Searching for tracks with anything containing \"kathy\"" "stdout of $test_name should tell user what is being search for"
test_track_displayed "$stdout" "mock_track_1" "stdout of $test_name"
test_track_displayed "$stdout" "mock_track_4" "stdout of $test_name"
is "${#sent_commands[*]}" "$commands_per_search" "number of commands sent for $test_name should be correct"
