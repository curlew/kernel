#include <serial.h>

#include <io.h>
#include <stdint.h>

static const uint16_t com1_port = 0x3F8;

void serial_init(void) {
    outb(com1_port + 1, 0x00);
    outb(com1_port + 3, 0x80);
    outb(com1_port + 0, 0x03);
    outb(com1_port + 1, 0x00);
    outb(com1_port + 3, 0x03);
    outb(com1_port + 2, 0xC7);
    outb(com1_port + 4, 0x0B);
}

void serial_putchar(char c) {
    outb(com1_port, c);
}

void serial_puts(const char *s) {
    while (*s) {
        serial_putchar(*s++);
    }
    serial_putchar('\n');
}
