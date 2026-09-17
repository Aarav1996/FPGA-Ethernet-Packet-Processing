module packet_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 2048
)(
    input  wire                  clk,
    input  wire                  rst_n,

    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire                  write_en,

    input  wire                  read_en,

    output reg  [DATA_WIDTH-1:0] data_out,

    output wire                  full,
    output wire                  empty
);

    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    reg [11:0] write_ptr;
    reg [11:0] read_ptr;

    reg [12:0] count;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            write_ptr <= 12'd0;
            read_ptr  <= 12'd0;
            count     <= 13'd0;
            data_out  <= 8'd0;

        end

        else begin

            // Write
            if (write_en && !full) begin

                memory[write_ptr] <= data_in;
                write_ptr <= write_ptr + 1'b1;

            end

            // Read
            if (read_en && !empty) begin

                data_out <= memory[read_ptr];
                read_ptr <= read_ptr + 1'b1;

            end

            // Counter
            case ({write_en && !full, read_en && !empty})

                2'b10:
                    count <= count + 1'b1;

                2'b01:
                    count <= count - 1'b1;

                default:
                    count <= count;

            endcase

        end

    end

endmodule
