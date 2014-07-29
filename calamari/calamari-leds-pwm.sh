#!/bin/sh

SYSFS_BASE="/sys/class/pwm"

# $1 pwm chip
# $2 pwm channel
pwm_setup() {
	if [ ! -d $SYSFS_BASE/pwmchip$1/pwm$2 ]; then
		echo $2 > $SYSFS_BASE/pwmchip$1/export
	fi
	echo 1 > $SYSFS_BASE/pwmchip$1/pwm$2/enable
}

# $1 pwm chip
# $2 pwm channel
# $3 period
# $4 duty
pwm_set() {
	echo $3 > $SYSFS_BASE/pwmchip$1/pwm$2/period
	echo $4 > $SYSFS_BASE/pwmchip$1/pwm$2/duty_cycle
}

if [ ! -d /sys/class/pwm/pwmchip0 -o ! -d /sys/class/pwm/pwmchip1 ]; then
	echo "SYSFS PWM chips not found"
	exit 1
fi

pwm_setup 0 0
pwm_setup 1 0

PERIOD=1000000000 # should be 1.0s
DUTY=$(($PERIOD/2)) # should be 0.5s

while true; do
	DUTY=$(($(($DUTY+1000))%$PERIOD))
	pwm_set 0 0 $PERIOD $DUTY
	pwm_set 1 0 $PERIOD $(($PERIOD-$DUTY))
done
