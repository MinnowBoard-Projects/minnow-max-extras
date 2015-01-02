/*
 * SPI testing utility (using spidev driver) for Calamari MCP3004 part
 *
 * Based on https://www.kernel.org/doc/Documentation/spi/spidev_test.c
 *
 * Modified by: California Sullivan <california.l.sullivan@intel.com>
 *
 * Copyright (c) 2007  MontaVista Software, Inc.
 * Copyright (c) 2007  Anton Vorontsov <avorontsov@ru.mvista.com>
 * Copyright (c) 2014, Intel Corporation.
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License.
 */

#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>

#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))

#define MCP300X_DATA_BITS_MASK 0x0003ff

#define MCP300X_START 0x01
#define MCP300X_SINGLE_ENDED 0x80
#define MCP300X_DIFFERENTIAL 0x00

#define NULL_BYTE 0x00

static uint8_t MCP300X_PIN[] ={ 0x00, 0x10, 0x20, 0x30 };

static void pabort(const char *s)
{
	perror(s);
	abort();
}

static const char *device = "/dev/spidev0.0";
static int pin = 0;
static void transfer(int fd)
{
	int ret;
	int tx_value;
	int total_value;

	total_value = 0;

	/* http://ww1.microchip.com/downloads/en/DeviceDoc/21295C.pdf p. 21 */
	uint8_t tx[] = {MCP300X_START,
			MCP300X_SINGLE_ENDED | MCP300X_PIN[pin],
			NULL_BYTE};

	uint8_t rx[ARRAY_SIZE(tx)] = {0, };
	struct spi_ioc_transfer tr = {
		.tx_buf = (unsigned long)tx,
		.rx_buf = (unsigned long)rx,
		.len = ARRAY_SIZE(tx),
	};

	ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
	if (ret < 1)
		pabort("Unable to send spi message");

	for (ret = 0; ret < ARRAY_SIZE(tx); ret++) {
		tx_value = rx[ret];
		tx_value = tx_value << 8 * (ARRAY_SIZE(tx) - ret - 1);
		total_value += tx_value;
	}

	total_value = total_value & MCP300X_DATA_BITS_MASK;
	printf("Pin %d value: %d\n", pin, total_value);
	printf("Highest possible value: %d\n", MCP300X_DATA_BITS_MASK);
}

static void print_usage(const char *prog)
{
	printf("Reads a pin on the MCP3004 part using spidev and ioctl.\n");
	printf("Usage: %s [OPTION OPTION_ARG]\n", prog);
	puts("  -d --device   device to use (default /dev/spidev0.0)\n"
	     "  -p --pin      pin to read (default pin 0, 0-3 valid)\n");
	exit(1);
}

static void parse_opts(int argc, char *argv[])
{
	while (1) {
		static const struct option lopts[] = {
			{ "device",  1, 0, 'd' },
			{ "pin", 1, 0, 'p' },
			{ NULL, 0, 0, 0 },
		};
		int c;

		c = getopt_long(argc, argv, "d:p:", lopts, NULL);

		if (c == -1)
			break;

		switch (c) {
		case 'd':
			device = optarg;
			break;
		case 'p':
			pin = atoi(optarg);
			if (pin > 3 || pin < 0) {
				printf("Valid pin range is 0-3. "
				       "Defaulting to 0.\n");
				pin = 0;
			}
			break;
		default:
			print_usage(argv[0]);
			break;
		}
	}
}

int main(int argc, char *argv[])
{
	int ret = 0;
	int fd;

	parse_opts(argc, argv);

	fd = open(device, O_RDWR);
	if (fd < 0)
		pabort("Unable to open device");

	transfer(fd);

	close(fd);

	return ret;
}
