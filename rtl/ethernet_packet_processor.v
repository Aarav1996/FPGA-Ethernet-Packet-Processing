module ethernet_packet_processor #(
    parameter [47:0] LOCAL_MAC = 48'h00_11_22_33_44_55
)(
    input  wire       clk,
    input  wire       rst_n,

    // Ethernet RX
    input  wire [7:0] rx_data,
    input  wire       rx_valid,
    input  wire       rx_last,

    // Ethernet TX
    output reg  [7:0] tx_data,
    output reg        tx_valid,
    output reg        tx_last,

    // Status
    output wire [47:0] destination_mac,
    output wire [47:0] source_mac,
    output wire [15:0] packet_ethertype,
    output wire        packet_accepted
);

    wire header_valid;

    // ----------------------------------------
    // Packet Parser
    // ----------------------------------------

    packet_parser parser_inst (

        .clk(clk),
        .rst_n(rst_n),

        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_last(rx_last),

        .dest_mac(destination_mac),
        .src_mac(source_mac),
        .ethertype(packet_ethertype),

        .header_valid(header_valid)

    );


    // ----------------------------------------
    // MAC Filter
    // ----------------------------------------

    packet_filter #(
        .LOCAL_MAC(LOCAL_MAC)
    )
    filter_inst (

        .clk(clk),
        .rst_n(rst_n),

        .dest_mac(destination_mac),
        .header_valid(header_valid),

        .packet_accept(packet_accepted)

    );


    // ----------------------------------------
    // Packet Buffer
    // ----------------------------------------

    reg [7:0] packet_memory [0:2047];

    reg [11:0] write_pointer;
    reg [11:0] read_pointer;

    reg [11:0] packet_length;

    reg [1:0] state;

    localparam IDLE     = 2'd0;
    localparam RECEIVE  = 2'd1;
    localparam TRANSMIT = 2'd2;


    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            state         <= IDLE;

            write_pointer <= 12'd0;
            read_pointer  <= 12'd0;

            packet_length <= 12'd0;

            tx_data       <= 8'd0;
            tx_valid      <= 1'b0;
            tx_last       <= 1'b0;

        end

        else begin

            case (state)

                // --------------------------------
                // IDLE
                // --------------------------------

                IDLE: begin

                    tx_valid <= 1'b0;
                    tx_last  <= 1'b0;

                    write_pointer <= 12'd0;
                    read_pointer  <= 12'd0;

                    if (rx_valid) begin

                        packet_memory[0] <= rx_data;

                        write_pointer <= 12'd1;

                        state <= RECEIVE;

                    end

                end


                // --------------------------------
                // RECEIVE
                // --------------------------------

                RECEIVE: begin

                    if (rx_valid) begin

                        packet_memory[write_pointer] <= rx_data;

                        write_pointer <= write_pointer + 1'b1;

                        if (rx_last) begin

                            packet_length <= write_pointer + 1'b1;

                            state <= TRANSMIT;

                        end

                    end

                end


                // --------------------------------
                // TRANSMIT
                // --------------------------------

                TRANSMIT: begin

                    if (packet_accepted) begin

                        tx_valid <= 1'b1;

                        tx_data <= packet_memory[read_pointer];

                        if (read_pointer == packet_length - 1) begin

                            tx_last <= 1'b1;

                            state <= IDLE;

                        end

                        else begin

                            tx_last <= 1'b0;

                            read_pointer <= read_pointer + 1'b1;

                        end

                    end

                    else begin

                        tx_valid <= 1'b0;
                        tx_last  <= 1'b0;

                        state <= IDLE;

                    end

                end

                default:
                    state <= IDLE;

            endcase

        end

    end

endmodule
