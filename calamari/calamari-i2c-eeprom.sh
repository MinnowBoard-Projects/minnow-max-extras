#!/bin/sh
I2CBUS=""

ACPI_BASE_PATH="/sys/devices/platform/80860F41:05"
ACPI_STATUS="$ACPI_BASE_PATH/firmware_node/status"
PCI_BASE_PATH="/sys/devices/pci0000:00/0000:00:18.6"

# Determine the i2c bus by device id (ACPI or PCI)
if [ -e $ACPI_STATUS ]; then
	STA=$(cat $ACPI_STATUS)
	if [ $STA -eq 15 ]; then
		I2CBUS=$(ls -d $ACPI_BASE_PATH/i2c-* | cut -d- -f2)
	fi
fi

# If no ACPI device, try PCI
if [ -z "$I2CBUS" ]; then
	if [ -d $PCI_BASE_PATH ]; then
		I2CBUS=$(ls -d $PCI_BASE_PATH/i2c-* | cut -d- -f2)
	else
		echo "ERROR: I2C5 bus not found"
		exit 1
	fi
fi

echo "Found I2C5 Bus: $I2CBUS"

i2cdetect -y -r $I2CBUS
echo
echo "VERIFY THIS IS THE CORRECT BUS:"
echo -n "Is 0x50 the only populated address [y/N]? "
read ANS

if [ ! "$ANS" = "y" -a ! "$ANS" = "Y" ]; then
	echo "FAIL"
	exit 1
fi

# This is a hack to get an extra 00 on the bus since some versions of i2cset
# complain if you add another 00 after the first.
i2cset -y $I2CBUS 0x50 0x00 0xde00 w
i2cset -y $I2CBUS 0x50 0x00 0x00 b
READ=$(i2cget -y $I2CBUS 0x50)
echo "Write: 0xde"
echo "Read: $READ"

if [ ! "$READ" = "0xde" ]; then
	echo "FAIL"
	exit 1
fi

echo "PASS"



