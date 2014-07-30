/*
 * MinnowBoard-Max Ika Lure board file
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
 * Author: California Sullivan <california.l.sullivan@intel.com>
 */

#define pr_fmt(fmt) "[ika] " fmt

#include <linux/module.h>
#include <linux/i2c.h>
#include <linux/i2c/ads1015.h>

#define IKA_ADS1015_ADDRESS 0x48
/* This is example code. Verify this bus is correct before loading module. */
#define IKA_ADS1015_BUS_NUMBER 11

static struct i2c_board_info ika_lure_board_info __initdata =
{
	I2C_BOARD_INFO("ads1015", IKA_ADS1015_ADDRESS),
};

static struct i2c_client *client = NULL;

static int __init ika_lure_init(void)
{
	struct i2c_adapter *adapter;

#ifndef CONFIG_SENSORS_ADS1015
#error CONFIG_SENSORS_ADS1015 must be defined.
#else
#ifdef MODULE
	if (request_module("ads1015")) {
		pr_err("ads1015 module is unavailable.\n");
		return -ENODEV;
	}
#endif /* MODULE */
#endif /* CONFIG_SENSORS_ADS1015 */

	adapter = i2c_get_adapter(IKA_ADS1015_BUS_NUMBER);
	if (!adapter) {
		pr_err("null adapter\n");
		return -ENODEV;
	}

	client = i2c_new_device(adapter, &ika_lure_board_info);
	if (!client) {
		pr_err("null client\n");
		return -ENODEV;
	}

	return 0;
}

static void __exit ika_lure_exit(void)
{
	if (!client) {
		pr_info("null client on unregister\n");
		return;
	}
	i2c_unregister_device(client);
}

module_init(ika_lure_init);
module_exit(ika_lure_exit);

MODULE_LICENSE("GPL");
