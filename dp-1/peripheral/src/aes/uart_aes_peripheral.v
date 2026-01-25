/*
 * UART AES Peripheral - Top-Level Integration
 * Combines existing UART peripheral with AES register interface
 * 
 * This is a minimal integration that provides:
 * 1. Standard UART functionality (existing peripheral)
 * 2. AES key/control registers for software-based AES operations
 * 
 * Note: This module provides the register infrastructure for AES.
 * Actual encryption/decryption can be done via:
 *   a) Software implementation reading/writing AES registers
 *   b) Future hardware AES datapath integration
 * 
 * The aes_uart_controller module (already tested) demonstrates
 * hardware AES integration and can be connected in future revisions.
 * 
 * Register Map:
 * UART Registers (0x00-0x1F): Direct pass-through to uart_peripheral
 *   0x00 - UART_CTRL
 *   0x04 - UART_STATUS  
 *   0x08 - UART_TX_DATA
 *   0x0C - UART_RX_DATA
 *   0x10 - INT_EN
 *   0x14 - INT_CLR
 * 
 * AES Registers (0x20-0x3F): Managed by aes_register_interface
 *   0x20 - AES_CTRL:     [0] AES_EN, [1] KEY_LOAD
 *   0x24 - AES_STATUS:   [0] TX_BUSY, [1] RX_BUSY, [2] KEY_READY
 *   0x28 - AES_KEY0:     Key bits [31:0]
 *   0x2C - AES_KEY1:     Key bits [63:32]
 *   0x30 - AES_KEY2:     Key bits [95:64]
 *   0x34 - AES_KEY3:     Key bits [127:96]
 *   0x38 - AES_TX_COUNT: Reserved
 *   0x3C - AES_RX_COUNT: Reserved
 */

`default_nettype none

module uart_aes_peripheral (
    input  wire        clk,
    input  wire        rst_n,
    
    // UART Physical Interface
    input  wire        uart_rx,
    output wire        uart_tx,
    
    // Flow Control
    input  wire        cts_n,
    output wire        rts_n,
    
    // CPU Register Interface (TinyQV bus)
    input  wire [5:0]  address,
    input  wire [31:0] data_in,
    input  wire [1:0]  data_write_n,
    input  wire [1:0]  data_read_n,
    output wire [31:0] data_out,
    output wire        data_ready,
    
    // Interrupt Output
    output wire        uart_interrupt
);

    // =========================================================================
    // Address Decode
    // =========================================================================
    
    wire uart_selected = (address[5] == 1'b0);  // 0x00-0x1F
    wire aes_selected  = (address[5] == 1'b1);  // 0x20-0x3F
    
    // =========================================================================
    // UART Peripheral Instance
    // =========================================================================
    
    wire [31:0] uart_data_out;
    wire        uart_data_ready;
    
    uart_peripheral uart_inst (
        .clk(clk),
        .rst_n(rst_n),
        
        // Physical interface
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .cts_n(cts_n),
        .rts_n(rts_n),
        
        // CPU register interface
        .address(address),
        .data_in(data_in),
        .data_write_n(uart_selected ? data_write_n : 2'b11),
        .data_read_n(uart_selected ? data_read_n : 2'b11),
        .data_out(uart_data_out),
        .data_ready(uart_data_ready),
        
        // Interrupt
        .uart_interrupt(uart_interrupt)
    );
    
    // =========================================================================
    // AES Register Interface  
    // =========================================================================
    
    wire        aes_enable;
    wire [127:0] aes_key;
    wire [31:0] aes_data_out;
    wire        aes_data_ready;
    wire        aes_bus_write = aes_selected && (data_write_n == 2'b00);
    wire        aes_bus_read = aes_selected && (data_read_n == 2'b00);
    
    // Simple byte address mapping: shift word address left by 2
    wire [7:0] aes_byte_addr = {address[3:0], 2'b00};
    
    aes_register_interface aes_reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .bus_write(aes_bus_write),
        .bus_read(aes_bus_read),
        .bus_addr(aes_byte_addr),
        .bus_wdata(data_in),
        .bus_rdata(aes_data_out),
        .bus_ready(aes_data_ready),
        // AES control outputs
        .aes_enable(aes_enable),
        .aes_key(aes_key),
        // AES status inputs (tied off for now - no hardware AES datapath)
        .tx_busy(1'b0),
        .rx_busy(1'b0),
        .tx_byte_count(4'h0),
        .rx_byte_count(4'h0)
    );
    
    // =========================================================================
    // Output Multiplexing
    // =========================================================================
    
    assign data_out = aes_selected ? aes_data_out : uart_data_out;
    assign data_ready = aes_selected ? aes_data_ready : uart_data_ready;
    
    // Note: AES key and enable signals are available for future use
    // The aes_uart_controller module can be instantiated here to create
    // a full hardware AES datapath when needed.

endmodule

`default_nettype wire
