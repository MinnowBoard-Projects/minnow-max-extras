#!/bin/sh

LED1=248
LED2=249

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

LED1=$(( ${LED1} + ${OFFSET} ))
LED2=$(( ${LED2} + ${OFFSET} ))


led1() {
	echo $1 > /sys/class/gpio/gpio$LED1/value
}

led2() {
	echo $1 > /sys/class/gpio/gpio$LED2/value
}

off() {
	led1 0
	led2 0
}

if [ ! -d /sys/class/gpio/gpio$LED1 -o ! -d /sys/class/gpio/gpio$LED2 ]; then
	echo $LED1 > /sys/class/gpio/export
	echo $LED2 > /sys/class/gpio/export
fi

if [ ! -d /sys/class/gpio/gpio$LED1 -o ! -d /sys/class/gpio/gpio$LED2 ]; then
	echo "Failed to export GPIOs"
	echo "Are the pins setup as PWM? If so, try calamari-leds-pwm.sh"
	exit 1
fi

echo out > /sys/class/gpio/gpio$LED1/direction
echo out > /sys/class/gpio/gpio$LED2/direction

i=0
LED2_VAL=0
while true ; do
	led1 $((i%2))
	if [ $((i%4)) -eq 0 ]; then
		LED2_VAL=$(($((LED2_VAL+1))%2))
		led2 $LED2_VAL
	fi
	sleep 1
	i=$((i+1))
done
