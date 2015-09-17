modname := low-speed-spidev
obj-m := low-speed-spidev.o

KVERSION := $(shell uname -r)
KDIR := /lib/modules/$(KVERSION)/build
PWD := "$$(pwd)"

default:
	$(info "Makefile: default")
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(info "Makefile clean")
	$(MAKE) O=$(PWD) -C $(KDIR) M=$(PWD) clean

load:
	$(info "Makefile load")
	-rmmod $(modname)
	insmod $(modname).ko

install:
	$(info "Makefile install")
	mkdir -p /lib/modules/$(KVERSION)/misc/$(modname)
	install -m 0755 -o root -g root $(modname).ko /lib/modules/$(KVERSION)/misc/$(modname)
	depmod -a

uninstall:
	$(info "Makefile uninstall")
	rm /lib/modules/$(KVERSION)/misc/$(modname)/$(modname).ko
	rmdir /lib/modules/$(KVERSION)/misc/$(modname)
	rmdir /lib/modules/$(KVERSION)/misc
	depmod -a

#clean:
#	rm -f *.o *~ core .depend .*.cmd *.ko *.mod.c
#	rm -f Module.markers Module.symvers modules.order
#	rm -rf .tmp_versions Modules.symvers

#all:
#	$(MAKE) -C $(KDIR) M=$(SRC)

#modules_install:
#	$(MAKE) -C $(KDIR) M=$(SRC) modules_install

