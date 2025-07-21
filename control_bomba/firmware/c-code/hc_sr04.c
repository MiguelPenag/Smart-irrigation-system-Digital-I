#include "libs/time.h"
#include "libs/uart.h"
#include <stdint.h>
#include "libs/utilities.h"

// Definición de direcciones de memoria (equivalentes a las constantes en ASM)
#define IO_BASE 0x400000
#define PERIP_HC_SR04 0x410000
#define GETDISTANCE 0x01

// Punteros a los registros de hardware
volatile uint32_t *const gp = (uint32_t *)IO_BASE;
volatile uint32_t *const getdistance = (uint32_t *)(PERIP_HC_SR04+GETDISTANCE);
const char hello[]="Leyendo distancias";
int main(){
  char buf []="";
  uint32_t dis = 0;
  putstring(hello);
  while(1){
    dis = *getdistance;
    itoa_simple_signed(dis , buf);
    putstring(buf);
    wait(5);
    }
  }

