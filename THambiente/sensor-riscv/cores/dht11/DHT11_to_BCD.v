module DHT11_to_BCD(
    input [7:0] temperature,
    output reg [3:0] tens,
    output reg [3:0] ones
);

    always @(*) begin
        tens  = temperature / 10;
        ones  = temperature % 10;
    end

endmodule
