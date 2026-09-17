module packet_filter #(
    parameter [47:0] LOCAL_MAC = 48'h00_11_22_33_44_55
)(
    input  wire        clk,
    input  wire        rst_n,

    input  wire [47:0] dest_mac,
    input  wire        header_valid,

    output reg         packet_accept
);

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            packet_accept <= 1'b0;
        end

        else begin

            if (header_valid) begin

                if (dest_mac == LOCAL_MAC)
                    packet_accept <= 1'b1;
                else
                    packet_accept <= 1'b0;

            end
            else begin
                packet_accept <= 1'b0;
            end

        end

    end

endmodule
