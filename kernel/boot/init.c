#include <multiboot2.h>
#include <serial.h>
#include <stdint.h>

void init(struct multiboot_tag *multiboot_info) {
    serial_init();
    serial_puts("hello world");

    for (multiboot_tag_t *tag = (multiboot_tag_t *)((uintptr_t)multiboot_info + 8); // skip fixed first tag
         tag->type != MULTIBOOT_TAG_TYPE_END;
         // align up to next 8-byte boundary
         tag = (multiboot_tag_t *)((uintptr_t)tag + ((tag->size + 8-1) & ~(8-1)))) {
        serial_puts("tag");
        switch (tag->type) {
        case MULTIBOOT_TAG_TYPE_MODULE:
            serial_puts("found module tag. cmdline:");
            serial_puts(((multiboot_tag_module_t *)tag)->cmdline);
            break;
        }
    }
}
