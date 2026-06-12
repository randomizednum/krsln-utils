#!/bin/sh

if [ $1 = "--isnt" ]; then
	if check-binary-file --is $2; then
		 exit 1;
	fi
	exit 0
fi

if [ -z $2 ]; then
	check-binary-file --is $1
	exit $?
fi

if file $2 | grep -q text; then
	exit 1
fi
exit 0
