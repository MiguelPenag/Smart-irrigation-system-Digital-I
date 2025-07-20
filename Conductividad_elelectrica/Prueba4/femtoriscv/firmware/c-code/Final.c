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

int simple_atoi(const char *str) {
    int result = 0;
    while (*str >= '0' && *str <= '9') {
        result = result * 10 + (*str - '0');
        str++;
    }
    return result;
}


int main() {
    int ppm_value;
    uint32_t gpio_val;
  
    while (1) {
        memset(buffer, 0, sizeof(buffer));
        int len = getstring(buffer, 32, '\r');
        if (len > 0) {
            buffer[len] = '\0';
            if (buffer[len - 1] == '\r' || buffer[len - 1] == '\n') {
                buffer[len - 1] = '\0';
            }
            putstring(buffer);
            //wait(10);
            ppm_value = simple_atoi(buffer);

            if (ppm_value > 704) {
                *gp_gpio = S1_MASK; // Enciende LED FalloArriba
                wait(10);
            }
            
            if (ppm_value < 512) {
                *gp_gpio = S2_MASK; // Enciende LED FalloAbajo
                wait(10);
            }
            if (ppm_value>512 && ppm_value<704) {
                *gp_gpio = 0;       // Apaga ambos
                wait(10);
            }
            //ppm_value = custom_atoi(buffer);
            //*gp_gpio = S2_MASK;
        } else {
            putstring("[ERR] No recibido\r\n");
            *gp_gpio = 0;
        }
        wait(10);
        
    }
  
  return 0;
}
