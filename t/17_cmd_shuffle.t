#!/bin/bash

# test: itunes shuffle (while on)
# test: itunes shuffle (while off)
# test: itunes shuffle on
# test: itunes shuffle off
# test: itunes shuffle neitheronnoroff

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

tests_per_shuffle="4"
tests_per_shuffle_on="4"
tests_per_shuffle_off="4"
tests_per_shuffle_neitheronnoroff="3"

plan tests $(((2 * $tests_per_shuffle) + (1 * $tests_per_shuffle_on) + (1 * $tests_per_shuffle_off) + (1 * $tests_per_shuffle_neitheronnoroff)))

function mock_osascript() {
    record_sent_command "$*"
    if [[ "$*" =~ "to shuffle of current playlist" ]]; then
        echo "$shuffle_state"
    fi
}

# test: itunes shuffle (while on)
shuffle_state="true"
test_name="'itunes shuffle' (while on)"
dispatch_mocked_command "shuffle"

is "$stderr" "" "stderr of $test_name should be empty"
like "${sent_commands[0]}" "to shuffle of current playlist" "first command of $test_name should contain 'to shuffle of current playlist'"
like "$stdout" "Current shuffle setting is on." "stdout of $test_name should report that shuffle is on"
is "${#sent_commands[*]}" "1" "number of commands sent for $test_name should be correct"

# test: itunes shuffle (while off)
shuffle_state="false"
test_name="'itunes shuffle' (while off)"
dispatch_mocked_command "shuffle"

is "$stderr" "" "stderr of $test_name should be empty"
like "${sent_commands[0]}" "to shuffle of current playlist" "first command of $test_name should contain 'to shuffle of current playlist'"
like "$stdout" "Current shuffle setting is off." "stdout of $test_name should report that shuffle is off"
is "${#sent_commands[*]}" "1" "number of commands sent for $test_name should be correct"

# test: itunes shuffle on
test_name="'itunes shuffle on'"
dispatch_mocked_command "shuffle" "on"

is "$stderr" "" "stderr of $test_name should be empty"
like "${sent_commands[0]}" "set shuffle of current playlist to true" "first command of $test_name should contain 'set shuffle of current playlist to true'"
like "$stdout" "Switching shuffle on." "stdout of $test_name should report that shuffle is being switched on"
is "${#sent_commands[*]}" "1" "number of commands sent for $test_name should be correct"

# test: itunes shuffle off
test_name="'itunes shuffle off'"
dispatch_mocked_command "shuffle" "off"

is "$stderr" "" "stderr of $test_name should be empty"
like "${sent_commands[0]}" "set shuffle of current playlist to false" "first command of $test_name should contain 'set shuffle of current playlist to false'"
like "$stdout" "Switching shuffle off." "stdout of $test_name should report that shuffle is being switched off"
is "${#sent_commands[*]}" "1" "number of commands sent for $test_name should be correct"

# test: itunes shuffle neitheronnoroff
test_name="'itunes shuffle neitheronnoroff'"
dispatch_mocked_command "shuffle" "neitheronnoroff"

like "$stderr" "Shuffle must be one of 'on' or 'off'." "stderr of $test_name should give correct usage"
is "$stdout" "" "stdout of $test_name should be empty"
is "${#sent_commands[*]}" "0" "number of commands sent for $test_name should be correct"
