`ifndef _ece453_fsm_example_vh_
`define _ece453_fsm_example_vh_

	//*******************************************************************
	// State Encodings 
	//*******************************************************************
	localparam	START	= 3'd0;
	localparam	LED0	= 3'd1;
	localparam	LED1	= 3'd2;
	localparam	LED2	= 3'd3;
	localparam	LED3	= 3'd4;
  localparam  ERROR = 3'd5;

	localparam	LED_OUT_START	= 4'h0;
	localparam	LED_OUT_LED0	= 4'h1;
	localparam	LED_OUT_LED1	= 4'h2;
	localparam	LED_OUT_LED2	= 4'h4;
	localparam	LED_OUT_LED3	= 4'h8;

  localparam RESET_ACTIVE   = 1'b1;
  localparam RESET_INACTIVE = 1'b0;
  
  localparam FSM_ACTIVE   = 1'b1;
  localparam FSM_INACTIVE = 1'b0;

  localparam LEFT   = 1'b1;
  localparam RIGHT  = 1'b0;

  localparam BTN_PRESSED      = 1'b1;
  localparam BTN_NOT_PRESSED  = 1'b0;

`endif
