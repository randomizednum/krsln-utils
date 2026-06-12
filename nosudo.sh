#!/bin/sh

# Replaces sudo with an alternative or a do-it-yourself mode.
# Some scripts force you to use sudo and I wrote this as a bad alternative.
# This is somewhat hacky and even I ended up accepting sudo in that case.

# notify-send "nosudo called" "with $*"
echo "nosudo: running sudo $@" > /dev/tty

export maybe_diy_mode=

if [ -z "$NOSUDO_NO_DIY_MODE" ]; then
	for arg in "$@"; do
		case $arg in -*)
			export maybe_diy_mode=1
		esac
	done
fi

if [ "$maybe_diy_mode" -a "!" "$NOSUDO_DIY_MODE" ]; then
	< /dev/tty read -p "nosudo: enable DIY mode? (y/n): " answer > /dev/tty
	case $answer in
	n)
		# su will be called instead
		;;
	y)
		export NOSUDO_DIY_MODE=1 ;;
	*)
		echo "not understood, enabling DIY mode" > /dev/tty
		export NOSUDO_DIY_MODE=1 ;;
	esac
fi

if [ "$NOSUDO_DIY_MODE" ]; then
	echo "nosudo: DIY mode" > /dev/tty
	< /dev/tty sh > /dev/tty
	exit
fi

< /dev/tty su -c "$*"
