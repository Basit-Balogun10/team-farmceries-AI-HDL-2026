`default_nettype none

/**
 * UART Peripheral Top Module
 * 
 * Complete UART peripheral integrating all sub-modules:
 * - Baud rate generator
 * - UART transmitter
 * - UART receiver
 * - Memory-mapped register interface
 * 
 * Interfaces with TinyQV RISC-V core via memory-mapped I/O.
 * UART TX on uo_out[0], RX on ui_in[7] (standard TinyQV UART pins)
 */
module uart_peripheral (
    input  wire        clk,          // System clock (70 MHz)
    input  wire        rst_n,        // Active-low reset
    
    // TinyQV CPU Bus Interface
    input  wire [5:0]  address,      // Register address
    input  wire [31:0] data_in,      // Write data
    input  wire [1:0]  data_write_n, // Write control
    input  wire [1:0]  data_read_n,  // Read control
    output wire [31:0] data_out,     // Read data
    output wire        data_ready,   // Read data valid
    
    // UART Physical Interface (connects to ui_in/uo_out in tt_wrapper)
    input  wire        uart_rx,      // UART RX input (from ui_in[7])
    output wire        uart_tx,      // UART TX output (to uo_out[0])
    
    // Interrupt output
    output wire        uart_interrupt
);

    // Internal signals
    wire [3:0] baud_sel;
    wire       baud_tick;
    
    // TX signals
    wire [7:0] tx_data;
    wire       tx_start;
    wire       tx_busy;
    
    // RX signals
    wire [7:0] rx_data;
    wire       rx_ready;
    wire       rx_error;
    
    // Instantiate baud rate generator
    uart_baud_generator baud_gen (
        .clk(clk),
        .rst_n(rst_n),
        .baud_sel(baud_sel),
        .enable(1'b1),           // Always enabled
        .baud_tick(baud_tick)
    );
    
    // Instantiate UART transmitter
    uart_tx transmitter (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_out(uart_tx),
        .tx_busy(tx_busy)
    );
    
    // Instantiate UART receiver
    uart_rx receiver (
        .clk(clk),
        .rst_n(rst_n),
        .rx_in(uart_rx),
        .baud_tick(baud_tick),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .rx_error(rx_error)
    );
    
    // Instantiate register interface
    uart_register_interface reg_interface (
        .clk(clk),
        .rst_n(rst_n),
        
        // CPU bus
        .address(address),
        .data_in(data_in),
        .data_write_n(data_write_n),
        .data_read_n(data_read_n),
        .data_out(data_out),
        .data_ready(data_ready),
        
        // TX interface
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        
        // RX interface
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .rx_error(rx_error),
        
        // Configuration
        .baud_sel(baud_sel),
        
        // Interrupt
        .uart_interrupt(uart_interrupt)
    );

endmodule

`default_nettype wire
