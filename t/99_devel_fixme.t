#!/bin/bash

# test: make sure I've left no FIXMEs in the release.

. $(dirname $0)/bash-tap-bootstrap
. "$BASH_TAP_ROOT/bash-tap-mock"
. $(dirname $0)/bash-itunes-test-functions
. $(dirname $0)/../itunes

plan tests 2

command_fixme=`grep 'FIXME' $(dirname $0)/../itunes`
tests_fixme=`grep 'FIXME' $(dirname $0)/*.t --exclude '*_devel_fixme.t'`

is "$command_fixme" "" "Should be no FIXME items in the main command"
is "$tests_fixme" "" "Should be no FIXME items in the unit tests"
