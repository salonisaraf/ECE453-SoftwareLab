
/*

  Author:  Joe Krachey
  Date:  01/10/2017

*/


module ece453(
  // signals to connect to an Avalon clock source interface
  clk,
  reset,
  // signals to connect to an Avalon-MM slave interface
  slave_address,
  slave_read,
  slave_write,
  slave_readdata,
  slave_writedata,
  slave_byteenable,
  gpio_inputs,
  gpio_outputs,
  irq_out
);

  //*******************************************************************
  // Module Interface
  //*******************************************************************
  input clk;
  input reset;
  
  // slave interface
  input [4:0] slave_address;
  input slave_read;
  input slave_write;
  output wire [31:0] slave_readdata;
  input [31:0] slave_writedata;
  input [3:0] slave_byteenable;

  input [31:0] gpio_inputs;
  output [31:0] gpio_outputs;
  output wire irq_out;

  `include "ece453.vh"

  
  //*******************************************************************
  // Register Set
  //*******************************************************************
  reg  [31:0] dev_id_r;
  reg  [31:0] control_r;
  reg  [31:0] status_r; 
  reg  [31:0] im_r;
  reg  [31:0] irq_r;
  reg  [31:0] gpio_in_r;
  reg  [31:0] gpio_out_r;

   //*******************************************************************
  // Wires/Reg
  //*******************************************************************
  wire  [31:0] control_in;
  wire  [31:0] status_in;
  wire  [31:0] im_in;
  reg   [31:0] irq_in;
  wire  [31:0] gpio_in;
  wire  [31:0] gpio_out;
  reg   [31:0] gpio_in_irqs;
  wire  [2:0]  fsm_state;
  wire  [3:0]  fsm_leds;
  wire         debounced_key;

  //*******************************************************************
  // Register Read Assignments
  //*******************************************************************
  assign slave_readdata = 
        ( (slave_address == DEV_ID_ADDR )    && slave_read )  ? dev_id_r :
        ( (slave_address == CONTROL_ADDR )   && slave_read )  ? control_r:
        ( (slave_address == STATUS_ADDR )    && slave_read )  ? status_r:
        ( (slave_address == IM_ADDR )        && slave_read )  ? im_r :
        ( (slave_address == IRQ_ADDR )       && slave_read )  ? irq_r :
        ( (slave_address == GPIO_IN_ADDR )   && slave_read )  ? gpio_in_r :
        ( (slave_address == GPIO_OUT_ADDR )  && slave_read )  ? gpio_out_r : 32'h00000000 ;

  //*******************************************************************
  // Output Assignments
  //*******************************************************************
   
  // IRQ indicating that an interrupt is active 
  assign irq_out = | (im_r & irq_r);
  assign gpio_outputs = {gpio_out_r[31:0]};

  // Combinational Logic Interrupt.  The interrupt will be generated when the FSM
  // enters state 1 or state 4.
	always @ (*)
	begin
		// Set the default value of the irq registe
		irq_in = irq_r;
		
		if( ((fsm_state == 3'd1) || ( fsm_state == 3'd4)) && ( fsm_state != status_r[2:0]))
		begin
			irq_in = irq_r | 32'h1;
		end
		
		else
		begin
			// Check to see if the IRQ is being cleared.
			if(slave_address == IRQ_ADDR)
			begin
				if( slave_write )
				begin
					irq_in = irq_r & (~slave_writedata);
				end
			end
		end

	end

  // Input signals for registers
  assign control_in     = ( (slave_address == CONTROL_ADDR )  && slave_write ) ? (slave_writedata & (CONTROL_FSM_DIR_MASK | CONTROL_FSM_ENABLE_MASK)) : control_r ;
  assign status_in      = {29'h0, fsm_state };
  assign im_in          = ( (slave_address == IM_ADDR )   && slave_write ) ? slave_writedata : im_r;
  assign gpio_in        = gpio_inputs;
  assign gpio_out       = {24'h0, fsm_state, fsm_leds};
  //assign gpio_out       = ( (slave_address == GPIO_OUT_ADDR )   && slave_write ) ? slave_writedata : gpio_out_r;

  //*******************************************************************
  // Registers
  //*******************************************************************
  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      dev_id_r    <= 32'hECE45318;
      control_r   <= 32'h00000000;
      status_r    <= 32'h00000000;
      im_r        <= 32'h00000000;
      irq_r       <= 32'h00000000;
      gpio_in_r   <= 32'h00000000;
      gpio_out_r  <= 32'h00000000;
    end
    
    else
    begin
      dev_id_r    <= 32'hECE45318;
      control_r   <= control_in;
      status_r    <= status_in;
      im_r        <= im_in;
      irq_r       <= irq_in;
      gpio_in_r   <= gpio_in;
      gpio_out_r  <= gpio_out;
    end
  end

  // Debounce the button that controls the state machine 
  ece453_debounce push_button
  (
	  .clk(clk),
	  .reset(reset),
    .button_in(gpio_inputs[0]),
    .button_out(debounced_key)
  ); 

  // Determine if the LED should be moved.
  ece453_fsm_example ece453_fsm
  (
	  .clk(clk),
	  .reset(reset),
    .fsm_enable(control_r[CONTROL_FSM_ENABLE_BIT_NUM]),
    .button(debounced_key),
    .direction(control_r[CONTROL_FSM_DIR_BIT_NUM]),
    .led_out(fsm_leds), 
    .current_state(fsm_state)
  );


endmodule

//*****************************************************************************
// ECE453 FSM Example 
//*****************************************************************************
module ece453_fsm_example(
  input clk,
  input reset,
  input fsm_enable,
  input button,
  input direction,
  output reg [3:0] led_out,
  output reg [2:0] current_state
);

 
  // Include the header file with the state definitions
  `include "ece453_fsm_example.vh"
  
  reg [2:0] next_state;



  // Implment the combinational logic for the FSM and output logic as
  // a combinational block using BLOCKING statements!!!
  //
  // The sensitivity list should be a *
  always @ (*) 
  begin
	//Default output and state
    next_state = ERROR;
	led_out = 4'b1111;

  case(current_state)
	START: begin
		if(~fsm_enable)begin
			next_state = START;
			led_out = LED_OUT_START;
		end 
		else begin
			next_state = LED0;
			led_out = LED_OUT_LED0;
		end
	end
	
	LED0: begin
		//Typo in the documentation for state transition: L is supposed to be D
		if(fsm_enable && button && ~direction)begin
			next_state = LED0;
			led_out = LED_OUT_LED0;
		end
		else if(fsm_enable && ~button)begin
			next_state = LED0;
			led_out = LED_OUT_LED0;
		end
		else if(~fsm_enable)begin
			next_state = LED0;
			led_out = LED_OUT_LED0;			
		end
		else if (fsm_enable && button && direction)begin
			next_state = LED1;
			led_out = LED_OUT_LED1;
		end
	end
	
	LED1: begin 
		if(fsm_enable && button && ~direction)begin
			next_state = LED0;
			led_out = LED_OUT_LED0;
		end
		else if(fsm_enable && ~button)begin
			next_state = LED1;
			led_out = LED_OUT_LED1;		
		end
		else if(~fsm_enable)begin
			next_state = LED1;
			led_out = LED_OUT_LED1;				
		end
		else if(fsm_enable && button && direction)begin
			next_state = LED2;
			led_out = LED_OUT_LED2;
		end
	end
	
	LED2: begin
		if(fsm_enable && button && ~direction)begin
			next_state = LED1;
			led_out = LED_OUT_LED1;				
		end
		else if(fsm_enable && ~button)begin
			next_state = LED2;
			led_out = LED_OUT_LED2;			
		end
		else if(~fsm_enable)begin
			next_state = LED2;
			led_out = LED_OUT_LED2;				
		end
		else if(fsm_enable && button && direction)begin
			next_state = LED3;
			led_out = LED_OUT_LED3;
		end
	end
	
	LED3: begin
		if(fsm_enable && button && ~direction)begin
			next_state = LED2;
			led_out = LED_OUT_LED2;	
		end
		else if(fsm_enable && ~button)begin
			next_state = LED3;
			led_out = LED_OUT_LED3;
		end 
		else if(~fsm_enable)begin
			next_state = LED3;
			led_out = LED_OUT_LED3;		
		end
		else if(fsm_enable && button && direction)begin
			next_state = LED3;
			led_out = LED_OUT_LED3;				
		end
	end
	
  endcase
  end

  // Implement the D Flip Flops used for the FSM as a separate always block
  //
  // For sequential logic, you must use NON-Blocking statements!!!! 
  //
  // The sensitivity list should ONLY be the an edge of the clock AND the reset
  // signal.
  always @ ( posedge clk or posedge reset) 
  begin
    if  (reset == 1) 
    begin
      current_state <= START;
    end 
    else 
    begin
      current_state <= next_state;
    end
  end

endmodule 

//*****************************************************************************
// ECE453 Button Debounce 
//*****************************************************************************
module ece453_debounce(
  input clk,
  input reset,
  input button_in,
  output reg button_out
);

  
  reg [23:0] debounce_timer_r;
  reg [7:0] samples_r;

  reg [23:0] debounce_timer_in;
  reg [7:0] samples_in;

  // Combinational Logic
  always @ (*) 
  begin
      if(debounce_timer_r == 24'd0)
      begin
        debounce_timer_in = 24'd500000;
        samples_in = ((samples_r << 1) | button_in);
      end
      else
      begin
        debounce_timer_in = debounce_timer_r - 24'd1;
        samples_in = samples_r;
      end

      if( samples_r == 8'h80)
      begin
        button_out = 1;
        samples_in = 8'h00;
      end
      else
      begin
        button_out = 0;
      end

  end

  // Sequential Logic
  always @ ( posedge clk or posedge reset) 
  begin
    if(reset) 
    begin
      samples_r         <= 8'hFF;
      debounce_timer_r  <= 24'd500000;
    end

    else 
    begin
      debounce_timer_r  <= debounce_timer_in;
      samples_r         <= samples_in;
    end
  end

endmodule


