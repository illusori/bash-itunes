#!/bin/bash

# test: itunes help

. $(dirname $0)/bash-tap-bootstrap
. $(dirname $0)/../itunes

plan tests 1

output=$(_dispatch "help")
like "$output" "Show this help and exit" "help text should be displayed"
