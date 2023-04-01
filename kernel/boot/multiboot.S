#include <multiboot2.h>

.code32

/* https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html#Header-layout */
.section .multiboot, "a"
.align 8

multiboot_header:

.long MULTIBOOT2_HEADER_MAGIC
.long MULTIBOOT_ARCHITECTURE_I386
.long multiboot_header_end - multiboot_header
.long -(MULTIBOOT2_HEADER_MAGIC + MULTIBOOT_ARCHITECTURE_I386 + (multiboot_header_end - multiboot_header))

module_align_tag:
.short MULTIBOOT_HEADER_TAG_MODULE_ALIGN
.short MULTIBOOT_HEADER_TAG_OPTIONAL
.long module_align_tag_end - module_align_tag
module_align_tag_end:

.short MULTIBOOT_HEADER_TAG_END
.short 0
.long 8

multiboot_header_end:
