#!/bin/bash

# test: itunes search
# test: itunes search [all] <search>
# test: itunes search {track | tracks | song | songs} <search>
# test: itunes search {album | albums} <search>

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

tests_per_search=$((3 + $tests_per_search_fetched))
tests_per_search_all=$(((1 * $tests_per_search) + (2 * tests_per_track_displayed)))
tests_per_search_track=$(((1 * $tests_per_search) + (2 * tests_per_track_displayed)))
tests_per_search_album=$(((1 * $tests_per_search) + (1 * tests_per_track_displayed)))

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

# test: itunes search <search>
search_term="kathy's song (come lie next to me)"
search_term_regexp=$(regexp_quotemeta "$search_term")
test_name="'itunes search $search_term'"
dispatch_mocked_command "search" "$search_term"

is "$stderr" "" "stderr of $test_name should be empty"
test_send_commands_search_fetch 0 "first" "$search_term" "only all" "$test_name"
like "$stdout" "Searching for tracks with anything containing \"$search_term_regexp\"" "stdout of $test_name should tell user what is being searched for"
test_track_displayed "$stdout" "mock_track_1" "stdout of $test_name"
test_track_displayed "$stdout" "mock_track_4" "stdout of $test_name"
is "${#sent_commands[*]}" "$commands_per_search" "number of commands sent for $test_name should be correct"

# test: itunes search [all] <search>
search_term="kathy's song (come lie next to me)"
search_term_regexp=$(regexp_quotemeta "$search_term")
test_name="'itunes search all $search_term'"
dispatch_mocked_command "search" "all" "$search_term"

is "$stderr" "" "stderr of $test_name should be empty"
test_send_commands_search_fetch 0 "first" "$search_term" "only all" "$test_name"
like "$stdout" "Searching for tracks with anything containing \"$search_term_regexp\"" "stdout of $test_name should tell user what is being searched for"
test_track_displayed "$stdout" "mock_track_1" "stdout of $test_name"
test_track_displayed "$stdout" "mock_track_4" "stdout of $test_name"
is "${#sent_commands[*]}" "$commands_per_search" "number of commands sent for $test_name should be correct"

# test: itunes search {track | tracks | song | songs} <search>
for search_restriction in "track" "tracks" "song" "songs"; do
    search_term="kathy's song (come lie next to me)"
    search_term_regexp=$(regexp_quotemeta "$search_term")
    test_name="'itunes search $search_restriction $search_term'"
    dispatch_mocked_command "search" "$search_restriction" "$search_term"

    is "$stderr" "" "stderr of $test_name should be empty"
    test_send_commands_search_fetch 0 "first" "$search_term" "only songs" "$test_name"
    like "$stdout" "Searching for tracks with name containing \"$search_term_regexp\"" "stdout of $test_name should tell user what is being searched for"
    test_track_displayed "$stdout" "mock_track_1" "stdout of $test_name"
    test_track_displayed "$stdout" "mock_track_4" "stdout of $test_name"
    is "${#sent_commands[*]}" "$commands_per_search" "number of commands sent for $test_name should be correct"
done

# test: itunes search {album | albums} <search>
for search_restriction in "album" "albums"; do
    search_term="welcome to earth \"extra bit for testing\""
    search_term_regexp=$(regexp_quotemeta "$search_term")
    test_name="'itunes search $search_restriction $search_term'"
    dispatch_mocked_command "search" "$search_restriction" "$search_term"

    is "$stderr" "" "stderr of $test_name should be empty"
    test_send_commands_search_fetch 0 "first" "$search_term" "only albums" "$test_name"
    like "$stdout" "Searching for tracks with album title containing \"$search_term_regexp\"" "stdout of $test_name should tell user what is being searched for"
    test_track_displayed "$stdout" "mock_track_1" "stdout of $test_name"
    is "${#sent_commands[*]}" "$commands_per_search" "number of commands sent for $test_name should be correct"
done
