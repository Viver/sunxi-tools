CC = gcc
CFLAGS = -g -O0 -Wall -Wextra
CFLAGS += -std=c99 -D_POSIX_C_SOURCE=200112L
CFLAGS += -Iinclude/

TOOLS = fexc bin2fex fex2bin bootinfo fel pio
TOOLS += nand-part

MISC_TOOLS = phoenix_info

.PHONY: all clean

all: $(TOOLS)

misc: $(MISC_TOOLS)

clean:
	@rm -vf $(TOOLS) $(MISC_TOOLS) *.o *.elf


$(TOOLS): Makefile common.h

fex2bin bin2fex: fexc
	ln -s $< $@

fexc: fexc.h script.h script.c \
	script_bin.h script_bin.c \
	script_fex.h script_fex.c

LIBUSB = libusb-1.0
LIBUSB_CFLAGS = `pkg-config --cflags $(LIBUSB)`
LIBUSB_LIBS = `pkg-config --libs $(LIBUSB)`

fel: fel.c
	$(CC) $(CFLAGS) $(LIBUSB_CFLAGS) $(LDFLAGS) -o $@ $(filter %.c,$^) $(LIBS) $(LIBUSB_LIBS)

%: %.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(filter %.c,$^) $(LIBS)

.dummy:	fel-pio.bin

fel-pio.bin: fel-pio.elf fel-pio.nm
	arm-none-eabi-objcopy -O binary fel-pio.elf fel-pio.bin

fel-pio.elf: fel-pio.c
	arm-none-eabi-gcc  -g  -Os   -fno-common -fno-builtin -ffreestanding -nostdinc -mno-thumb-interwork -Wall -Wstrict-prototypes -fno-stack-protector -Wno-format-nonliteral -Wno-format-security -fno-toplevel-reorder  fel-pio.c -nostdlib -o fel-pio.elf -T fel-pio.lds

fel-pio.nm: fel-pio.elf
	arm-none-eabi-nm fel-pio.elf | grep -v " _" >fel-pio.nm

bootinfo: bootinfo.c

.gitignore: Makefile
	@for x in $(TOOLS) '*.o' '*.swp'; do \
		echo "$$x"; \
	done > $@
