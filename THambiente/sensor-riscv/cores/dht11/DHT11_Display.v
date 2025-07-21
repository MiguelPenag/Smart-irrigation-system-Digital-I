module DHT11_Display(
    input clk,                  // Reloj del sistema
    input reset,                // Reset activo en alto
    inout DHT11,                // Línea bidireccional del sensor
    output [6:0] seg,           // Segmentos A-G del display (cátodo común)
    output [1:0] anode,         // Control de los displays
    output [7:0] temperature    // Salida directa de temperatura al periférico
);

    // 🔄 CAMBIO: Señales internas
    wire [7:0] temp_internal;
    wire ready;                 // 🔄 CAMBIO: ahora usamos ready
    wire [3:0] decenas, unidades;

    // 🔄 CAMBIO: Instancia del sensor con ready
    DHT11_Read sensor (
        .clk(clk),
        .rst(reset),
        .DHT11(DHT11),
        .temperature(temp_internal),
        .ready(ready)           // 🔄 CAMBIO
    );

    // 🔄 CAMBIO: Mostrar 99 mientras no esté listo
    assign temperature = (ready) ? temp_internal : 8'd99;

    // Conversión binario a BCD
    DHT11_to_BCD bcd_converter (
        .temperature(temperature),
        .tens(decenas),
        .ones(unidades)
    );

    // Multiplexado y visualización
    Multiplexed_Display display_driver (
        .clk(clk),
        .tens(decenas),
        .ones(unidades),
        .seg(seg),
        .anode(anode)
    );

endmodule

