#include "./libs/time.h"
#include "./libs/uart.h"
#include <stdint.h>

#define NULL (void *)0

#define IO_BASE 0x400000
#define IO_LEDS 4

volatile uint32_t *const gp = (uint32_t *)IO_BASE;

char buffer[32] = "";

int main() {
  wait(20);
  putstring(buffer);
  wait(20);
  while (1) {
    getstring(buffer, 32, '\r');
    wait(10);
    putstring(buffer);
    //putstring("\r\n");
    wait(10);
  }
  return 0;
}
