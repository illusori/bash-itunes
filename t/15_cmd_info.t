#!/bin/bash

# test: itunes info
# test: itunes info track
# test: itunes info track <track name>
# test: itunes info playlist
# TODO: test: itunes info playlist <playlist name>

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

tests_per_info_current_track=$((1 + (1 * tests_per_current_track_fetched) + (1 * tests_per_track_displayed)))
tests_per_info_named_track=$((1 + (1 * tests_per_track_fetched) + (1 * tests_per_track_displayed)))

tests_per_info_current_playlist=$((5 + (1 * tests_per_playlist_displayed) + (4 * tests_per_track_displayed)))
tests_per_info_named_playlist=$((0 + (1 * tests_per_playlist_displayed) + (2 * tests_per_track_displayed)))

plan tests $(((2 * tests_per_info_current_track) + (1 * tests_per_info_named_track) + (1 * tests_per_info_current_playlist) + (0 * tests_per_info_named_playlist)))

function mock_osascript() {
    record_sent_command "$*"
    if [[ "$*" =~ 'of current track' ]]; then
        echo "$mock_track_1_data"
    elif [[ "$*" =~ 'of track "Sapphire"' ]]; then
        echo "$mock_track_3_data"
    elif [[ "$*" =~ 'player position' ]]; then
        echo "60"
    elif [[ "$*" =~ '(name, time, id) of current playlist' ]]; then
        echo "$mock_playlist_1_data"
    elif [[ "$*" =~ 'count tracks' && "$*" =~ 'current playlist' ]]; then
        echo "$mock_playlist_1_count"
    elif [[ "$*" =~ 'of every track of current playlist' ]]; then
        echo "$mock_playlist_1_tracks"
    elif [[ "$*" =~ '(name, time, id) of playlist "c Synth+Ind (Great)"' ]]; then
        echo "$mock_playlist_2_data"
    elif [[ "$*" =~ 'count tracks' && "$*" =~ 'playlist "c Synth+Ind (Great)"' ]]; then
        echo "$mock_playlist_2_count"
    elif [[ "$*" =~ 'of every track of playlist "c Synth+Ind (Great)"' ]]; then
        echo "$mock_playlist_2_tracks"
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

is "$stderr" "" "stderr of 'itunes info' should be empty"
test_send_commands_current_track_fetch "0" "first" "'itunes info'"
test_track_displayed "$stdout" "mock_track_1" "stdout of 'itunes info'" "verbose"

# Current track is cached, clear it after.
_scrub_current_track

# test: itunes info track
clear_sent_commands
mock_function "_osascript" "mock_osascript"
start_output_capture

_dispatch "info" "track"

finish_output_capture stdout stderr
restore_mocked_function "_osascript"
read_sent_commands

is "$stderr" "" "stderr of 'itunes info track' should be empty"
test_send_commands_current_track_fetch "0" "first" "'itunes info track'"
test_track_displayed "$stdout" "mock_track_1" "stdout of 'itunes info track'" "verbose"

# Current track is cached, clear it after.
_scrub_current_track

# test: itunes info track <track name>
clear_sent_commands
mock_function "_osascript" "mock_osascript"
start_output_capture

_dispatch "info" "track" "Sapphire"

finish_output_capture stdout stderr
restore_mocked_function "_osascript"
read_sent_commands

is "$stderr" "" "stderr of 'itunes info track Sapphire' should be empty"
test_send_commands_track_fetch "0" "first" 'of track "Sapphire"' "'itunes info track Sapphire'"
test_track_displayed "$stdout" "mock_track_3" "stdout of 'itunes info track Sapphire'" "verbose"

# test: itunes info playlist
clear_sent_commands
mock_function "_osascript" "mock_osascript"
start_output_capture

_dispatch "info" "playlist"

finish_output_capture stdout stderr
restore_mocked_function "_osascript"
read_sent_commands

is "$stderr" "" "stderr of 'itunes info' should be empty"

like "${sent_commands[0]}" 'of current track' "first sent command of 'itunes info playlist' should be fetch of 'current track'"
like "${sent_commands[0]}" 'tell application "iTunes"' "first sent command of 'itunes info playlist' should contain 'tell application \"iTunes\"'"
like "${sent_commands[1]}" 'player position as integer' "second sent command of 'itunes info playlist' should contain 'player position as integer'"
like "${sent_commands[1]}" 'tell application "iTunes"' "second sent command of 'itunes info playlist' should contain 'tell application \"iTunes\"'"

test_playlist_displayed "$stdout" "mock_playlist_1" "stdout of 'itunes info playlist'"
test_track_displayed "$stdout" "mock_track_1" "stdout of 'itunes info playlist'"
test_track_displayed "$stdout" "mock_track_2" "stdout of 'itunes info playlist'"
test_track_displayed "$stdout" "mock_track_3" "stdout of 'itunes info playlist'"
test_track_displayed "$stdout" "mock_track_4" "stdout of 'itunes info playlist'"

# Current track is cached, clear it after.
_scrub_current_track



# TODO: test: itunes info playlist <playlist name>
