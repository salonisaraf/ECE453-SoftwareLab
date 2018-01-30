`ifndef _ece453_vh_
`define _ece453_vh_

	//*******************************************************************
	// Register Bit definitions
	//*******************************************************************
	localparam CONTROL_FSM_ENABLE_BIT_NUM		= 0;
	localparam CONTROL_FSM_ENABLE_MASK		= (32'h1 << CONTROL_FSM_ENABLE_BIT_NUM);

	localparam CONTROL_FSM_DIR_BIT_NUM		= 1;
	localparam CONTROL_FSM_DIR_MASK		= (32'h1 << CONTROL_FSM_DIR_BIT_NUM);

	localparam GPIO_OUT_LEDS_BIT_NUM		= 0;
	localparam GPIO_OUT_LEDS_MASK		= (32'h3FF << GPIO_OUT_LEDS_BIT_NUM);
	
	localparam GPIO_IN_BUTTONS_BIT_NUM	= 0;
	localparam GPIO_IN_BUTTONS_MASK		= (32'hF << GPIO_IN_BUTTONS_BIT_NUM);

	localparam STATUS_FSM_STATE_BIT_NUM		= 0;
	localparam STATUS_FSM_STATE_MASK		  = (32'h7 << STATUS_FSM_STATE_BIT_NUM);
	
  localparam STATUS_FSM_LEDS_BIT_NUM		= 3;
	localparam STATUS_FSM_LEDS_MASK		    = (32'hF << STATUS_FSM_STATE_BIT_NUM);

	//*******************************************************************
	// Register Addresses
	//*******************************************************************
	localparam	DEV_ID_ADDR	  = 5'b0000;
	localparam	CONTROL_ADDR	= 5'b0001;
	localparam  STATUS_ADDR	  = 5'b0010;
	localparam	IM_ADDR		    = 5'b0011;
	localparam	IRQ_ADDR	    = 5'b0100;
	localparam	GPIO_IN_ADDR	= 5'b0101;
	localparam	GPIO_OUT_ADDR	= 5'b0110;

	localparam	ALL_BITS      = 32'hFFFFFFFF;

  localparam  DEBOUNCE_TICKS  = 24'd10;

`endif
