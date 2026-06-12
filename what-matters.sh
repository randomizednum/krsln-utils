#!/bin/sh
# Finds only what matters.

find $1 \
	"!" -name "*.o" \
	"!" -name "*.a" \
	"!" -name ".*"  \
	"!" -empty      \
	-type f         \
	-exec check-binary-file --isnt '{}' ";" \
	-exec echo "{}" ";"
