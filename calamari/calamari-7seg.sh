#!/bin/sh

CLOCK=84
LATCH=219
DATA=218
CLEAR=217

# $1 GPIO
# $2 VAL (0 or 1)
setval() {
	echo $2 > /sys/class/gpio/gpio$1/value
}

tick() {
	setval $CLOCK 1
	setval $CLOCK 0
}

clock0in() {
	setval $DATA 1
	tick
}

clock1in() {
	setval $DATA 0
	tick
}

latch() {
	setval $LATCH 0
	setval $LATCH 1
	setval $LATCH 0
}

clear() {
	setval $CLEAR 1
	setval $CLEAR 0
	setval $CLEAR 1
}

if [ ! -d /sys/class/gpio/gpio$CLOCK -o \
     ! -d /sys/class/gpio/gpio$LATCH -o \
     ! -d /sys/class/gpio/gpio$CLEAR -o \
     ! -d /sys/class/gpio/gpio$DATA ]; then
	echo $CLOCK > /sys/class/gpio/export
	echo $LATCH > /sys/class/gpio/export
	echo $DATA > /sys/class/gpio/export
	echo $CLEAR > /sys/class/gpio/export
fi

if [ ! -d /sys/class/gpio/gpio$CLOCK -o \
     ! -d /sys/class/gpio/gpio$LATCH -o \
     ! -d /sys/class/gpio/gpio$CLEAR -o \
     ! -d /sys/class/gpio/gpio$DATA ]; then
	echo "Failed to export GPIOs"
	exit 1
fi

echo out > /sys/class/gpio/gpio${CLOCK}/direction
echo out > /sys/class/gpio/gpio${LATCH}/direction
echo out > /sys/class/gpio/gpio${DATA}/direction
echo out > /sys/class/gpio/gpio${CLEAR}/direction

setval $CLOCK 0
setval $LATCH 0
setval $DATA 0
setval $CLEAR 0

clear

while [ 1 ] ; do
clock0in
clock0in
clock0in
clock0in
clock0in
clock0in
clock0in
clock0in
latch

sleep 1

clock1in
clock0in
clock0in
clock0in
clock0in
clock0in
clock0in
clock0in
latch

sleep 1

clock0in
clock1in
clock0in
clock0in
clock0in
clock0in
clock0in
clock0in
latch

sleep 1

clock0in
clock0in
clock1in
clock0in
clock0in
clock0in
clock0in
clock0in
latch

sleep 1

clock0in
clock0in
clock0in
clock1in
clock0in
clock0in
clock0in
clock0in
latch

sleep 1

clock0in
clock0in
clock0in
clock0in
clock1in
clock0in
clock0in
clock0in
latch

sleep 1

clock0in
clock0in
clock0in
clock0in
clock0in
clock1in
clock0in
clock0in
latch

sleep 1

clock0in
clock0in
clock0in
clock0in
clock0in
clock0in
clock1in
clock0in
latch

sleep 1

clock0in
clock0in
clock0in
clock0in
clock0in
clock0in
clock0in
clock1in
latch

sleep 1

clock1in
clock1in
clock1in
clock1in
clock1in
clock1in
clock1in
clock1in
latch

sleep 1

done
