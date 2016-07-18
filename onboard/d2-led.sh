#!/bin/sh

#
# Use GPIO 104 if you are on a kernel older than 3.18
# Use GPIO 360 if you are on a kernel newer than 3.17
# Defaulting to the later at this point
#
#LED1=104
LED1=360

led1() {
	echo $1 > /sys/class/gpio/gpio$LED1/value
}

off() {
	led1 0
}

if [ \
	! -d /sys/class/gpio/gpio$LED1 ]; then
	echo $LED1 > /sys/class/gpio/export
fi

if [ ! -d /sys/class/gpio/gpio$LED1 ]; then
	echo "Failed to export GPIOs"
	echo "Are the pins setup as PWM? If so, try calamari-leds-pwm.sh"
	exit 1
fi

echo out > /sys/class/gpio/gpio$LED1/direction

i=0
while true ; do
	led1 $((i%2))
	sleep 1
	i=$((i+1))
done
