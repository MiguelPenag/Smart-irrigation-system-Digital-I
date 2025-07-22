# Cuarta versión del módulo

En esta iteración del proyecto se añade funcionalidad de salida visual a través de LEDs conectados a la FPGA. Esta versión introduce un módulo GPIO básico que permite encender o apagar LEDs según datos recibidos o eventos detectados dentro del sistema.

La lógica implementada actúa de la siguiente manera:
- A partir de los datos procesados, se toma una decisión de control.
- Esta decisión se traduce en una señal lógica de activación que es enviada a los pines de salida que van a los LEDs.
- Así, el comportamiento del sistema se puede observar directamente mediante encendidos/apagados de los LEDs, lo que facilita el diagnóstico visual y la depuración del sistema.

## Requisitos
- FPGA
- LEDs conectados a pines GPIO de la FPGA
- Fuente de alimentación adecuada para los LEDs
- Comunicación con ESP32 para control remoto

## Archivos importantes
- `peripheral_gpio.v`: módulo de control de puertos GPIO para gestionar los LEDs.
- `SOC.v`, `SOC_tb.v`, `top_tb.v`: módulos de arquitectura principal y pruebas.
- `firmware.hex`: programa embebido que genera eventos de control.
- `Makefile`: automatización del proceso de compilación y simulación.


