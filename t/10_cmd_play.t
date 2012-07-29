#!/bin/bash

# test: itunes {play | resume | unpause}

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

plan tests $((3 * (8 + (1 * tests_per_track_displayed))))

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
    like "${sent_commands[0]}" 'tell application "iTunes"' "first sent of $test_name command should contain 'tell application \"iTunes\"'"
    like "${sent_commands[1]}" 'of current track' "second sent command of $test_name should be fetch of 'current track'"
    like "${sent_commands[1]}" 'tell application "iTunes"' "second sent of $test_name command should contain 'tell application \"iTunes\"'"
    like "${sent_commands[2]}" 'player position as integer' "third sent command of $test_name should contain 'player position as integer'"
    like "${sent_commands[2]}" 'tell application "iTunes"' "third sent command of $test_name should contain 'tell application \"iTunes\"'"

    like "$stdout" "Resuming" "stdout of $test_name should tell user that play is resuming"
    test_track_displayed "$stdout" "mock_track_1" "stdout of $test_name"
done
