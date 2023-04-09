.code32

.set STACK_SIZE, 0x4000 /* 16 KiB */

.set GDT_CS_INDEX, 1
.set GDT_DS_INDEX, 2
/* descriptor index is bits 3 through 15 */
.set GDT_CS_SELECTOR, (GDT_CS_INDEX << 3)
.set GDT_DS_SELECTOR, (GDT_DS_INDEX << 3)

.section .stack, "aw", @nobits
.align 16
stack_bottom:
.skip STACK_SIZE
stack_top:

/* paging structures */
/* see Intel 64 and IA-32 Architectures Software Developer's Manual,
 * vol. 3A, ch. 4.2 Hierarchical Paging Structures: an Overview */
.section .bss, "aw", @nobits
.align 4096
/* level 4 page map table - entries (PML4Es) reference PDPTs */
.comm pg_pml4t, 4096
/* page directory pointer table - entries (PDPTEs) reference page directories */
.comm pg_pdpt, 4096
/* page directory - entries (PDEs) reference page tables */
.comm pg_pd, 4096
/* page table - entries (PTEs) map 4 KiB pages */
.comm pg_pt, 4096

.section .data
.align 8
gdt:
.quad 0
.quad 0x00AF9A000000FFFF /* CS: present, read/execute, page granularity, 64-bit */
.quad 0x00CF92000000FFFF /* DS: present, read/write, page granularity, big */
gdt_end:

gdt_ptr:
.short gdt - gdt_end - 1 /* size */
.quad gdt /* base address */

.section .text
.global _start
.type _start, @function

.extern init
.type init, @function

_start:
    /* https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html#I386-machine-state */
    /* ebx contains the multiboot2 info struct's address */

    cli
    movl $stack_top, %esp

    /* clear level 4 page map table */
    movl $pg_pml4t, %edi
    movl $4096, %ecx
    xorb %al, %al
    rep stosb
    /* clear page directory pointer table */
    movl $pg_pdpt, %edi
    movl $4096, %ecx
    xorb %al, %al
    rep stosb
    /* clear page directory */
    movl $pg_pd, %edi
    movl $4096, %ecx
    xorb %al, %al
    rep stosb
    /* clear page table */
    movl $pg_pt, %edi
    movl $4096, %ecx
    xorb %al, %al
    rep stosb

    /* point pml4t[0] to pdpt */
    movl $pg_pml4t, %edi
    movl $pg_pdpt, (%edi)
    /* see Intel SDM, vol. 3A, ch. 4.5.4, table 4-15 */
    orl $0b11, (%edi) /* bit 0: present. bit 1: read/write */

    /* point pdpt[0] to page directory */
    movl $pg_pdpt, %edi
    movl $pg_pd, (%edi)
    orl $0b11, (%edi) /* bit 0: present. bit 1: read/write */

    /* point page directory[0] to page table */
    movl $pg_pd, %edi
    movl $pg_pt, (%edi)
    orl $0b11, (%edi) /* bit 0: present. bit 1: read/write */

    /* identity map the first 2 MiB */
    movl $pg_pt, %edi
    xorl %eax, %eax /* starting physical address (0) */
    movl $512, %ecx /* 512 iterations (page table entries) */
.set_pte:
    movl %eax, (%edi)
    orl $0b11, (%edi) /* bit 0: present. bit 1: read/write */
    addl $8, %edi /* next page table entry */
    addl $4096, %eax /* next physical address */
    loop .set_pte

    /* load pml4t to page directory base register */
    movl $pg_pml4t, %eax
    movl %eax, %cr3

    /* enable physical address extension */
    movl %cr4, %eax
    orl $0b100000, %eax /* bit 5: PAE */
    movl %eax, %cr4

    /* enter long mode */
    movl $0xC0000080, %ecx /* EFER model-specific register */
    rdmsr /* read into EDX:EAX (high order half:low order half) */
    orl $(1 << 8), %eax /* set LME (long mode enable) bit */
    wrmsr /* write to msr */

    /* enable paging */
    movl %cr0, %eax
    orl $(1 << 31), %eax /* PG bit */
    movl %eax, %cr0

    /* load 64-bit global descriptor table */
    mov $gdt_ptr, %eax
    lgdt (%eax)
    /* far jump into code segment to reload CS register */
    jmp $GDT_CS_SELECTOR, $1f

.code64
1:
    /* manually reload other segment registers */
    movw $GDT_DS_SELECTOR, %ax
    movw %ax, %ds
    movw %ax, %ss
    movw $0, %ax
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs

    movq %rbx, %rdi /* multiboot2 info struct */
    call init

halt:
    hlt
    jmp halt
.size _start, . - _start
