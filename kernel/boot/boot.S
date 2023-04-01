.code32

.set STACK_SIZE, 0x4000 /* 16 KiB */

.section .stack, "aw", @nobits
.align 16
stack_bottom:
.skip STACK_SIZE
stack_top:

.section .text
.global _start
.type _start, @function
_start:
    /* https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html#I386-machine-state */
    cli
    movl $stack_top, %esp

    hlt
.size _start, . - _start
