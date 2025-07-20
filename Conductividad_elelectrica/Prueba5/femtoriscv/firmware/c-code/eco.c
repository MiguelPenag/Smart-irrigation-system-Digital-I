#include "./libs/time.h"
#include "./libs/uart.h"
#include <stdint.h>
#include <string.h>

// No necesitamos la lógica de GPIO para esta prueba
// #define ADDR_GPIO ...
char buffer[16] = "echo\n\r";

int main() {

    while (1) {
        // 1. Limpiar el buffer
        memset(buffer, 0, sizeof(buffer));

        // 2. Esperar y recibir datos del ESP32
        getstring(buffer, 15, '\r');
        
        // 3. Enviar de vuelta exactamente lo que recibimos, con un prefijo.
        putstring("ECHO: [");
        putstring(buffer);
        putstring("]\r\n");

        wait(50);
    }
  
  return 0;
}
