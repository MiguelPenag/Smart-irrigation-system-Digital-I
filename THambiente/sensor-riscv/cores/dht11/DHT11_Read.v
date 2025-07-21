//==========================
// DHT11_Read.v Mejorado con detección de flanco de subida
//==========================
module DHT11_Read(
    input clk,
    input rst,
    inout DHT11,
    output reg [7:0] temperature,
    output reg ready
);

    // Parámetros para temporización
    localparam CLK_FREQ = 25_000_000;
    localparam ONE_US_TICKS = CLK_FREQ / 1_000_000; // ciclos por 1 us
    localparam THRESHOLD_US = 50; // umbral de 50 us para diferenciar 0 y 1

    // Línea bidireccional
    reg dht_out_en;
    reg dht_out;
    assign DHT11 = dht_out_en ? dht_out : 1'bz;
    wire dht_in = DHT11;

    // Estados de la FSM
    reg [3:0] state;
    localparam IDLE         = 4'd0,
               WAIT_POWER   = 4'd1,
               START_LOW    = 4'd2,
               START_HIGH   = 4'd3,
               WAIT_RESP_LO = 4'd4,
               WAIT_RESP_HI = 4'd5,
               READ_LOW     = 4'd6,
               READ_HIGH    = 4'd7,
               CHECK_DONE   = 4'd8,
               DONE         = 4'd9;

    reg [25:0] timer;
    reg [5:0] bit_index;
    reg [39:0] shift_reg;
    reg [15:0] high_counter;
    reg [15:0] tick_counter;
    reg last_state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            dht_out_en <= 0;
            dht_out <= 1;
            timer <= 0;
            bit_index <= 0;
            shift_reg <= 0;
            temperature <= 0;
            ready <= 0;
            high_counter <= 0;
            tick_counter <= 0;
            last_state <= 1;
        end else begin
            last_state <= dht_in;
            case (state)
                IDLE: begin
                    ready <= 0;
                    timer <= 0;
                    state <= WAIT_POWER;
                end
                WAIT_POWER: begin
                    if (timer < 25_000_000)
                        timer <= timer + 1;
                    else begin
                        timer <= 0;
                        dht_out_en <= 1;
                        dht_out <= 0;
                        state <= START_LOW;
                    end
                end
                START_LOW: begin
                    if (timer < 500_000)
                        timer <= timer + 1;
                    else begin
                        timer <= 0;
                        dht_out <= 1;
                        state <= START_HIGH;
                    end
                end
                START_HIGH: begin
                    if (timer < 40_000)
                        timer <= timer + 1;
                    else begin
                        timer <= 0;
                        dht_out_en <= 0;
                        state <= WAIT_RESP_LO;
                    end
                end
                WAIT_RESP_LO: begin
                    if (!dht_in) begin
                        timer <= 0;
                        state <= WAIT_RESP_HI;
                    end
                end
                WAIT_RESP_HI: begin
                    if (dht_in) begin
                        timer <= 0;
                        bit_index <= 0;
                        shift_reg <= 0;
                        state <= READ_LOW;
                    end
                end
                READ_LOW: begin
                    if (!dht_in)
                        timer <= 0;
                    else if (!last_state && dht_in) begin // flanco de subida
                        timer <= 0;
                        state <= READ_HIGH;
                    end
                end
                READ_HIGH: begin
                    if (dht_in) begin
                        if (tick_counter < ONE_US_TICKS - 1) begin
                            tick_counter <= tick_counter + 1;
                        end else begin
                            tick_counter <= 0;
                            high_counter <= high_counter + 1;
                        end
                    end else begin
                        shift_reg <= {shift_reg[38:0], (high_counter > THRESHOLD_US)};
                        bit_index <= bit_index + 1;
                        high_counter <= 0;
                        tick_counter <= 0;
                        if (bit_index == 39)
                            state <= CHECK_DONE;
                        else
                            state <= READ_LOW;
                    end
                end
                CHECK_DONE: begin
                    temperature <= shift_reg[31:24];
                    ready <= 1;
                    state <= DONE;
                end
                DONE: begin
                    // Espera nuevo reset externo
                end
            endcase
        end
    end
endmodule

