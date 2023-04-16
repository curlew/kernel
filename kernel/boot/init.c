#include <elf.h>
#include <multiboot2.h>
#include <serial.h>
#include <stdint.h>

// round `addr` up to the next multiple of `align` bytes
#define ALIGN_UP(addr, align) ((addr + (align - 1)) & ~(align - 1))

void init(struct multiboot_tag *multiboot_info) {
    serial_init();
    serial_puts("hello world");

    for (multiboot_tag_t *tag = multiboot_info + 1;
         tag->type != MULTIBOOT_TAG_TYPE_END;
         tag = (multiboot_tag_t *)((uintptr_t)tag + ALIGN_UP(tag->size, 8))) {
        if (tag->type == MULTIBOOT_TAG_TYPE_MODULE) {
            serial_puts("found multiboot tag, cmdline:");
            serial_puts(((multiboot_tag_module_t *)tag)->cmdline);

            uint8_t *kernel_image = (uint8_t *)(uintptr_t)((multiboot_tag_module_t *)tag)->mod_start;
            Elf64_Ehdr *kernel_elf_header = (Elf64_Ehdr *)kernel_image;
        }
    }
}
