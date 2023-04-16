#ifndef ELF_H
#define ELF_H

#include <stdint.h>

// https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.eheader.html
// https://en.wikipedia.org/wiki/Executable_and_Linkable_Format#File_header

#define EI_NIDENT 16 // size of e_ident

typedef struct elf64_hdr {
    unsigned char e_ident[EI_NIDENT]; // magic number & identity
    uint16_t e_type;
    uint16_t e_machine;
    uint32_t e_version;
    uint64_t e_entry; // entry point virtual address
    uint64_t e_phoff; // program header table offset
    uint64_t e_shoff; // section header table offset
    uint32_t e_flags;
    uint16_t e_ehsize;    // ELF header size
    uint16_t e_phentsize; // program header table entry size
    uint16_t e_phnum;     // number of entries in program header table
    uint16_t e_shentsize; // section header table entry size
    uint16_t e_shnum;     // number of entries in section header table
    uint16_t e_shstrndx;  // index of section names entry in section header table
} Elf64_Ehdr;

#endif // ifndef ELF_H
