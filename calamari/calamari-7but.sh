#!/bin/bash 
# Demo script for the Calamari Lure on a MinnowBoard MAX
#   Read the buttons to decrement/reset/increment a counter displayed
#   on the 7-Segment LED 

# 7-Segment Display segment patterns for chars 0-F
#   Segments are numbered like so: (with 3 being the decimal point) 
#       5
#     1   4
#       6
#     7   2
#       8    3
#
#   So to display a 0, we'd want all the segments on except for 3 & 6
#   or expressed as a binary number:  11011011  (with segment 1 as the 
#   low-order bit) or 219. decimal. For the digit 1 we want only segments 
#   2 & 4 turned on, or 00001010 or 10. decimal, etc. 
#
#   Here are the 7-segment display patterns for the hex digits from 0-F
DISPLAY=(219 10 248 186 43 179 243 27 251 187 123 227 224 234 241 113)

# GPIOs for 7-Segment Display
#  Note that for linux kernel > 3.17 the GPIO numbers are +256
#  than earlier versions of the kernel

CLOCK=$((84+256))
LATCH=$((219+256))
DATA=$((218+256))
CLEAR=$((217+256))

# GPIOs for the three switches
S1=$((216+256))
S2=$((227+256))
S3=$((226+256))

# $1 GPIO
# $2 VAL (0 or 1)
setval() {
	echo $2 > /sys/class/gpio/gpio$1/value
}

tick() {
	setval $CLOCK 1
	setval $CLOCK 0
}

clockin() {
        if [ "$1" = "0" ]; then
	   setval $DATA 1
           tick
	else
	   setval $DATA 0
           tick
	fi
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


# Display the 7-seg character for the value given as only parameter
# (using the DISPLAY array mapping): strips the bits off the low end
# one at a time, send them to the 7-seg controller along with a 
# final latch indication that all segment data is ready to display

showseg() {
   echo showing $1
   MAP=${DISPLAY[$1]}
   for i in `seq 1 8`; do
     BAR=`expr $MAP % 2`
     clockin $BAR
     MAP=`expr $MAP / 2`
   done
   latch
}


# Setup GPIO access for the 7-Segment Display

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
	echo "Failed to export GPIOs for 7-Segment LED"
	exit 1
fi

if [ ! -w /sys/class/gpio/gpio${CLOCK}/direction ]; then
   echo "Failed writing to GPIOs for 7-Segment LED"
   echo "Are you running as root?"
   exit 1
fi

echo out > /sys/class/gpio/gpio${CLOCK}/direction
echo out > /sys/class/gpio/gpio${LATCH}/direction
echo out > /sys/class/gpio/gpio${DATA}/direction
echo out > /sys/class/gpio/gpio${CLEAR}/direction

# Setup GPIO access for the three switches
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
	echo "Failed to export GPIOs for switches"
	exit 1
fi

echo in > /sys/class/gpio/gpio$S1/direction
echo in > /sys/class/gpio/gpio$S2/direction
echo in > /sys/class/gpio/gpio$S3/direction


# Here we go

setval $CLOCK 0
setval $LATCH 0
setval $DATA 0
setval $CLEAR 0

clear

# Start off with the 7-Seg display showing a 0
SEGVAL=0
showseg $SEGVAL

while [ 1 ] ; do

  # Switch 1 is for decrementing the counter
  if [ "`cat /sys/class/gpio/gpio$S1/value`" = "0" ]; then
    SEGVAL=$(($SEGVAL - 1))
    if [ $SEGVAL -lt 0 ]; then 
       SEGVAL=0;
    fi
    showseg $SEGVAL
  # Switch 3 is for incrementing the counter
  elif [ "`cat /sys/class/gpio/gpio$S3/value`" = "0" ]; then
    SEGVAL=$(($SEGVAL + 1))
    if [ $SEGVAL -gt 15 ]; then
       SEGVAL=15;
    fi
    showseg $SEGVAL
  # Switch 2 is for resetting the counter to 0
  elif [ "`cat /sys/class/gpio/gpio$S2/value`" = "0" ]; then
    SEGVAL=0;
    showseg $SEGVAL
  fi

  # wait a bit before polling the switches again
  sleep 0.1

done
