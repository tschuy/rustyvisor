TARGET := x86_64-linux
RELEASE := debug
MODULENAME := rustyvisor
obj-m += $(MODULENAME).o
$(MODULENAME)-objs += loader/linux.o target/$(TARGET)/$(RELEASE)/lib$(MODULENAME).a
KDIR := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)
CARGO := cargo
XARGO := xargo
RUSTFILES := libs/*/src/*.rs src/*.rs
RUSTFLAGS='-C relocation-model=static'
CARFOFEATURES="runtime_tests"

all: $(MODULENAME).ko

$(MODULENAME).ko: loader/linux.c target/$(TARGET)/$(RELEASE)/lib$(MODULENAME).a
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules

target/$(TARGET)/$(RELEASE)/lib$(MODULENAME).a: $(RUSTFILES) Cargo.toml
	RUSTFLAGS=$(RUSTFLAGS) $(XARGO) build --target=$(TARGET) --verbose --features "$(CARFOFEATURES)"

test:
	cd libs/allocator && $(CARGO) test --verbose
	$(CARGO) test --verbose


clean:
	rm -f *.o *.ko *.ko.unsigned modules.order Module.symvers *.mod.c .*.cmd
	rm -rf .tmp_versions
	$(XARGO) clean

.PHONY: all clean test
