module peripheral_dht11_display (
    input clk,
    input reset,
    input [31:0] d_in,
    input cs,
    input [31:0] addr,
    input rd,
    input wr,
    output reg [31:0] d_out,

    inout DHT11,
    output [6:0] seg,
    output [1:0] anode
);

    // Señal interna para temperatura (8 bits)
    wire [7:0] temperature;

    // Instancia del módulo principal con lectura y display
    DHT11_Display display_unit (
        .clk(clk),
        .reset(reset),
        .DHT11(DHT11),
        .seg(seg),
        .anode(anode),
        .temperature(temperature)
    );

    // Lógica de lectura por el bus
    always @(posedge clk) begin
        if (reset)
            d_out <= 32'b0;
        else if (cs && rd) begin
            case (addr)
                32'h00000000: d_out <= {24'b0, temperature}; // Temperatura en bits bajos
                default:      d_out <= 32'b0;                // Otras direcciones devuelven cero
            endcase
        end
    end

endmodule

