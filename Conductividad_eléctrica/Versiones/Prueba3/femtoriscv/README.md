# Tercera versión del módulo

Esta versión implementa la comunicación completa entre tres componentes clave del sistema embebido: el sensor de conductividad eléctrica, el microcontrolador ESP32 y la FPGA. 

El flujo de datos es el siguiente:
1. El sensor mide la conductividad del agua.
2. El ESP32 toma esta señal analógica, la convierte a digital mediante su ADC y la empaqueta.
3. Esta información digital es enviada a la FPGA, que la procesa.
4. Luego, la FPGA retorna el dato procesado al ESP32.
5. Finalmente, el ESP32 transmite este dato por medio del módulo Bluetooth HC-06, lo que permite visualizarlo en una terminal remota .

Este sistema permite verificar no solo la correcta adquisición de la señal, sino también la comunicación bidireccional y el procesamiento intermedio en la FPGA.

## Requisitos
- FPGA 
- Módulo ESP32
- Sensor analógico de conductividad eléctrica 
- Módulo Bluetooth HC-06

## Archivos importantes
- `SOC.v`, `SOC_tb.v`, `top_tb.v`: arquitectura del sistema y banco de pruebas.
- `firmware.hex`: firmware para la memoria del sistema.
- `address_decoder.v`, `chip_select.v`: módulos encargados de direccionar y seleccionar dispositivos conectados.
- `init_dpram.ini`: configuración inicial de memoria dual-port RAM.


