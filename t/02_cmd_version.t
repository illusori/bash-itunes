#!/bin/bash

. $(dirname $0)/bash-tap-bootstrap
. $(dirname $0)/../itunes

plan tests 1

output=$(_dispatch "version")
like "$output" " version " "version should be displayed"
