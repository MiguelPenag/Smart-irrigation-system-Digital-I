module peripheral_gpio (
    input             clk,
    input             rst,
    
    input      [4:0]  addr,
    input             cs,
    input             rd,
    input             wr,
    input      [31:0] d_in,
    output reg [31:0] d_out,
    output            mem_ready,     // <--- SEÑAL CLAVE

    output reg [1:0]  gpio_out
);

    assign mem_ready = 1'b1; // ← SIEMPRE responde inmediatamente

    always @(*) begin
        d_out = {30'b0, gpio_out};
    end

    always @(posedge clk) begin
        if (rst) begin
            gpio_out <= 2'b0;
        end else if (cs & wr & (addr == 5'h00)) begin
            gpio_out <= d_in[1:0]; 
        end
    end

endmodule

