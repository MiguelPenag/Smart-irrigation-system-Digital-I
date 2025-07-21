#include "./libs/time.h"
#include "./libs/uart.h"
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// --- CONFIGURACIÓN CORREGIDA ---
// La dirección ahora apunta al inicio del bloque 0x0041xxxx que define el address_decoder.
#define ADDR_GPIO   0x00410000
#define IO_BASE 0x400000

// Puntero al registro del periférico GPIO
volatile uint32_t *const gp_gpio = (uint32_t *)ADDR_GPIO;
volatile uint32_t *const gp = (uint32_t *)IO_BASE;

// Máscaras de bits para S1 y S2
#define S1_MASK (1 << 0)
#define S2_MASK (1 << 1)
// --- FIN DE CONFIGURACIÓN ---

char buffer[16] = "echo\n\r";
int ppm_value = 0;
uint32_t gpio_val;

int main() {
  wait(20);
  putstring(buffer);
  wait(20);
  while (1) {
    getstring(buffer, 4, '\r');
    wait(10);
    putstring(buffer);
    ppm_value = atoi(buffer);
    memset(buffer, 0, sizeof(buffer));

    //putstring("\r\n");
    wait(10);

    
    if (ppm_value > 800) {
        *gp_gpio = S1_MASK; // Enciende LED FalloArriba
        wait(50);
    }
    
    if (ppm_value < 300) {
        *gp_gpio = S2_MASK; // Enciende LED FalloAbajo
        wait(50);
    }
    if (ppm_value>300 && ppm_value<800) {
        *gp_gpio = 0;       // Apaga ambos (debería encenderse TodoOk)
        wait(50);
    }
    
  }
  
  return 0;
}
