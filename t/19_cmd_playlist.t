#!/bin/bash

# FIXME: finish writing these playlist tests
# TODO: test: itunes playlist
# TODO: test: itunes playlist <name>
# TODO: test: itunes playlist <name> (not found)

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

tests_per_search=$((3 + $tests_per_search_fetched))
tests_per_search_all=$(((1 * $tests_per_search) + (2 * tests_per_track_displayed)))
tests_per_search_track=$(((1 * $tests_per_search) + (2 * tests_per_track_displayed)))
tests_per_search_album=$(((1 * $tests_per_search) + (1 * tests_per_track_displayed)))

# FIXME
skip_all "not implemented"
exit

plan tests $(((2 * $tests_per_search_all) + (4 * $tests_per_search_track) + (2 * $tests_per_search_album)))

function mock_osascript() {
    record_sent_command "$*"
    if [[ "$*" =~ "search playlist \"Library\" for \"kathy's song (come lie next to me)\"" ]]; then
        echo "$mock_track_1_data
$mock_track_4_data"
    elif [[ "$*" =~ "search playlist \"Library\" for \"welcome to earth \\\"extra bit for testing\\\"\"" ]]; then
        echo "$mock_track_1_data"
    fi
}

#is "implemented" "not implemented"
