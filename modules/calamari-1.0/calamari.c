/*
 * MinnowBoard-Max Calamari Lure board file
 * Copyright (c) 2014, Intel Corporation.
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License,
 * version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Author: Darren Hart <dvhart@linux.intel.com>
 */

#define pr_fmt(fmt) "Calamari: " fmt

#include <linux/platform_device.h>
#include <linux/module.h>
#include <linux/spi/spi.h>

/* #define CALAMARI_SPI_MASTER 32766 */
#define CALAMARI_SPI_MASTER 0

#define CALAMARI_SPI_CS 0
#define MCP320X_MAX_CLK_HZ 1000000

static struct spi_board_info cal_spi_board_info __initdata = {
	.modalias	= "mcp3204",
	.max_speed_hz	= MCP320X_MAX_CLK_HZ,
	.bus_num	= CALAMARI_SPI_MASTER,
	.chip_select	= CALAMARI_SPI_CS,
};

static struct spi_device *dev;

static int __init minnow_module_init(void)
{
	struct spi_master *master;
	int err;

	pr_info("module init\n");

	err = -ENODEV;
	master = spi_busnum_to_master(CALAMARI_SPI_MASTER);
	pr_info("master=%p\n", master);
	if (!master)
		goto out;

	dev = spi_new_device(master, &cal_spi_board_info);
	pr_info("dev=%p\n", dev);
	if (!dev)
		goto out;
	pr_info("mcp320x registered\n");
	err = 0;

 out:
	if (err)
		pr_err("Failed to register SPI device\n");
	return err;
}

static void __exit minnow_module_exit(void)
{
	pr_info("module exit");
	if (dev)
		spi_unregister_device(dev);
}

module_init(minnow_module_init);
module_exit(minnow_module_exit);

MODULE_LICENSE("GPL");
