`timescale 1ns/1ps
// EDA Playground Top Level: uart_rx_tb

module uart_rx_tb;

  // 125 MHz clock (8 ns), baud = 3 Mbps  -> prescale = 125e6/(baud*8) = 5
  parameter DATA_WIDTH   = 8;
  parameter CLK_NS       = 8;
  parameter BAUD_HZ      = 3000000;
  parameter PRESCALE_VAL = 125000000 / (BAUD_HZ * 8);

  // DUT I/O
  reg                     clk = 1'b0;
  reg                     rst = 1'b0;
  reg                     rxd = 1'b1;      // idle high
  wire [DATA_WIDTH-1:0]   m_axis_tdata;
  wire                    m_axis_tvalid;
  reg                     m_axis_tready = 1'b1;
  wire                    busy;
  wire                    overrun_error;
  wire                    frame_error;
  reg  [15:0]             prescale;

  // clock
  always #(CLK_NS/2) clk = ~clk;

  // DUT
  uart_rx #(.DATA_WIDTH(DATA_WIDTH)) dut (
    .clk(clk),
    .rst(rst),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .rxd(rxd),
    .busy(busy),
    .overrun_error(overrun_error),
    .frame_error(frame_error),
    .prescale(prescale)
  );

  // wave dump
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, uart_rx_tb);
  end

  // simple timeout so EP doesn’t kill the job silently
  initial begin
    #50_000;  // 50 us
    $display("TIMEOUT: end of demo window");
    $finish;
  end

  // helpers
  integer bit_cycles;  // clocks per serial bit = 8 * prescale
  task wait_clocks; input integer n; integer i; begin
    for (i=0;i<n;i=i+1) @(posedge clk);
  end endtask

  // send one byte on rxd (8N1): start(0), 8 data LSB-first, stop(1)
  task uart_send_byte; input [7:0] b; integer i; begin
    rxd = 1'b0;               // start
    wait_clocks(bit_cycles);
    for (i=0;i<8;i=i+1) begin
      rxd = b[i];             // LSB-first
      wait_clocks(bit_cycles);
    end
    rxd = 1'b1;               // stop
    wait_clocks(bit_cycles);
  end endtask

  // monitor: print when a byte is received
  always @(posedge clk) if (m_axis_tvalid)
    $display("RX: 0x%02x  busy=%0d frame_err=%0d  @ %0t ns",
             m_axis_tdata, busy, frame_error, $time);

  // test sequence: reset, idle gap, send 0x55, wait a bit, finish
  initial begin
    prescale   = PRESCALE_VAL[15:0];
    bit_cycles = 8 * PRESCALE_VAL;

    // reset
    rst = 1'b1; wait_clocks(4);
    rst = 1'b0; wait_clocks(4);

    // idle line before first start bit (important for RX)
    wait_clocks(bit_cycles*2);

    // send one demo byte (01010101)
    $display("INFO: sending 0x55 @ %0t ns", $time);
    uart_send_byte(8'h55);

    // give RX time to assert tvalid, then end the demo
    wait_clocks(bit_cycles*8);  // ~8 bit-times extra view
    $display("DONE: single-byte demo complete");
    $finish;
  end

endmodule
