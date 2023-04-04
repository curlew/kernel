SRC_DIR := kernel
BUILD_DIR := build

CC := x86_64-elf-gcc
CFLAGS := -std=c17 -Og -g -ffreestanding \
		-Wall -Wextra -Wpedantic \
		-m64 -mno-red-zone -mno-mmx -mno-sse -mno-sse2
CPPFLAGS := -I$(SRC_DIR) -MMD -MP
LDFLAGS := -nostdlib
LDLIBS := -lgcc

SRCS := $(shell find $(SRC_DIR) -name "*.c" -or -name "*.S")
OBJS := $(SRCS:%=build/%.o)
DEPS := $(OBJS:.o=.d)

all: $(BUILD_DIR)/kernel.iso

qemu: $(BUILD_DIR)/kernel.iso
	qemu-system-x86_64 -serial stdio $^

clean:
	-rm -r $(BUILD_DIR)

.PHONY: all qemu clean

$(BUILD_DIR)/kernel.iso: $(BUILD_DIR)/kernel.bin $(SRC_DIR)/grub.cfg
	mkdir -p $(BUILD_DIR)/iso/boot/grub
	cp $(word 1, $^) $(BUILD_DIR)/iso/boot
	cp $(word 2, $^) $(BUILD_DIR)/iso/boot/grub
	grub-mkrescue -o $@ $(BUILD_DIR)/iso

$(BUILD_DIR)/kernel.bin: $(SRC_DIR)/boot/linker.ld $(OBJS)
	$(CC) $(LDFLAGS) -T $< $(filter-out $<, $^) $(LDLIBS) -o $@
	grub-file --is-x86-multiboot2 $@

$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(@D)
	$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $<
$(BUILD_DIR)/%.S.o: %.S
	mkdir -p $(@D)
	$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $<

-include $(DEPS)
