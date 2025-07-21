# Segunda versión del módulo

En la segunda versión del sistema, se integra el sensor de conductividad al circuito de comunicación. El ESP32 sigue gestionando dos UART: una con la PC y otra con la FPGA. Ahora, además, lee el valor analógico del sensor a través del pin GPIO36, lo convierte a digital y lo escala a un valor máximo de 1000. Este dato es enviado cada 20 milisegundos a la FPGA. Si la FPGA responde, el ESP32 retransmite la respuesta al puerto USB. Por su parte, la FPGA espera a recibir un valor completo (4 caracteres), lo almacena en un buffer y luego lo envía de regreso como eco. Esta versión prueba la comunicación de un dato real —el valor del sensor— desde el entorno físico, pasando por el ESP32 y llegando a la FPGA.

