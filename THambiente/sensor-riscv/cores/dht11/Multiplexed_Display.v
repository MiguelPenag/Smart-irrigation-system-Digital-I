module Multiplexed_Display (
    input clk,                  // Reloj de entrada
    input [3:0] tens,           // Dígito de las decenas (0-9)
    input [3:0] ones,           // Dígito de las unidades (0-9)
    output reg [6:0] seg,       // Salidas a segmentos del display
    output reg [1:0] anode      // Control de ánodos (cátodo común: 0 activa)
);

    reg [15:0] refresh_counter = 0;   // Contador para la multiplexación
    reg select_digit = 0;             // 0 = display derecho (unidades), 1 = izquierdo (decenas)

    // Generación del pulso de refresco (~1 kHz si clk = 25 MHz)
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
        if (refresh_counter == 0)
            select_digit <= ~select_digit;
    end

    wire [3:0] current_digit = (select_digit) ? ones : tens;

    always @(*) begin
        // Selección de display: 0 enciende (cátodo común)
        case (select_digit)
            1'b0: anode = 2'b10;  // Display derecho (unidades) activo
            1'b1: anode = 2'b01;  // Display izquierdo (decenas) activo
        endcase

        // Conversión de BCD a 7 segmentos (cátodo común: 0 enciende)
        case (current_digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111; // Apagado
        endcase
    end

endmodule

