# Primera versión del módulo

En esta primera versión del sistema, se establece una comunicación UART entre el ESP32 y la FPGA. El ESP32 configura dos puertos UART: uno para comunicarse con la PC vía USB y otro dedicado a la FPGA. Cada 20 milisegundos, el ESP32 envía el valor fijo "700\\r" a la FPGA y, si recibe alguna respuesta, la reenvía al puerto USB para monitoreo. Por su parte, la FPGA está programada para recibir caracteres por UART y responder con un eco, reenviando los mismos caracteres que recibe, además de enviar un mensaje inicial "echo\\n\\r". Esta versión busca validar el enlace UART y la correcta transmisión de datos entre ambos dispositivos, quedando lista para futuras versiones donde se envíen datos reales de sensores.

