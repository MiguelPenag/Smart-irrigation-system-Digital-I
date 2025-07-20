// filename: peripheral_gpio_tb.v
// brief: Testbench para el módulo peripheral_gpio.
// Genera un reloj, aplica un reset y simula escrituras en el periférico
// para verificar su comportamiento.

// Escala de tiempo: 1 nanosegundo de unidad con 1 nanosegundo de precisión.
`timescale 1ns / 1ns

module peripheral_gpio_tb;

    // Parámetros del Testbench
    localparam CLK_PERIOD = 20; // Periodo del reloj de 20 ns (Frecuencia 50 MHz)

    // Declaración de señales para conectar al DUT (Device Under Test)
    // 'reg' para las entradas del DUT, ya que las controlamos desde el testbench.
    reg           clk;
    reg           rst;
    reg   [4:0]   addr;
    reg           cs;
    reg           rd;
    reg           wr;
    reg   [31:0]  d_in;

    // 'wire' para las salidas del DUT, ya que solo las leemos/monitoreamos.
    wire  [31:0]  d_out;
    wire          mem_ready;
    wire  [1:0]   gpio_out;


    // Instanciación del Módulo Bajo Prueba (Device Under Test - DUT)
    // Conecta las señales del testbench a los puertos del módulo peripheral_gpio.
    peripheral_gpio dut (
        .clk        (clk),
        .rst        (rst),
        .addr       (addr),
        .cs         (cs),
        .rd         (rd),
        .wr         (wr),
        .d_in       (d_in),
        .d_out      (d_out),
        .mem_ready  (mem_ready),
        .gpio_out   (gpio_out)
    );

    // Generador de Reloj
    // Crea una señal de reloj que alterna cada medio período.
    initial begin
        clk = 0;
        // La sentencia 'forever' asegura que el reloj se genere continuamente.
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Secuencia de Estímulos y Verificación
    // Este bloque 'initial' define la secuencia de operaciones para probar el DUT.
    initial begin
        // 1. Fase de Inicialización y Reset
        $display("T=%0t: --- Inicio de la Simulación ---", $time);
        rst = 1;      // Activar reset
        cs = 0;
        rd = 0;
        wr = 0;
        addr = 5'h0;
        d_in = 32'h0;

        // Mantener el reset activo por 2 ciclos de reloj para asegurar la estabilización.
        #(CLK_PERIOD * 2);
        rst = 0;      // Desactivar reset
        $display("T=%0t: Reset liberado. El DUT está operativo.", $time);
        
        // Esperar un ciclo de reloj antes de la primera operación.
        @(posedge clk);

        // 2. Primera Operación de Escritura (Escribir '01')
        $display("T=%0t: Realizando escritura: d_in = 2'b01 en addr = 0x00", $time);
        addr <= 5'h00;
        d_in <= 32'd1; // d_in[1:0] será 2'b01
        cs   <= 1;
        wr   <= 1;

        // La escritura ocurre en el flanco de subida del reloj.
        @(posedge clk);
        // Desactivar las señales de control después de la escritura.
        cs   <= 0;
        wr   <= 0;
        d_in <= 32'h0;

        // Dar un pequeño retardo para que las señales se propaguen antes de verificar.
        #1;
        $display("T=%0t: Verificando... gpio_out = %b, d_out = %h", $time, gpio_out, d_out);
        
        // 3. Segunda Operación de Escritura (Escribir '10')
        @(posedge clk);
        $display("T=%0t: Realizando escritura: d_in = 2'b10 en addr = 0x00", $time);
        d_in <= 32'd2; // d_in[1:0] será 2'b10
        cs   <= 1;
        wr   <= 1;

        @(posedge clk);
        cs   <= 0;
        wr   <= 0;
        d_in <= 32'h0;
        
        #1;
        $display("T=%0t: Verificando... gpio_out = %b, d_out = %h", $time, gpio_out, d_out);

        // 4. Intento de Escritura en Dirección Incorrecta
        @(posedge clk);
        $display("T=%0t: Intentando escribir en dirección incorrecta (addr = 0x1F)", $time);
        addr <= 5'h1F;
        d_in <= 32'd3; // Intentar escribir 2'b11
        cs   <= 1;
        wr   <= 1;
        
        @(posedge clk);
        cs   <= 0;
        wr   <= 0;
        d_in <= 32'h0;
        addr <= 5'h0; // Restaurar dirección para futuras pruebas

        #1;
        $display("T=%0t: Verificando... gpio_out debe permanecer sin cambios. gpio_out = %b", $time, gpio_out);

        // 5. Fin de la simulación
        #(CLK_PERIOD * 2);
        $display("T=%0t: --- Fin de la Simulación ---", $time);
        $finish; // Termina la simulación
    end

    // Monitor de Señales Clave
    // Imprime en consola cada vez que una de las señales en la lista cambia.
    initial begin
        $monitor("Monitor @ T=%0t: clk=%b, rst=%b, cs=%b, wr=%b, addr=%h, d_in=%h -> gpio_out=%b",
                 $time, clk, rst, cs, wr, addr, d_in, gpio_out);
    end

    // Configuración para Volcado de Formas de Onda (VCD)
    // Esto crea un archivo 'waves.vcd' que puede ser visualizado con GTKWave.
    initial begin
        $dumpvars(0, peripheral_gpio_tb);
    end

endmodule

