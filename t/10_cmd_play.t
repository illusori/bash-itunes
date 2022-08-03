#!/bin/bash

# test: itunes {play | resume | unpause}
# test: itunes play <track>

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

tests_per_play=$(((4 + (1 * tests_per_current_track_fetched) + (1 * tests_per_track_displayed))))
tests_per_play_track=$(((8 + (1 * tests_per_current_track_fetched) + (1 * tests_per_track_displayed))))

plan tests $(((3 * tests_per_play) + (1 * tests_per_play_track)))

function mock_osascript() {
    record_sent_command "$*"
    if [[ "$*" =~ 'of current track' ]]; then
        echo "$mock_track_1_data"
    elif [[ "$*" =~ 'player position' ]]; then
        echo "60"
    fi
}

# test: itunes {play | resume | unpause}
for subcommand in "play" "resume" "unpause"; do
    test_name="'itunes $subcommand'"
    dispatch_mocked_command "$subcommand"

    is "$stderr" "" "stderr of $test_name should be empty"
    like "${sent_commands[0]}" 'play' "first sent command of $test_name should contain 'play'"
    like "${sent_commands[0]}" "tell application \"$itunes_app\"" "first sent of $test_name command should contain 'tell application \"$itunes_app\"'"

    test_send_commands_current_track_fetch "1" "second" "$test_name"

    like "$stdout" "Resuming" "stdout of $test_name should tell user that play is resuming"
    test_track_displayed "$stdout" "mock_track_1" "stdout of $test_name"
done

# test: itunes play <track>
test_name="'itunes play storm'"
dispatch_mocked_command "play" "storm"

is "$stderr" "" "stderr of $test_name should be empty"
like "${sent_commands[0]}" 'play' "first sent command of $test_name should contain 'play'"
like "${sent_commands[0]}" 'tracks of current playlist whose name is "storm"' "first sent command of $test_name should try to play exact match from current playlist"
like "${sent_commands[0]}" 'tracks of current playlist whose name contains "storm"' "first sent command of $test_name should try to play substring match from current playlist"
like "${sent_commands[0]}" 'tracks whose name is "storm"' "first sent command of $test_name should try to play exact match from library"
like "${sent_commands[0]}" 'tracks whose name contains "storm"' "first sent command of $test_name should try to play substring match from library"
like "${sent_commands[0]}" "tell application \"$itunes_app\"" "first sent of $test_name command should contain 'tell application \"$itunes_app\"'"

test_send_commands_current_track_fetch "1" "second" "$test_name"

like "$stdout" "Now playing" "stdout of $test_name should tell user 'Now playing'"
test_track_displayed "$stdout" "mock_track_1" "stdout of $test_name"
