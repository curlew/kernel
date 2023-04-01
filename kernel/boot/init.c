#include <stdint.h>

void init(void) {
    volatile uint16_t *const vga_buffer = (uint16_t *)0xB8000;
    *vga_buffer = (15 << 8) | 'X';
}
