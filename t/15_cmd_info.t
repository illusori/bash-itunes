#!/bin/bash

# test: itunes info
# test: itunes info track
# test: itunes info track <track name>
# test: itunes info playlist
# test: itunes info playlist <playlist name>

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

tests_per_info_current_track=$((2 + (1 * tests_per_current_track_fetched) + (1 * tests_per_track_displayed)))
tests_per_info_named_track=$((2 + (1 * tests_per_track_fetched) + (1 * tests_per_track_displayed)))

tests_per_info_current_playlist=$((2 + (1 * tests_per_current_track_fetched) + (1 * tests_per_current_playlist_fetched) + (1 * tests_per_playlist_displayed) + (4 * tests_per_track_displayed)))
tests_per_info_named_playlist=$((2 + (1 * tests_per_playlist_fetched) + (1 * tests_per_playlist_displayed) + (2 * tests_per_track_displayed)))

commands_per_current_track=$(((1 * commands_per_current_track_fetched)))
commands_per_named_track=$(((1 * commands_per_track_fetched)))
commands_per_current_playlist=$(((1 * commands_per_current_playlist_fetched) + (1 * commands_per_current_track_fetched)))
commands_per_named_playlist=$(((1 * commands_per_playlist_fetched)))

plan tests $(((2 * tests_per_info_current_track) + (1 * tests_per_info_named_track) + (1 * tests_per_info_current_playlist) + (1 * tests_per_info_named_playlist)))

function mock_osascript() {
    record_sent_command "$*"
    if [[ "$*" =~ 'of (current track)' ]]; then
        echo "$mock_track_1_data"
    elif [[ "$*" =~ 'of (track "Sapphire")' ]]; then
        echo "$mock_track_3_data"
    elif [[ "$*" =~ 'player position' ]]; then
        echo "60"
    elif [[ "$*" =~ '(name, time, id) of (current playlist)' ]]; then
        echo "$mock_playlist_1_data"
    elif [[ "$*" =~ 'count tracks' && "$*" =~ 'current playlist' ]]; then
        echo "$mock_playlist_1_count"
    elif [[ "$*" =~ 'of (every track of current playlist)' ]]; then
        echo "$mock_playlist_1_tracks"
    elif [[ "$*" =~ '(name, time, id) of (playlist "c Synth+Ind (Great)")' ]]; then
        echo "$mock_playlist_2_data"
    elif [[ "$*" =~ 'count tracks' && "$*" =~ 'playlist "c Synth+Ind (Great)"' ]]; then
        echo "$mock_playlist_2_count"
    elif [[ "$*" =~ 'of (every track of playlist "c Synth+Ind (Great)")' ]]; then
        echo "$mock_playlist_2_tracks"
    fi
}

# test: itunes info
test_name="'itunes info'"
dispatch_mocked_command "info"

is "$stderr" "" "stderr of $test_name should be empty"
test_send_commands_current_track_fetch "0" "first" "$test_name"
test_track_displayed "$stdout" "mock_track_1" "stdout of $test_name" "verbose"
is "${#sent_commands[*]}" "$commands_per_current_track" "number of commands sent for $test_name should be correct"

# Current track is cached, clear it after.
_scrub_current_track

# test: itunes info track
test_name="'itunes info track'"
dispatch_mocked_command "info" "track"

is "$stderr" "" "stderr of $test_name should be empty"
test_send_commands_current_track_fetch "0" "first" "$test_name"
test_track_displayed "$stdout" "mock_track_1" "stdout of $test_name" "verbose"
is "${#sent_commands[*]}" "$commands_per_current_track" "number of commands sent for $test_name should be correct"

# Current track is cached, clear it after.
_scrub_current_track

# test: itunes info track <track name>
test_name="'itunes info track $mock_track_3_name'"
dispatch_mocked_command "info" "track" "$mock_track_3_name"

is "$stderr" "" "stderr of $test_name should be empty"
test_send_commands_track_fetch "0" "first" 'track "Sapphire"' "$test_name"
test_track_displayed "$stdout" "mock_track_3" "stdout of $test_name" "verbose"
is "${#sent_commands[*]}" "$commands_per_named_track" "number of commands sent for $test_name should be correct"

# test: itunes info playlist
test_name="'itunes info playlist'"
dispatch_mocked_command "info" "playlist"

is "$stderr" "" "stderr of $test_name should be empty"
test_send_commands_current_track_fetch "0" "first" "$test_name"
test_send_commands_current_playlist_fetch "3" "fourth" "$test_name"
test_playlist_displayed "$stdout" "mock_playlist_1" "stdout of $test_name"
test_track_displayed "$stdout" "mock_track_1" "stdout of $test_name"
test_track_displayed "$stdout" "mock_track_2" "stdout of $test_name"
test_track_displayed "$stdout" "mock_track_3" "stdout of $test_name"
test_track_displayed "$stdout" "mock_track_4" "stdout of $test_name"
is "${#sent_commands[*]}" "$commands_per_current_playlist" "number of commands sent for $test_name should be correct"

# Current track is cached, clear it after.
_scrub_current_track

# test: itunes info playlist <playlist name>
test_name="'itunes info playlist $mock_playlist_2_name'"
dispatch_mocked_command "info" "playlist" "$mock_playlist_2_name"

is "$stderr" "" "stderr of $test_name should be empty"
test_send_commands_playlist_fetch "0" "first" "playlist \"$mock_playlist_2_name\"" "$test_name"
test_playlist_displayed "$stdout" "mock_playlist_2" "stdout of $test_name"
test_track_displayed "$stdout" "mock_track_1" "stdout of $test_name"
test_track_displayed "$stdout" "mock_track_3" "stdout of $test_name"
is "${#sent_commands[*]}" "$commands_per_named_playlist" "number of commands sent for $test_name should be correct"
