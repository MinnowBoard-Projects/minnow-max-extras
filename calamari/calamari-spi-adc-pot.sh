#!/bin/sh

lsmod | grep -q calamari
calamari_found=$?

SYSFS="/sys/class/spi_master/spi0/spi0.0/iio:device0/in_voltage0-voltage1_raw"

if [[ "${calamari_found}" -ne "0" ]]
then
	echo "Calamari kernel module (board file) not loaded - this won't work"
	exit 1
fi

if [[
	! -e ${SYSFS}
]]
then
	echo "The SPI entry expected was not found - Something 'Wonky' - EXITING"
	exit 1
fi

initial_val="$( cat ${SYSFS} )"
echo "Initial value: ${initial_val}"
echo "Path: ${SYSFS}"

sleep 5

watch -n 1 cat ${SYSFS}
