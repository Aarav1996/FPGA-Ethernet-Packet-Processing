module packet_parser (
    input  wire        clk,
    input  wire        rst_n,

    input  wire [7:0]  rx_data,
    input  wire        rx_valid,
    input  wire        rx_last,

    output reg  [47:0] dest_mac,
    output reg  [47:0] src_mac,
    output reg  [15:0] ethertype,

    output reg         header_valid
);

    reg [3:0] byte_count;

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            byte_count  <= 4'd0;
            dest_mac    <= 48'd0;
            src_mac     <= 48'd0;
            ethertype   <= 16'd0;
            header_valid <= 1'b0;

        end

        else begin

            if (rx_valid) begin

                case (byte_count)

                    // Destination MAC
                    4'd0: dest_mac[47:40] <= rx_data;
                    4'd1: dest_mac[39:32] <= rx_data;
                    4'd2: dest_mac[31:24] <= rx_data;
                    4'd3: dest_mac[23:16] <= rx_data;
                    4'd4: dest_mac[15:8]  <= rx_data;
                    4'd5: dest_mac[7:0]   <= rx_data;

                    // Source MAC
                    4'd6: src_mac[47:40] <= rx_data;
                    4'd7: src_mac[39:32] <= rx_data;
                    4'd8: src_mac[31:24] <= rx_data;
                    4'd9: src_mac[23:16] <= rx_data;
                    4'd10: src_mac[15:8] <= rx_data;
                    4'd11: src_mac[7:0]  <= rx_data;

                    // EtherType
                    4'd12: ethertype[15:8] <= rx_data;
                    4'd13: begin
                        ethertype[7:0] <= rx_data;
                        header_valid <= 1'b1;
                    end

                    default: begin
                    end

                endcase

                if (rx_last) begin
                    byte_count <= 4'd0;
                    header_valid <= 1'b0;
                end
                else begin
                    byte_count <= byte_count + 1'b1;
                end

            end
        end

    end

endmodule
