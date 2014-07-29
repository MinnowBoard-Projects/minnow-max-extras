#!/bin/sh

S1=216
S2=227
S3=226

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
