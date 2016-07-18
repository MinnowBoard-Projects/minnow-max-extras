#!/bin/sh

RED=82
GREEN=83
BLUE=208

#
# Between Linux kernel 3.17 and 3.18 there was a change in how GPIOs are enumerated
# specifically instead of counting down from 256, they now count down from 512.
# This means that all GPIOs are now offset by an additional 256 in newer kernels
# so the following code attempts to handle that
#

OFFSET="0"

KERNEL_MAJOR_MINOR=$( uname -r | awk 'BEGIN { FS="."; } ; { print $1 "." $2; }' )

if [[ ${KERNEL_MAJOR_MINOR} > 3.17 ]]
then
	OFFSET="256"
fi

RED=$(( ${RED} + ${OFFSET} ))
GREEN=$(( ${GREEN} + ${OFFSET} ))
BLUE=$(( ${BLUE} + ${OFFSET} ))


color() {
	echo $2 > /sys/class/gpio/gpio$1/value
}

off() {
	color $RED 0
	color $GREEN 0
	color $BLUE 0
}

red() {
	color $RED $1
}

green() {
	color $GREEN $1
}

blue() {
	color $BLUE $1
}

if [ ! -d /sys/class/gpio/gpio$RED -o \
     ! -d /sys/class/gpio/gpio$GREEN -o \
     ! -d /sys/class/gpio/gpio$BLUE ]; then
	echo $RED > /sys/class/gpio/export
	echo $GREEN > /sys/class/gpio/export
	echo $BLUE > /sys/class/gpio/export
fi

if [ ! -d /sys/class/gpio/gpio$RED -o \
     ! -d /sys/class/gpio/gpio$GREEN -o \
     ! -d /sys/class/gpio/gpio$BLUE ]; then
	echo "Failed to export GPIOs"
	exit 1
fi

echo out > /sys/class/gpio/gpio$RED/direction
echo out > /sys/class/gpio/gpio$GREEN/direction
echo out > /sys/class/gpio/gpio$BLUE/direction

while [ 1 ] ; do
	off
	red 1
	sleep 1

	off
	green 1
	sleep 1

	off
	blue 1
	sleep 1
	
	off
	red 1
	green 1
	sleep 1

	off
	red 1
	blue 1
	sleep 1

	off
	green 1
	blue 1
	sleep 1
	
	off
	red 1
	green 1
	blue 1
	sleep 1
	
done
