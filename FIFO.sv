
////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(IF.DUT Design);

parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
 
localparam max_fifo_addr = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];
reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

// Write Logic: handles wr_ack and overflow
always @(posedge Design.clk or negedge Design.rst_n) begin
	if (!Design.rst_n) begin  
		wr_ptr <= 0;
		Design.wr_ack <= 0;
		Design.overflow <= 0;
	end
	else if (Design.wr_en && !Design.full) begin
		mem[wr_ptr] <= Design.data_in;
		Design.wr_ack <= 1;
		// wrap around when pointer reaches end
		wr_ptr <= (wr_ptr == FIFO_DEPTH-1) ? 0 : wr_ptr + 1;
	end
	else begin 
		Design.wr_ack <= 0; 
		// overflow asserted if write attempted while FIFO full
		if (Design.wr_en && Design.full)
			Design.overflow <= 1;
		else
			Design.overflow <= 0;
	end
end

// Read Logic: handles data_out and underflow
always @(posedge Design.clk or negedge Design.rst_n) begin
	if (!Design.rst_n) begin 
		rd_ptr <= 0;
		Design.data_out <= 0;
		Design.underflow <= 0;
	end
	else if (Design.rd_en && !Design.empty) begin
		Design.data_out <= mem[rd_ptr];
		// wrap around when pointer reaches end
		rd_ptr <= (rd_ptr == FIFO_DEPTH-1) ? 0 : rd_ptr + 1;
		Design.underflow <= 0;
	end
	else begin
		// underflow asserted if read attempted while FIFO empty
		if (Design.rd_en && Design.empty)
			Design.underflow <= 1;
		else
			Design.underflow <= 0;
	end
end

// Counter Logic: handles simultaneous read/write correctly
always @(posedge Design.clk or negedge Design.rst_n) begin
	if (!Design.rst_n) begin
		count <= 0;
	end
	else begin 
		case ({Design.wr_en, Design.rd_en})
			2'b10: if (!Design.full)  count <= count + 1;       // write only
			2'b01: if (!Design.empty) count <= count - 1;       // read only
			2'b11: begin                                         // both high
				if (Design.empty)      count <= count + 1;       // empty 	 write only
				else if (Design.full)  count <= count - 1;       // full 	 read only
				else                   count <= count;           // normal    no change
			end
			default: count <= count;
		endcase
	end
end

// Flag Assignments
assign Design.full = (count == FIFO_DEPTH)? 1 : 0;
assign Design.empty = (count == 0)? 1 : 0;
assign Design.almostfull = (count == FIFO_DEPTH-1)? 1 : 0;  // BUG: FIFO_DEPTH-1 not FIFO_DEPTH-2
assign Design.almostempty = (count == 1)? 1 : 0;

`ifdef SIM

// Concurrent Assertion
property BothActive_StableCount;
  @(posedge Design.clk) disable iff(!Design.rst_n)
  (Design.wr_en && Design.rd_en && !Design.full && !Design.empty)
  |=> $stable(count) &&
      ((wr_ptr == $past(wr_ptr) + 1) || (($past(wr_ptr) == FIFO_DEPTH-1) && wr_ptr == 0)) &&
      ((rd_ptr == $past(rd_ptr) + 1) || (($past(rd_ptr) == FIFO_DEPTH-1) && rd_ptr == 0));
endproperty

property WriteOnly_CountInc;
  @(posedge Design.clk) disable iff(!Design.rst_n)
  (Design.wr_en && !Design.rd_en && !Design.full)
  |=> (count == $past(count) + 1);
endproperty

property ReadOnly_CountDec;
  @(posedge Design.clk) disable iff(!Design.rst_n)
  (!Design.wr_en && Design.rd_en && !Design.empty)
  |=> (count == $past(count) - 1);
endproperty

property WriteFull_NoPtrMove;
  @(posedge Design.clk) disable iff(!Design.rst_n)
  (Design.wr_en && Design.full)
  |=> $stable(wr_ptr);
endproperty

property ReadEmpty_NoPtrMove;
  @(posedge Design.clk) disable iff(!Design.rst_n)
  (Design.rd_en && Design.empty)
  |=> $stable(rd_ptr);
endproperty

BothActiveCheck: assert property(BothActive_StableCount);
WriteIncCheck:   assert property(WriteOnly_CountInc);
ReadDecCheck:    assert property(ReadOnly_CountDec);
WriteFullCheck:  assert property(WriteFull_NoPtrMove);
ReadEmptyCheck:  assert property(ReadEmpty_NoPtrMove);

// Reset Assertions 
always_comb begin 
	if (!Design.rst_n) begin
		assert final(count == 0);
		assert final(wr_ptr == 0);
		assert final(rd_ptr == 0);
		assert final(Design.full == 0);
		assert final(Design.empty == 1);
		assert final(Design.almostfull == 0);
		assert final(Design.almostempty == 0);
		assert final(Design.overflow == 0);
		assert final(Design.underflow == 0);
	end
end

// Flag Assertions
always_comb if (count == FIFO_DEPTH)     assert final(Design.full);
always_comb if (count == 0)              assert final(Design.empty);
always_comb if (count == FIFO_DEPTH - 1) assert final(Design.almostfull);
always_comb if (count == 1)              assert final(Design.almostempty);

// Sequential Flag Behavior 
property WriteAck_OK;
  @(posedge Design.clk) disable iff(!Design.rst_n)
  (Design.wr_en && !Design.full) |=> Design.wr_ack;
endproperty

property Overflow_OK;
  @(posedge Design.clk) disable iff(!Design.rst_n)
  (Design.wr_en && Design.full) |=> Design.overflow;
endproperty

property Underflow_OK;
  @(posedge Design.clk) disable iff(!Design.rst_n)
  (Design.rd_en && Design.empty) |=> Design.underflow;
endproperty

property WrPtr_Wrap;
  @(posedge Design.clk)
  (wr_ptr == FIFO_DEPTH-1 && Design.wr_en && !Design.full) |=> (wr_ptr == 0);
endproperty

property RdPtr_Wrap;
  @(posedge Design.clk)
  (rd_ptr == FIFO_DEPTH-1 && Design.rd_en && !Design.empty) |=> (rd_ptr == 0);
endproperty

property Pointers_InRange;
  @(posedge Design.clk)
  (count <= FIFO_DEPTH) && (wr_ptr < FIFO_DEPTH) && (rd_ptr < FIFO_DEPTH);
endproperty

AckCheck:      assert property(WriteAck_OK);
OverflowCheck: assert property(Overflow_OK);
UnderflowCheck:assert property(Underflow_OK);
WrPtrWrap:     assert property(WrPtr_Wrap);
RdPtrWrap:     assert property(RdPtr_Wrap);
PtrRange:      assert property(Pointers_InRange);

`endif

endmodule