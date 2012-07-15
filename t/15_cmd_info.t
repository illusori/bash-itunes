#!/bin/bash

# test: itunes info
# test: itunes info track
# TODO: test: itunes info track <track name>
# TODO: test: itunes info playlist
# TODO: test: itunes info playlist <playlist name>

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

tests_per_info_current_track=$((5 + (1 * tests_per_track_displayed)))
tests_per_info_named_track=$((tests_per_info_current_track - 2))

tests_per_info_current_playlist=$((0 + (0 * tests_per_track_displayed)))
tests_per_info_named_playlist=$((tests_per_info_current_playlist - 1))

plan tests $(((2 * tests_per_info_current_track) + (1 * tests_per_info_named_track) + (0 * tests_per_current_playlist) + (0 * tests_per_named_playlist)))

function mock_osascript() {
    record_sent_command "$*"
    if [[ "$*" =~ 'of current track' ]]; then
        echo "$mock_track_1_data"
    elif [[ "$*" =~ 'of track "Sapphire"' ]]; then
        echo "$mock_track_3_data"
    elif [[ "$*" =~ 'player position' ]]; then
        echo "60"
    fi
}

# test: itunes info
clear_sent_commands
mock_function "_osascript" "mock_osascript"
start_output_capture

_dispatch "info"

finish_output_capture stdout stderr
restore_mocked_function "_osascript"
read_sent_commands

like "${sent_commands[0]}" 'of current track' "first sent command of 'itunes info' should be fetch of 'current track'"
like "${sent_commands[0]}" 'tell application "iTunes"' "first sent command of 'itunes info' should contain 'tell application \"iTunes\"'"
like "${sent_commands[1]}" 'player position as integer' "second sent command of 'itunes info' should contain 'player position as integer'"
like "${sent_commands[1]}" 'tell application "iTunes"' "second sent command of 'itunes info' should contain 'tell application \"iTunes\"'"

test_track_displayed "$stdout" "mock_track_1" "stdout of 'itunes info'" "verbose"
is "$stderr" "" "stderr of 'itunes info' should be empty"

# test: itunes info track

# Current track is cached, clear it first.
_scrub_current_track

clear_sent_commands
mock_function "_osascript" "mock_osascript"
start_output_capture

_dispatch "info" "track"

finish_output_capture stdout stderr
restore_mocked_function "_osascript"
read_sent_commands

like "${sent_commands[0]}" 'of current track' "first sent command of 'itunes info track' should be fetch of 'current track'"
like "${sent_commands[0]}" 'tell application "iTunes"' "first sent command of 'itunes info track' should contain 'tell application \"iTunes\"'"
like "${sent_commands[1]}" 'player position as integer' "second sent command of 'itunes info track' should contain 'player position as integer'"
like "${sent_commands[1]}" 'tell application "iTunes"' "second sent command of 'itunes info track' should contain 'tell application \"iTunes\"'"

test_track_displayed "$stdout" "mock_track_1" "stdout of 'itunes info track'" "verbose"
is "$stderr" "" "stderr of 'itunes info track' should be empty"

# test: itunes info track <track name>
clear_sent_commands
mock_function "_osascript" "mock_osascript"
start_output_capture

_dispatch "info" "track" "Sapphire"

finish_output_capture stdout stderr
restore_mocked_function "_osascript"
read_sent_commands

like "${sent_commands[0]}" 'of track "Sapphire"' "first sent command of 'itunes info track Sapphire' should be fetch of track named 'Sapphire'"
like "${sent_commands[0]}" 'tell application "iTunes"' "first sent command of 'itunes info track Sapphire' should contain 'tell application \"iTunes\"'"

test_track_displayed "$stdout" "mock_track_3" "stdout of 'itunes info track Sapphire'" "verbose"
is "$stderr" "" "stderr of 'itunes info track Sapphire' should be empty"

# TODO: test: itunes info playlist
# TODO: test: itunes info playlist <playlist name>
