#include <stdint.h>  // Necesario para uint32_t

int main() {
    volatile uint32_t* dht11_display = (uint32_t*) 0x00410000;

    // Leer la temperatura una vez
    uint32_t temperature = *dht11_display;

    // Repetir lectura periódicamente
    while (1) {
        temperature = *dht11_display;
        for (volatile int i = 0; i < 100000; i++);  // pequeño delay
    }

    return 0;
}

