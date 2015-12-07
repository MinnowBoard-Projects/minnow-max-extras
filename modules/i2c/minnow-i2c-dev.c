/*
 * Copyright (c) 2015, The Linux Foundation. All rights reserved.
 * Copyright (c) 2015, Alex Deddo <adeddo27@gmail.com>
 *
 * This software is licensed under the terms of the GNU General Public
 * License version 2, as published by the Free Software Foundation, and
 * may be copied, distributed, and modified under those terms.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#define pr_fmt(fmt) "%s: " fmt, __func__

#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/i2c.h>

/* Configure device name, i2c addr, and optional irq here */
#define DEV_NAME "i2c-dev"
#define DEV_ADDR 0
#define GPIO_IRQ 0

static struct i2c_adapter *adap;
static struct i2c_board_info board_info[] __initdata = {
	{
		I2C_BOARD_INFO(DEV_NAME, DEV_ADDR),
		.irq = GPIO_IRQ,
	},
};
static struct i2c_client *client;

static int __init minnow_module_init(void)
{
	adap = i2c_get_adapter(0);

	client = i2c_new_device(adap, board_info);

	pr_info("initialized\n");

	return 0;
}

static void __exit minnow_module_exit(void)
{
	i2c_unregister_device(client);
	i2c_put_adapter(adap);

	pr_info("exited\n");
}

module_init(minnow_module_init);
module_exit(minnow_module_exit);

MODULE_AUTHOR("Alex Deddo");
MODULE_DESCRIPTION("MinnowMax I2C device initializer");
MODULE_LICENSE("GPL");
