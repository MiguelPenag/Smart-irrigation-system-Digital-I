/*
 * Módulo SOC (System on Chip) completo con la lógica de sensores integrada
 * directamente en este archivo.
 */
module SOC (
    input             clk,     // system clock
    input             resetn,  // reset button
    output wire [3:0] LEDS,    // 4 BITS: {Fallo, FalloArriba, FalloAbajo, TodoOk}
    input             RXD,     // UART receive
    output            TXD      // UART transmit
);
  //--- Señales del Bus del CPU ---
  wire [31:0] mem_addr;
  wire [31:0] mem_rdata;
  wire        mem_rstrb;
  wire [31:0] mem_wdata;
  wire [3:0]  mem_wmask;
  wire        wr = |mem_wmask;
  wire        rd = mem_rstrb;

  //--- Instancia del CPU FemtoRV32 ---
  FemtoRV32 CPU (
      .clk(clk),
      .reset(resetn),
      .mem_addr(mem_addr),
      .mem_rdata(mem_rdata),
      .mem_rstrb(mem_rstrb),
      .mem_wdata(mem_wdata),
      .mem_wmask(mem_wmask),
      .mem_rbusy(1'b0),
      .mem_wbusy(1'b0)
  );

  //--- Definición de Periféricos y Memoria ---
  wire [31:0] RAM_rdata;
  wire [31:0] uart_dout;
  wire [31:0] gpio_dout;
  wire [31:0] mult_dout;
  wire [31:0] div_dout;
  wire [31:0] bin2bcd_dout;
  wire [31:0] dpram_dout;
  wire [6:0]  cs;

  //--- Memoria RAM ---
  Memory RAM (
      .clk(clk),
      .mem_addr(mem_addr),
      .mem_rdata(RAM_rdata),
      .mem_rstrb(cs[0] & rd),
      .mem_wdata(mem_wdata),
      .mem_wmask({4{cs[0]}} & mem_wmask)
  );

  //--- Periférico UART ---
  peripheral_uart #(
      .clk_freq(25000000),
      .baud    (57600)
  ) per_uart (
      .clk(clk),
      .rst(!resetn),
      .d_in(mem_wdata),
      .cs(cs[5]),
      .addr(mem_addr[4:0]),
      .rd(rd),
      .wr(wr),
      .d_out(uart_dout),
      .uart_tx(TXD),
      .uart_rx(RXD)
  );

  //--- Periférico Multiplicador ---
  peripheral_mult mult1 (
      .clk(clk),
      .reset(!resetn),
      .d_in(mem_wdata[15:0]),
      .cs(cs[3]),
      .addr(mem_addr[4:0]),
      .rd(rd),
      .wr(wr),
      .d_out(mult_dout)
  );

  // =================================================================
  // ==                LÓGICA DE SENSORES INTEGRADA                 ==
  // =================================================================
  
  //--- 1. Periférico GPIO para conectar el Software con el Hardware ---
  wire [1:0] gpio_outputs;
  
wire gpio_ready;

peripheral_gpio per_gpio (
    .clk(clk),
    .rst(!resetn),
    .addr(mem_addr[4:0]),
    .cs(cs[4]),
    .rd(rd),
    .wr(wr),
    .d_in(mem_wdata),
    .d_out(gpio_dout),
    .mem_ready(gpio_ready),       // NUEVO
    .gpio_out(gpio_outputs)
);  

  //--- 2. Lógica de Sensores (directamente aquí) ---
  wire S1, S2;
  wire TodoOk, FalloAbajo, FalloArriba, Fallo;

  assign S1 = gpio_outputs[0];
  assign S2 = gpio_outputs[1];

  // La lógica del módulo Sensores se coloca aquí directamente
  assign TodoOk      = ~ (S1 | S2);
  assign Fallo       = (S1 ^ S2);
  assign FalloAbajo  = S2;
  assign FalloArriba = S1;
  
  //--- 3. Conexión final de la lógica a los LEDs físicos ---
  assign LEDS = {Fallo, FalloArriba, FalloAbajo, TodoOk};

  // =================================================================

  //--- Decodificador de Direcciones y MUX de Lectura ---
  address_decoder address_decoder (
      .mem_addr(mem_addr),
      .cs(cs)
  );

  chip_select chip_select (
      .cs(cs),
      .dpram_dout(dpram_dout),
      .uart_dout(uart_dout),
      .gpio_dout(gpio_dout),
      .mult_dout(mult_dout),
      .div_dout(div_dout),
      .bin2bcd_dout(bin2bcd_dout),
      .RAM_rdata(RAM_rdata),
      .mem_rdata(mem_rdata)
  );

`ifdef BENCH
  always @(posedge clk) begin
    if (cs[5] & wr) begin
      $write("%c", mem_wdata[7:0]);
      $fflush(32'h8000_0001);
    end
  end
`endif

endmodule
