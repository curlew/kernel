ENTRY(_start)

SECTIONS {
    . = 0x100000;

    .multiboot ALIGN(4K) : {
        KEEP(*(.multiboot))
    }
    .text ALIGN(4K) : {
        _text = .;
        *(.text)
        *(.text*)
        _etext = .;
    }
    .data ALIGN(4K) : {
        _data = .;
        *(.data)
        *(.data*)
        _edata = .;
    }
    .rodata ALIGN(4K) : {
        _rodata = .;
        *(.rodata)
        *(.rodata*)
        _erodata = .;
    }
    .bss ALIGN(4K) : {
        _bss = .;
        *(COMMON)
        *(.bss)
        *(.stack)
        _ebss = .;
    }
}
