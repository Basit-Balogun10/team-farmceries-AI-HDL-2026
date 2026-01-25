/*
 * AES UART Streaming Controller
 * Byte-level streaming encryption/decryption for UART datapath
 * 
 * Features:
 * - Byte-in, byte-out interface (compatible with UART)
 * - Automatic 16-byte buffering and block encryption/decryption
 * - Bypass mode when AES disabled (transparent passthrough)
 * - Backpressure support (busy signals)
 * 
 * Operation:
 * TX Path: Buffers 16 plaintext bytes → encrypts → outputs 16 ciphertext bytes
 * RX Path: Buffers 16 ciphertext bytes → decrypts → outputs 16 plaintext bytes
 * Bypass: When aes_enable=0, data passes through unmodified
 */

`default_nettype none

module aes_uart_streaming (
    input  wire        clk,
    input  wire        rst_n,
    
    // AES Configuration
    input  wire        aes_enable,
    input  wire [127:0] aes_key,
    
    // TX Path (CPU → UART): Plaintext in, ciphertext out
    input  wire [7:0]  tx_data_in,
    input  wire        tx_valid_in,
    output wire        tx_ready_out,       // Ready to accept more data
    output wire [7:0]  tx_data_out,
    output wire        tx_valid_out,
    input  wire        tx_ready_in,        // UART ready to accept data
    
    // RX Path (UART → CPU): Ciphertext in, plaintext out
    input  wire [7:0]  rx_data_in,
    input  wire        rx_valid_in,
    output wire        rx_ready_out,       // Ready to accept more data
    output wire [7:0]  rx_data_out,
    output wire        rx_valid_out,
    input  wire        rx_ready_in         // CPU ready to read data
);

    // =========================================================================
    // TX Path: Byte Buffering, Encryption, Serialization
    // =========================================================================
    
    // TX State Machine
    localparam TX_IDLE = 3'd0;
    localparam TX_BUFFER = 3'd1;
    localparam TX_ENCRYPT = 3'd2;
    localparam TX_SERIALIZE = 3'd3;
    localparam TX_BYPASS = 3'd4;
    
    reg [2:0] tx_state;
    reg [3:0] tx_byte_count;
    reg [127:0] tx_plaintext_buf;
    reg [127:0] tx_ciphertext_buf;
    reg [3:0] tx_output_count;
    
    // TX AES Core
    reg tx_aes_start;
    wire tx_aes_done;
    wire [127:0] tx_aes_out;
    
    aes_core tx_aes (
        .clk(clk),
        .rst_n(rst_n),
        .start(tx_aes_start),
        .mode(1'b0),  // Encrypt
        .plaintext(tx_plaintext_buf),
        .key(aes_key),
        .ciphertext(tx_aes_out),
        .done(tx_aes_done),
        .busy()
    );
    
    // TX Control Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_state <= TX_IDLE;
            tx_byte_count <= 4'd0;
            tx_output_count <= 4'd0;
            tx_plaintext_buf <= 128'h0;
            tx_ciphertext_buf <= 128'h0;
            tx_aes_start <= 1'b0;
        end else begin
            tx_aes_start <= 1'b0;
            
            case (tx_state)
                TX_IDLE: begin
                    tx_byte_count <= 4'd0;
                    tx_output_count <= 4'd0;
                    if (tx_valid_in) begin
                        if (aes_enable) begin
                            // Start buffering for encryption
                            tx_plaintext_buf <= {120'h0, tx_data_in};
                            tx_byte_count <= 4'd1;
                            tx_state <= TX_BUFFER;
                        end else begin
                            // Bypass mode - pass through directly
                            tx_state <= TX_BYPASS;
                        end
                    end
                end
                
                TX_BUFFER: begin
                    if (tx_valid_in && tx_byte_count < 16) begin
                        tx_plaintext_buf <= {tx_plaintext_buf[119:0], tx_data_in};
                        tx_byte_count <= tx_byte_count + 1;
                        
                        if (tx_byte_count == 15) begin
                            // Full block buffered, start encryption
                            tx_aes_start <= 1'b1;
                            tx_state <= TX_ENCRYPT;
                        end
                    end
                end
                
                TX_ENCRYPT: begin
                    if (tx_aes_done) begin
                        tx_ciphertext_buf <= tx_aes_out;
                        tx_output_count <= 4'd0;
                        tx_state <= TX_SERIALIZE;
                    end
                end
                
                TX_SERIALIZE: begin
                    if (tx_ready_in && tx_output_count < 16) begin
                        // Shift out one byte (MSB first)
                        tx_ciphertext_buf <= {tx_ciphertext_buf[119:0], 8'h0};
                        tx_output_count <= tx_output_count + 1;
                        
                        if (tx_output_count == 15) begin
                            tx_state <= TX_IDLE;
                        end
                    end
                end
                
                TX_BYPASS: begin
                    if (tx_ready_in) begin
                        // In bypass mode, just pass through and return to idle
                        tx_state <= TX_IDLE;
                    end
                end
            endcase
        end
    end
    
    // TX Outputs
    assign tx_ready_out = (tx_state == TX_IDLE) || (tx_state == TX_BUFFER && tx_byte_count < 16);
    assign tx_data_out = (tx_state == TX_SERIALIZE) ? tx_ciphertext_buf[127:120] : 
                         (tx_state == TX_BYPASS) ? tx_data_in : 8'h0;
    assign tx_valid_out = (tx_state == TX_SERIALIZE) || (tx_state == TX_BYPASS && tx_valid_in);
    
    // =========================================================================
    // RX Path: Byte Buffering, Decryption, Serialization
    // =========================================================================
    
    // RX State Machine
    localparam RX_IDLE = 3'd0;
    localparam RX_BUFFER = 3'd1;
    localparam RX_DECRYPT = 3'd2;
    localparam RX_SERIALIZE = 3'd3;
    localparam RX_BYPASS = 3'd4;
    
    reg [2:0] rx_state;
    reg [3:0] rx_byte_count;
    reg [127:0] rx_ciphertext_buf;
    reg [127:0] rx_plaintext_buf;
    reg [3:0] rx_output_count;
    
    // RX AES Core
    reg rx_aes_start;
    wire rx_aes_done;
    wire [127:0] rx_aes_out;
    
    aes_core rx_aes (
        .clk(clk),
        .rst_n(rst_n),
        .start(rx_aes_start),
        .mode(1'b1),  // Decrypt
        .plaintext(rx_ciphertext_buf),
        .key(aes_key),
        .ciphertext(rx_aes_out),
        .done(rx_aes_done),
        .busy()
    );
    
    // RX Control Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_state <= RX_IDLE;
            rx_byte_count <= 4'd0;
            rx_output_count <= 4'd0;
            rx_ciphertext_buf <= 128'h0;
            rx_plaintext_buf <= 128'h0;
            rx_aes_start <= 1'b0;
        end else begin
            rx_aes_start <= 1'b0;
            
            case (rx_state)
                RX_IDLE: begin
                    rx_byte_count <= 4'd0;
                    rx_output_count <= 4'd0;
                    if (rx_valid_in) begin
                        if (aes_enable) begin
                            // Start buffering for decryption
                            rx_ciphertext_buf <= {120'h0, rx_data_in};
                            rx_byte_count <= 4'd1;
                            rx_state <= RX_BUFFER;
                        end else begin
                            // Bypass mode
                            rx_state <= RX_BYPASS;
                        end
                    end
                end
                
                RX_BUFFER: begin
                    if (rx_valid_in && rx_byte_count < 16) begin
                        rx_ciphertext_buf <= {rx_ciphertext_buf[119:0], rx_data_in};
                        rx_byte_count <= rx_byte_count + 1;
                        
                        if (rx_byte_count == 15) begin
                            // Full block buffered, start decryption
                            rx_aes_start <= 1'b1;
                            rx_state <= RX_DECRYPT;
                        end
                    end
                end
                
                RX_DECRYPT: begin
                    if (rx_aes_done) begin
                        rx_plaintext_buf <= rx_aes_out;
                        rx_output_count <= 4'd0;
                        rx_state <= RX_SERIALIZE;
                    end
                end
                
                RX_SERIALIZE: begin
                    if (rx_ready_in && rx_output_count < 16) begin
                        // Shift out one byte (MSB first)
                        rx_plaintext_buf <= {rx_plaintext_buf[119:0], 8'h0};
                        rx_output_count <= rx_output_count + 1;
                        
                        if (rx_output_count == 15) begin
                            rx_state <= RX_IDLE;
                        end
                    end
                end
                
                RX_BYPASS: begin
                    if (rx_ready_in) begin
                        rx_state <= RX_IDLE;
                    end
                end
            endcase
        end
    end
    
    // RX Outputs
    assign rx_ready_out = (rx_state == RX_IDLE) || (rx_state == RX_BUFFER && rx_byte_count < 16);
    assign rx_data_out = (rx_state == RX_SERIALIZE) ? rx_plaintext_buf[127:120] :
                         (rx_state == RX_BYPASS) ? rx_data_in : 8'h0;
    assign rx_valid_out = (rx_state == RX_SERIALIZE) || (rx_state == RX_BYPASS && rx_valid_in);

endmodule

`default_nettype wire
