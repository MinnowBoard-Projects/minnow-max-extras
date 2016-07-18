#!/bin/sh

S1=216
S2=227
S3=226

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

S1=$(( ${S1} + ${OFFSET} ))
S2=$(( ${S2} + ${OFFSET} ))
S3=$(( ${S3} + ${OFFSET} ))

printval() {
	cat /sys/class/gpio/gpio$1/value
}


if [ ! -d /sys/class/gpio/gpio$S1 -o \
     ! -d /sys/class/gpio/gpio$S2 -o \
     ! -d /sys/class/gpio/gpio$S3 ]; then
	echo $S1 > /sys/class/gpio/export
	echo $S2 > /sys/class/gpio/export
	echo $S3 > /sys/class/gpio/export
fi

if [ ! -d /sys/class/gpio/gpio$S1 -o \
     ! -d /sys/class/gpio/gpio$S2 -o \
     ! -d /sys/class/gpio/gpio$S3 ]; then
	echo "Failed to export GPIOs"
	exit 1
fi

echo in > /sys/class/gpio/gpio$S1/direction
echo in > /sys/class/gpio/gpio$S2/direction
echo in > /sys/class/gpio/gpio$S3/direction

while [ 1 ] ; do
	clear
	printval $S1
	printval $S2
	printval $S3	
	sleep 1
done
