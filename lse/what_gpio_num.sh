#!/bin/bash

DEBUG=${DEBUG:="0"}
SINGLECOL=${SINGLECOL:="0"}

echo "***************************************************************"
echo "***  This program attempts to ascertain what the correct    ***"
echo "***  Linux GPIO numbers for the various GPIOs for the       ***"
echo "***  MinnowBoard MAX                                        ***"
echo "***                                                         ***"
echo "***  This is by no means perfect, double check it's output  ***"
echo "***************************************************************"


pin1="-"	# GND / Ground
pin2="-"	# GND / Ground
pin3="-"	# +5V Power / VCC
pin4="-"	# +3V3 / +3.3V Power
pin5="-"	# SPI Chip Select / GPIO_SPI_CS#
pin6="-"	# GPIO_UART1_TXD / UART Transmit
pin7="-"	# Master In / Slave Out (MISO) / GPIO_SPI_MISO
pin8="-"	# UART Receive / GPIO_UART1_RXD
pin9="-"	# Master Out / Slave In / GPIO_SPI_MOSI
pin10="-"	# CTS / GPIO / GPIO_UART1_CTS
pin11="-"	# SPI Clock / GPIO_SPI_CLK
pin12="-"	# RTS / GPIO / GPIO_UART1_RTS
pin13="-"	# Clock / GPIO / GPIO_I2C_SCL (I2C #5)
pin14="-"	# Clock / GPIO / GPIO_I2S_CLK
pin15="-"	# Data / GPIO / GPIO_I2C_SDA (I2C #5)
pin16="-"	# Frame / GPIO / GPIO_I2S_FRM
pin17="-"	# UART Transmit / GPIO / GPIO_UART2_TXD
pin18="-"	# Data Out / GPIO / GPIO_I2S_DO
pin19="-"	# UART Receive / GPIO / GPIO_UART2_RXD
pin20="-"	# Data In / GPIO / GPIO_I2S_DI
pin21="-"	# GPIO / Wakeup / GPIO_S5_0
pin22="-"	# PWM / GPIO / GPIO_PWM0
pin23="-"	# GPIO / Wakeup / GPIO_S5_1
pin24="-"	# PWM / GPIO / GPIO_PWM1
pin25="-"	# GPIO / Wakeup / GPIO_S5_4
pin26="-"	# Timer / GPIO / GPIO_IBL_8254

cat /sys/kernel/debug/gpio &> /dev/null

if [[ "$?" != "0" ]]
then
	echo ""
	echo "ERROR: /sys/kernel/debug/gpio is not readable, the output here will not be useful"
	exit
fi

range_start0="$(
		cat /sys/kernel/debug/gpio | \
		grep "^GPIOs" | \
		grep "INT33FC:00" | \
		awk '{ print $2; }' | \
		sed 's/,//' | sed 's/-[0-9]*//' \
		)"
range_start1="$(
		cat /sys/kernel/debug/gpio | \
		grep "^GPIOs" | \
		grep "INT33FC:01" | \
		awk '{ print $2; }' | \
		sed 's/,//' | \
		sed 's/-[0-9]*//' \
		)"
range_start2="$( \
		cat /sys/kernel/debug/gpio | \
		grep "^GPIOs" | \
		grep "INT33FC:02" | \
		awk '{ print $2; }' | \
		sed 's/,//' | \
		sed 's/-[0-9]*//' \
		)"

## Debugging output, set the shell variable "DEBUG" to not 0 to output
if [[ "${DEBUG}" != "0" ]]
then
	echo "~~~ ~~~"
	echo "~~~ Range 0 start: ${range_start0}"
	echo "~~~ Range 1 start: ${range_start1}"
	echo "~~~ Range 2 start: ${range_start2}"
	echo "~~~ ~~~"
fi

# pin 1 = GND / Ground
# pin 2 = GND / Ground
# pin 3 = +5V Power / VCC
# pin 4 = +3V3 / +3.3V Power
let "pin5 = range_start0 + 66"	# SPI Chip Select / GPIO_SPI_CS#
let "pin6 = range_start0 + 71"	# GPIO_UART1_TXD / UART Transmit
let "pin7 = range_start0 + 67"	# Master In / Slave Out (MISO) / GPIO_SPI_MISO
let "pin8 = range_start0 + 70"	# UART Receive / GPIO_UART1_RXD
let "pin9 = range_start0 + 68"	# Master Out / Slave In / GPIO_SPI_MOSI
let "pin10 = range_start0 + 73"	# CTS / GPIO / GPIO_UART1_CTS
let "pin11 = range_start0 + 69"	# SPI Clock / GPIO_SPI_CLK
let "pin12 = range_start0 + 72"	# RTS / GPIO / GPIO_UART1_RTS
let "pin13 = range_start0 + 89"	# Clock / GPIO / GPIO_I2C_SCL (I2C #5)
let "pin14 = range_start0 + 62"	# Clock / GPIO / GPIO_I2S_CLK
let "pin15 = range_start0 + 88"	# Data / GPIO / GPIO_I2C_SDA (I2C #5)
let "pin16 = range_start0 + 63"	# Frame / GPIO / GPIO_I2S_FRM
let "pin17 = range_start0 + 75"	# UART Transmit / GPIO / GPIO_UART2_TXD
let "pin18 = range_start0 + 65"	# Data Out / GPIO / GPIO_I2S_DO
let "pin19 = range_start0 + 74"	# UART Receive / GPIO / GPIO_UART2_RXD
let "pin20 = range_start0 + 64"	# Data In / GPIO / GPIO_I2S_DI
let "pin21 = range_start2 + 0"	# GPIO / Wakeup / GPIO_S5_0
let "pin22 = range_start0 + 94"	# PWM / GPIO / GPIO_PWM0
let "pin23 = range_start2 + 1"	# GPIO / Wakeup / GPIO_S5_1
let "pin24 = range_start0 + 95"	# PWM / GPIO / GPIO_PWM1
let "pin25 = range_start2 + 2"	# GPIO / Wakeup / GPIO_S5_4
let "pin26 = range_start0 + 54"	# Timer / GPIO / GPIO_IBL_8254

if [[ "${SINGLECOL}" != "0" ]]
then

echo   "Description                   | Name                  | Pin | Linux GPIO #"
echo   "------------------------------+-----------------------+-----+--------------"
printf " Ground                       | GND                   |   1 |    %3s\n" ${pin1}
printf " Ground                       | GND                   |   2 |    %3s\n" ${pin2}
printf " +5V Power                    | +5V                   |   3 |    %3s\n" ${pin3}
printf " +3.3V Power                  | +3V3                  |   4 |    %3s\n" ${pin4}
printf " SPI Chip Select              | GPIO_SPI_CS#          |   5 |    %3s\n" ${pin5}
printf " GPIO_UART1_TXD               | UART Transmit         |   6 |    %3s\n" ${pin6}
printf " Master In / Slave Out (MISO) | GPIO_SPI_MISO         |   7 |    %3s\n" ${pin7}
printf " GPIO_UART1_RXD               | UART Receive          |   8 |    %3s\n" ${pin8}
printf " Master Out / Slave In        | GPIO_SPI_MOSI         |   9 |    %3s\n" ${pin9}
printf " CTS / GPIO                   | GPIO_UART1_CTS        |  10 |    %3s\n" ${pin10}
printf " SPI Clock                    | GPIO_SPI_CLK          |  11 |    %3s\n" ${pin11}
printf " RTS / GPIO                   | GPIO_UART1_RTS        |  12 |    %3s\n" ${pin12}
printf " Clock / GPIO                 | GPIO_I2C_SCL (I2C #5) |  13 |    %3s\n" ${pin13}
printf " Clock / GPIO                 | GPIO_I2S_CLK          |  14 |    %3s\n" ${pin14}
printf " Data / GPIO                  | GPIO_I2C_SDA (I2C #5) |  15 |    %3s\n" ${pin15}
printf " Frame / GPIO                 | GPIO_I2S_FRM          |  16 |    %3s\n" ${pin16}
printf " UART Transmit                | GPIO / GPIO_UART2_TXD |  17 |    %3s\n" ${pin17}
printf " Data Out / GPIO              | GPIO_I2S_DO           |  18 |    %3s\n" ${pin18}
printf " UART Receive / GPIO i        | GPIO_UART2_RXD        |  19 |    %3s\n" ${pin19}
printf " Data In / GPIO               | GPIO_I2S_DI           |  20 |    %3s\n" ${pin20}
printf " GPIO / Wakeup                | GPIO_S5_0             |  21 |    %3s\n" ${pin21}
printf " PWM / GPIO                   | GPIO_PWM0             |  22 |    %3s\n" ${pin22}
printf " GPIO / Wakeup                | GPIO_S5_1             |  23 |    %3s\n" ${pin23}
printf " PWM / GPIO                   | GPIO_PWM1             |  24 |    %3s\n" ${pin24}
printf " GPIO / Wakeup                | GPIO_S5_4             |  25 |    %3s\n" ${pin25}
printf " Timer / GPIO                 | GPIO_IBL_8254         |  26 |    %3s\n" ${pin26}

else

echo   "Description                   | Name                  | Pin | Linux GPIO # || Linux GPIO # | Pin | Name           | Description"
echo   "------------------------------+-----------------------+-----+--------------++--------------+-----+----------------+------------"
printf " Ground                       | GND                   |   1 |    %3s       ||   %3s        |  2  | GND            |  Ground\n" ${pin1} ${pin2}
printf " +5V Power                    | +5V                   |   3 |    %3s       ||   %3s        |  4  | +3V3           |  +3.3V Power\n" ${pin3} ${pin4}
printf " SPI Chip Select              | GPIO_SPI_CS#          |   5 |    %3s       ||   %3s        |  6  | UART Transmit  |  GPIO_UART1_TXD\n" ${pin5} ${pin6}
printf " Master In / Slave Out (MISO) | GPIO_SPI_MISO         |   7 |    %3s       ||   %3s        |  8  | UART Receive   |  GPIO_UART1_RXD\n" ${pin7} ${pin8}
printf " Master Out / Slave In        | GPIO_SPI_MOSI         |   9 |    %3s       ||   %3s        | 10  | GPIO_UART1_CTS |  CTS / GPIO\n" ${pin9} ${pin10}
printf " SPI Clock                    | GPIO_SPI_CLK          |  11 |    %3s       ||   %3s        | 12  | GPIO_UART1_RTS |  RTS / GPIO\n" ${pin11} ${pin12}
printf " Clock / GPIO                 | GPIO_I2C_SCL (I2C #5) |  13 |    %3s       ||   %3s        | 14  | GPIO_I2S_CLK   |  Clock / GPIO\n" ${pin13} ${pin14}
printf " Data / GPIO                  | GPIO_I2C_SDA (I2C #5) |  15 |    %3s       ||   %3s        | 16  | GPIO_I2S_FRM   |  Frame / GPIO\n" ${pin15} ${pin16}
printf " UART Transmit                | GPIO / GPIO_UART2_TXD |  17 |    %3s       ||   %3s        | 18  | GPIO_I2S_DO    |  Data Out / GPIO\n" ${pin17} ${pin18}
printf " UART Receive / GPIO i        | GPIO_UART2_RXD        |  19 |    %3s       ||   %3s        | 20  | GPIO_I2S_DI    |  Data In / GPIO\n" ${pin19} ${pin20}
printf " GPIO / Wakeup                | GPIO_S5_0             |  21 |    %3s       ||   %3s        | 22  | GPIO_PWM0      |  PWM / GPIO\n" ${pin21} ${pin22}
printf " GPIO / Wakeup                | GPIO_S5_1             |  23 |    %3s       ||   %3s        | 24  | GPIO_PWM1      |  PWM / GPIO\n" ${pin23} ${pin24}
printf " GPIO / Wakeup                | GPIO_S5_4             |  25 |    %3s       ||   %3s        | 26  | GPIO_IBL_8254  |  Timer / GPIO\n" ${pin25} ${pin26}

fi
