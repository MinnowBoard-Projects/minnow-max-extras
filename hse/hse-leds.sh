#!/bin/sh

LED1=109
LED2=110
LED3=111
LED4=112

led1() {
	echo $1 > /sys/class/gpio/gpio$LED1/value
}

led2() {
	echo $1 > /sys/class/gpio/gpio$LED2/value
}

led3() {
	echo $1 > /sys/class/gpio/gpio$LED3/value
}

led4() {
	echo $1 > /sys/class/gpio/gpio$LED4/value
}

off() {
	led1 0
	led2 0
	led3 0
	led4 0
}

if [ ! -d /sys/class/gpio/gpio$LED1 -o ! -d /sys/class/gpio/gpio$LED2 -o \
     ! -d /sys/class/gpio/gpio$LED3 -o ! -d /sys/class/gpio/gpio$LED4 ]; then
	echo $LED1 > /sys/class/gpio/export
	echo $LED2 > /sys/class/gpio/export
	echo $LED3 > /sys/class/gpio/export
	echo $LED4 > /sys/class/gpio/export
fi

if [ ! -d /sys/class/gpio/gpio$LED1 -o ! -d /sys/class/gpio/gpio$LED2 ]; then
	echo "Failed to export GPIOs"
	exit 1
fi

echo out > /sys/class/gpio/gpio$LED1/direction
echo out > /sys/class/gpio/gpio$LED2/direction
echo out > /sys/class/gpio/gpio$LED3/direction
echo out > /sys/class/gpio/gpio$LED4/direction

i=0
LED2_VAL=0
LED3_VAL=0
LED4_VAL=0
while true ; do
	led1 $((i%2))
	if [ $((i%3)) -eq 0 ]; then
		LED2_VAL=$(($((LED2_VAL+1))%2))
		led2 $LED2_VAL
	fi
	if [ $((i%4)) -eq 0 ]; then
		LED3_VAL=$(($((LED3_VAL+1))%2))
		led3 $LED3_VAL
	fi
	if [ $((i%5)) -eq 0 ]; then
		LED4_VAL=$(($((LED4_VAL+1))%2))
		led4 $LED4_VAL
	fi
	sleep 1
	i=$((i+1))
done
