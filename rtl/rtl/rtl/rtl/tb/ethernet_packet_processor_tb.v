`timescale 1ns/1ps

module ethernet_packet_processor_tb;

    reg clk;
    reg rst_n;

    reg [7:0] rx_data;
    reg       rx_valid;
    reg       rx_last;

    wire [7:0] tx_data;
    wire       tx_valid;
    wire       tx_last;

    wire [47:0] destination_mac;
    wire [47:0] source_mac;

    wire [15:0] packet_ethertype;

    wire packet_accepted;


    // ----------------------------------------
    // DUT
    // ----------------------------------------

    ethernet_packet_processor #(
        .LOCAL_MAC(48'h00_11_22_33_44_55)
    )
    dut (

        .clk(clk),
        .rst_n(rst_n),

        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_last(rx_last),

        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .tx_last(tx_last),

        .destination_mac(destination_mac),
        .source_mac(source_mac),
        .packet_ethertype(packet_ethertype),

        .packet_accepted(packet_accepted)

    );


    // ----------------------------------------
    // Clock
    // ----------------------------------------

    initial begin

        clk = 0;

        forever #5 clk = ~clk;

    end


    // ----------------------------------------
    // Send Byte
    // ----------------------------------------

    task send_byte;

        input [7:0] data;
        input       last;

        begin

            @(posedge clk);

            rx_data  <= data;
            rx_valid <= 1'b1;
            rx_last  <= last;

            @(posedge clk);

            rx_valid <= 1'b0;
            rx_last  <= 1'b0;

        end

    endtask


    // ----------------------------------------
    // Test
    // ----------------------------------------

    initial begin

        rx_data  = 0;
        rx_valid = 0;
        rx_last  = 0;

        rst_n = 0;

        #100;

        rst_n = 1;

        #20;


        // ------------------------------------
        // Ethernet Destination MAC
        // 00:11:22:33:44:55
        // ------------------------------------

        send_byte(8'h00, 0);
        send_byte(8'h11, 0);
        send_byte(8'h22, 0);
        send_byte(8'h33, 0);
        send_byte(8'h44, 0);
        send_byte(8'h55, 0);


        // ------------------------------------
        // Source MAC
        // AA:BB:CC:DD:EE:FF
        // ------------------------------------

        send_byte(8'hAA, 0);
        send_byte(8'hBB, 0);
        send_byte(8'hCC, 0);
        send_byte(8'hDD, 0);
        send_byte(8'hEE, 0);
        send_byte(8'hFF, 0);


        // ------------------------------------
        // EtherType = IPv4
        // ------------------------------------

        send_byte(8'h08, 0);
        send_byte(8'h00, 0);


        // ------------------------------------
        // Payload
        // ------------------------------------

        send_byte(8'hDE, 0);
        send_byte(8'hAD, 0);
        send_byte(8'hBE, 0);
        send_byte(8'hEF, 1);


        #200;

        $display("Destination MAC = %h",
                 destination_mac);

        $display("Source MAC = %h",
                 source_mac);

        $display("EtherType = %h",
                 packet_ethertype);

        $display("Packet Accepted = %b",
                 packet_accepted);


        #100;

        $finish;

    end

endmodule
