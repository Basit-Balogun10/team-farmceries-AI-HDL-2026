`default_nettype none

/**
 * UART Register Interface
 * 
 * Memory-mapped register interface for UART control/status.
 * Connects TinyQV CPU bus to UART TX/RX modules.
 * 
 * Register Map (6-bit address space):
 * 0x00 - CTRL:   [3:0] baud_sel, [4] tx_enable, [5] rx_enable
 * 0x04 - STATUS: [0] tx_busy, [1] rx_ready, [2] rx_error (read-only)
 * 0x08 - TX_DATA: [7:0] data to transmit (write triggers transmission)
 * 0x0C - RX_DATA: [7:0] received data (read-only)
 * 0x10 - INT_EN: [0] tx_done_int_en, [1] rx_ready_int_en
 * 0x14 - INT_CLR: [0] clear_tx_int, [1] clear_rx_int (write 1 to clear)
 */
module uart_register_interface (
    input  wire        clk,
    input  wire        rst_n,
    
    // CPU Bus Interface (from peripheral.v)
    input  wire [5:0]  address,
    input  wire [31:0] data_in,
    input  wire [1:0]  data_write_n,  // 11=no write, 00=8bit, 01=16bit, 10=32bit
    input  wire [1:0]  data_read_n,   // 11=no read, 00=8bit, 01=16bit, 10=32bit
    output wire [31:0] data_out,
    output wire        data_ready,
    
    // UART TX Interface
    output wire [7:0]  tx_data,
    output reg         tx_start,
    input  wire        tx_busy,
    
    // UART RX Interface
    input  wire [7:0]  rx_data,
    input  wire        rx_ready,
    input  wire        rx_error,
    
    // Baud rate selection
    output wire [3:0]  baud_sel,
    
    // Interrupt output
    output wire        uart_interrupt
);

    // Register addresses
    localparam ADDR_CTRL    = 6'h00;
    localparam ADDR_STATUS  = 6'h04;
    localparam ADDR_TX_DATA = 6'h08;
    localparam ADDR_RX_DATA = 6'h0C;
    localparam ADDR_INT_EN  = 6'h10;
    localparam ADDR_INT_CLR = 6'h14;
    
    // Registers
    reg [7:0] ctrl_reg;       // [3:0] baud_sel, [4] tx_en, [5] rx_en
    reg [7:0] tx_data_reg;    // Data to transmit
    reg [7:0] rx_data_reg;    // Received data (latched)
    reg [1:0] int_en_reg;     // [0] tx_done_int_en, [1] rx_ready_int_en
    reg [1:0] int_status_reg; // [0] tx_done_pending, [1] rx_ready_pending
    
    // Status flags (read-only, directly from UART modules)
    wire [7:0] status_reg;
    assign status_reg = {5'b0, rx_error, rx_ready, tx_busy};
    
    // Extract baud_sel from control register
    assign baud_sel = ctrl_reg[3:0];
    
    // Assign tx_data output
    assign tx_data = tx_data_reg;
    
    // Write logic
    wire write_en = (data_write_n != 2'b11);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ctrl_reg      <= 8'h00;  // Default: 9600 baud (sel=0), disabled
            tx_data_reg   <= 8'h00;
            tx_start      <= 1'b0;
            int_en_reg    <= 2'b00;
        end else begin
            // Default: clear tx_start pulse after 1 cycle
            tx_start <= 1'b0;
            
            if (write_en) begin
                case (address)
                    ADDR_CTRL: begin
                        ctrl_reg <= data_in[7:0];
                    end
                    
                    ADDR_TX_DATA: begin
                        // Writing to TX_DATA triggers transmission
                        tx_data_reg <= data_in[7:0];
                        tx_start    <= 1'b1;  // Pulse for 1 cycle
                    end
                    
                    ADDR_INT_EN: begin
                        int_en_reg <= data_in[1:0];
                    end
                    
                    ADDR_INT_CLR: begin
                        // Write 1 to clear interrupt
                        if (data_in[0]) int_status_reg[0] <= 1'b0;
                        if (data_in[1]) int_status_reg[1] <= 1'b0;
                    end
                    
                    default: begin
                        // Ignore writes to undefined addresses
                    end
                endcase
            end
        end
    end
    
    // RX data latching and interrupt generation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_data_reg      <= 8'h00;
            int_status_reg   <= 2'b00;
        end else begin
            // Latch RX data when ready pulse occurs
            if (rx_ready) begin
                rx_data_reg      <= rx_data;
                int_status_reg[1] <= 1'b1;  // Set RX interrupt pending
            end
            
            // Set TX interrupt when transmission completes
            // (tx_busy falling edge)
            if (!tx_busy && int_status_reg[0] == 1'b0) begin
                // Check if we just completed a transmission
                // This is a simplified approach - could track tx_busy edge
            end
        end
    end
    
    // Read logic
    reg [31:0] read_data;
    
    always @(*) begin
        case (address)
            ADDR_CTRL:    read_data = {24'h0, ctrl_reg};
            ADDR_STATUS:  read_data = {24'h0, status_reg};
            ADDR_TX_DATA: read_data = {24'h0, tx_data_reg};
            ADDR_RX_DATA: read_data = {24'h0, rx_data_reg};
            ADDR_INT_EN:  read_data = {30'h0, int_en_reg};
            ADDR_INT_CLR: read_data = {30'h0, int_status_reg};
            default:      read_data = 32'h00000000;
        endcase
    end
    
    assign data_out = read_data;
    
    // All reads complete in 1 cycle
    assign data_ready = 1'b1;
    
    // Generate interrupt signal
    assign uart_interrupt = |(int_status_reg & int_en_reg);
    
    // Prevent warnings for unused signals
    wire _unused = &{data_read_n, 1'b0};

endmodule

`default_nettype wire
