#include "./libs/time.h"
#include "./libs/uart.h"
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define ADDR_GPIO   0x00410000 
volatile uint32_t *const gp_gpio = (uint32_t *)ADDR_GPIO;

#define S1_MASK (1 << 0)
#define S2_MASK (1 << 1)

char buffer[32] = "";

int main() {
    int ppm_value;
    uint32_t gpio_val;
  
    while (1) {
        memset(buffer, 0, sizeof(buffer));
        int len = getstring(buffer, 32, '\r');
        if (len > 0) {
            buffer[len] = '\0';
            // Eliminamos posibles terminadores residuales
            if (buffer[len - 1] == '\r' || buffer[len - 1] == '\n') {
                buffer[len - 1] = '\0';
            }
            //putstring("[RX] ");
            putstring(buffer);
            //ppm_value = atoi(buffer);
            //putstring("\r\n");
            /*if (ppm_value > 800) {
                *gp_gpio = S1_MASK; // Activa LED de fallo alto
            } 
            else if (ppm_value < 300) {
                *gp_gpio = S2_MASK; // Activa LED de fallo bajo
            } 
            else { // El valor está en el rango [300, 800]
                *gp_gpio = 0;       // Apaga LEDs de fallo
            }*/
            //*gp_gpio = S1_MASK;
        } else {
            putstring("[ERR] No recibido\r\n");
            *gp_gpio = 0;
        }
        wait(10);
        
    }
  
  return 0;
}
