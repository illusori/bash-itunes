#!/bin/bash

# test: itunes repeat (while one)
# test: itunes repeat (while all)
# test: itunes repeat (while off)
# test: itunes repeat one
# test: itunes repeat all
# test: itunes repeat off
# test: itunes repeat invalid

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

tests_per_repeat="4"
tests_per_repeat_set="4"
tests_per_repeat_invalid="3"

plan tests $(((3 * $tests_per_repeat) + (3 * $tests_per_repeat_set) + (1 * $tests_per_repeat_invalid)))

function mock_osascript() {
    record_sent_command "$*"
    if [[ "$*" =~ "to song repeat of current playlist" ]]; then
        echo "$repeat_state"
    fi
}

# test: itunes repeat (while one)
# test: itunes repeat (while all)
# test: itunes repeat (while off)
for repeat_state in "one" "all" "off"; do
    test_name="'itunes repeat' (while $repeat_state)"
    dispatch_mocked_command "repeat"

    is "$stderr" "" "stderr of $test_name should be empty"
    like "${sent_commands[0]}" "to song repeat of current playlist" "first command of $test_name should contain 'to song repeat of current playlist'"
    like "$stdout" "Current repeat setting is $repeat_state." "stdout of $test_name should report that repeat is $repeat_state"
    is "${#sent_commands[*]}" "1" "number of commands sent for $test_name should be correct"
done

# test: itunes repeat one
# test: itunes repeat all
# test: itunes repeat off
for repeat_state in "one" "all" "off"; do
    test_name="'itunes repeat $repeat_state'"
    dispatch_mocked_command "repeat" "$repeat_state"

    is "$stderr" "" "stderr of $test_name should be empty"
    like "${sent_commands[0]}" "set song repeat of current playlist to $repeat_state" "first command of $test_name should contain 'set song repeat of current playlist to $repeat_state'"
    like "$stdout" "Switching repeat to $repeat_state." "stdout of $test_name should report that repeat is being switched to $repeat_state"
    is "${#sent_commands[*]}" "1" "number of commands sent for $test_name should be correct"
done

# test: itunes repeat invalid
test_name="'itunes repeat invalid'"
dispatch_mocked_command "repeat" "invalid"

like "$stderr" "Repeat must be one of 'one', 'all' or 'off'." "stderr of $test_name should give correct usage"
is "$stdout" "" "stdout of $test_name should be empty"
is "${#sent_commands[*]}" "0" "number of commands sent for $test_name should be correct"
