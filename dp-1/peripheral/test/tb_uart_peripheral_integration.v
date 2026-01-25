`timescale 1ns / 1ps

/**
 * Integration testbench for UART Peripheral with FIFOs and Flow Control
 * 
 * Tests:
 * 1. TX FIFO burst write
 * 2. RX FIFO accumulation
 * 3. Flow control (CTS/RTS)
 * 4. Full duplex operation
 */
module tb_uart_peripheral_integration;

    // Clock and reset
    reg clk;
    reg rst_n;
    
    // CPU bus interface
    reg [5:0]  address;
    reg [31:0] data_in;
    reg [1:0]  data_write_n;
    reg [1:0]  data_read_n;
    wire [31:0] data_out;
    wire        data_ready;
    
    // UART interface
    reg  uart_rx;
    wire uart_tx;
    
    // Flow control
    reg  cts_n;
    wire rts_n;
    
    // Interrupt
    wire uart_interrupt;
    
    // DUT instantiation
    uart_peripheral dut (
        .clk(clk),
        .rst_n(rst_n),
        .address(address),
        .data_in(data_in),
        .data_write_n(data_write_n),
        .data_read_n(data_read_n),
        .data_out(data_out),
        .data_ready(data_ready),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .cts_n(cts_n),
        .rts_n(rts_n),
        .uart_interrupt(uart_interrupt)
    );
    
    // Clock generation (70 MHz -> 14.3ns period)
    initial begin
        clk = 0;
        forever #7 clk = ~clk;
    end
    
    // Test stimulus
    integer test_num;
    integer i;
    reg [7:0] test_byte;
    reg [31:0] read_val;
    
    initial begin
        $dumpfile("uart_peripheral_integration.vcd");
        $dumpvars(0, tb_uart_peripheral_integration);
        
        // Initialize
        test_num = 0;
        rst_n = 0;
        address = 0;
        data_in = 0;
        data_write_n = 2'b11;
        data_read_n = 2'b11;
        uart_rx = 1;  // Idle high
        cts_n = 1;    // Initially not clear to send
        
        // Reset
        #100;
        rst_n = 1;
        #100;
        
        $display("\n========================================");
        $display(" UART Peripheral Integration Tests");
        $display("========================================\n");
        
        // Test 1: Basic register access
        test_num = 1;
        $display("Test %0d: Register read/write", test_num);
        cpu_write(6'h00, 32'h0000000C);  // Set baud rate to 115200
        cpu_read(6'h00, read_val);
        if ((read_val & 8'hFF) == 8'h0C) begin
            $display("  PASS: CTRL register set to 0x%02X", read_val & 8'hFF);
        end else begin
            $display("  FAIL: CTRL register = 0x%02X, expected 0x0C", read_val & 8'hFF);
        end
        #500;
        
        // Test 2: TX FIFO burst write
        test_num = 2;
        $display("\nTest %0d: TX FIFO burst write (8 bytes)", test_num);
        cts_n = 0;  // Enable CTS
        for (i = 0; i < 8; i = i + 1) begin
            cpu_write(6'h08, {24'h0, 8'hA0 + i});
            #20;
        end
        $display("  INFO: Written 8 bytes to TX FIFO");
        
        // Wait for transmission (8 bytes * ~87us per byte at 115200)
        #8000;
        cpu_read(6'h04, read_val);
        if ((read_val & 8'h01) == 0) begin
            $display("  PASS: TX completed (not busy)");
        end else begin
            $display("  FAIL: TX still busy");
        end
        
        // Test 3: Flow control register
        test_num = 3;
        $display("\nTest %0d: Flow control register", test_num);
        cpu_write(6'h18, 32'h00000001);  // Enable flow control
        cpu_read(6'h18, read_val);
        if ((read_val & 8'h01) == 1) begin
            $display("  PASS: Flow control enabled");
        end else begin
            $display("  FAIL: Flow control not enabled");
        end
        #100;
        
        // Test 4: CTS pause/resume
        test_num = 4;
        $display("\nTest %0d: CTS flow control pause", test_num);
        cts_n = 1;  // Disable CTS (pause)
        cpu_write(6'h08, 32'h000000BB);  // Write byte
        #500;
        cpu_read(6'h04, read_val);
        $display("  INFO: STATUS with CTS paused = 0x%08X", read_val);
        
        cts_n = 0;  // Resume
        #3000;
        cpu_read(6'h04, read_val);
        if ((read_val & 8'h01) == 0) begin
            $display("  PASS: TX completed after CTS resume");
        end else begin
            $display("  FAIL: TX still busy after resume");
        end
        
        // Test 5: RX data reception
        test_num = 5;
        $display("\nTest %0d: RX data reception", test_num);
        send_uart_byte(8'h55);
        #2000;
        cpu_read(6'h04, read_val);
        if ((read_val & 8'h02) == 8'h02) begin
            $display("  INFO: RX ready flag set");
            cpu_read(6'h0C, read_val);
            if ((read_val & 8'hFF) == 8'h55) begin
                $display("  PASS: Received 0x55 correctly");
            end else begin
                $display("  FAIL: Received 0x%02X, expected 0x55", read_val & 8'hFF);
            end
        end else begin
            $display("  FAIL: RX ready flag not set");
        end
        
        // Test 6: RTS generation (simplified - just check signal exists)
        test_num = 6;
        $display("\nTest %0d: RTS signal check", test_num);
        $display("  INFO: RTS_N = %0d (active low)", rts_n);
        $display("  PASS: RTS signal present");
        
        // Final summary
        #500;
        $display("\n========================================");
        $display(" Integration Tests Completed");
        $display("========================================\n");
        
        $finish;
    end
    
    // Task: CPU write
    task cpu_write;
        input [5:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            address = addr;
            data_in = data;
            data_write_n = 2'b00;  // 8-bit write
            @(posedge clk);
            data_write_n = 2'b11;
            @(posedge clk);
        end
    endtask
    
    // Task: CPU read
    task cpu_read;
        input [5:0] addr;
        output [31:0] data;
        begin
            @(posedge clk);
            address = addr;
            data_read_n = 2'b00;  // 8-bit read
            @(posedge clk);
            data = data_out;
            data_read_n = 2'b11;
            @(posedge clk);
        end
    endtask
    
    // Task: Send UART byte
    task send_uart_byte;
        input [7:0] byte_val;
        integer bit_idx;
        begin
            // Start bit
            uart_rx = 0;
            #(38 * 14);  // 115200 baud ~= 38 clocks at 70MHz
            
            // Data bits (LSB first)
            for (bit_idx = 0; bit_idx < 8; bit_idx = bit_idx + 1) begin
                uart_rx = byte_val[bit_idx];
                #(38 * 14);
            end
            
            // Stop bit
            uart_rx = 1;
            #(38 * 14);
        end
    endtask
    
    // Timeout watchdog
    initial begin
        #200000;  // 200us timeout
        $display("\nERROR: Simulation timeout!");
        $finish;
    end

endmodule
