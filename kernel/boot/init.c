#include <serial.h>
#include <stdint.h>

void init(void) {
    serial_init();
    serial_puts("hello world");

    volatile uint16_t *const vga_buffer = (uint16_t *)0xB8000;
    *vga_buffer = (15 << 8) | 'X';
}
