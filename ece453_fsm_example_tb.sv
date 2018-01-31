module ece453_fsm_example_tb();

//Inputs and outputs of DUT
logic clk, reset, fsm_enable, button, direction; //Inputs of iDUT
logic [3:0] led_out; //Output 
logic [2:0] current_state; //Output

//Instantiate DUT
ece453_fsm_example iDUT(.clk(clk), .reset(reset), .fsm_enable(fsm_enable), .button(button), .direction(direction), .led_out(led_out), .current_state(current_state));
 
// Include the header file with the state definitions
`include "ece453_fsm_example.vh"

reg [5:0] i;

initial begin
clk = 0;
reset = RESET_ACTIVE; //Reset is an active high signal
fsm_enable = FSM_INACTIVE;
button = BTN_NOT_PRESSED;
direction = RIGHT;

//Wait for sometime before changing inputs
@(posedge clk);
@(posedge clk);
@(negedge clk);

//Deassert reset
reset = RESET_INACTIVE;

@(posedge clk);
@(posedge clk);
@(negedge clk);
//Since reset was asserted and then deasserted, we should start in the START state
	if(current_state != START || led_out != LED_OUT_START)begin
		$display("Test 1 failed: Was supposed to be in START state, was in: %h", current_state);
		$stop();
	end
	else begin
		$display("Test 1 passed!");
	end

//Test state transitions for START state
fsm_enable = FSM_ACTIVE;
@(posedge clk);
@(posedge clk);
@(negedge clk);
fsm_enable = FSM_INACTIVE;
//Check transition out of START state
	if(current_state != LED0 || led_out != LED_OUT_LED0)begin
		$display("Test 2 failed: Was supposed to be in LED0 state, was in: %h", current_state);
		$stop();	
	end
	else begin
		$display("Test 2 passed!");
	end
	fsm_enable = FSM_ACTIVE;
	button = BTN_PRESSED;
	direction = LEFT;
	
	//Forward and backward directional state transitions 
	for(i = 2; i < 8; i++)begin
	@(posedge clk);
	@(negedge clk);
	case(i)
		2: if(current_state == LED1 && led_out == LED_OUT_LED1)begin
		$display("Test %d passed!", i);
		end
		else begin
		$display("Test %d failed: Was supposed to be in LED1 state, was in: %h", i, current_state);	
		end
		
		3: if(current_state == LED2 && led_out == LED_OUT_LED2)begin
		$display("Test %d passed!", i);	
		end
		else begin
		$display("Test %d failed: Was supposed to be in LED2 state, was in: %h", i, current_state);	
		end
			
		4: if(current_state == LED3 && led_out == LED_OUT_LED3)begin
		$display("Test %d passed!", i);	
		//Reverse direction	
		direction = 0;
		end
		else begin
		$display("Test %d failed: Was supposed to be in LED3 state, was in: %h", i, current_state);	
		end		
		
		5: if(current_state == LED2 && led_out == LED_OUT_LED2)begin
		$display("Test %d passed!", i);	
		end		
		else begin
		$display("Test %d failed: Was supposed to be in LED2 state, was in: %h", i, current_state);
		end	
			
		6: if(current_state == LED1 && led_out == LED_OUT_LED1)begin
		$display("Test %d passed!", i);
		end
		else begin
		$display("Test %d failed: Was supposed to be in LED1 state, was in: %h", i, current_state);
		end	
			
		7: if(current_state == LED0 && led_out == LED_OUT_LED0)begin
		$display("Test %d passed!", i);
		end
		else begin
		$display("Test %d failed: Was supposed to be in LED0 state, was in: %h", i, current_state);
		end				
	endcase	
	end

	same_state_trans(LED0, LED_OUT_LED0);
	same_state_trans(LED1, LED_OUT_LED1);
	same_state_trans(LED2, LED_OUT_LED2);
	same_state_trans(LED3, LED_OUT_LED3);

$display("All tests passed!");
$stop();

end


//State transitions to ensure that we remain in same state
task same_state_trans(input [2:0] state, input [3:0] leds);
		
	integer x;
	
	//Transition to next state if not in LED0
	if(state != LED0)begin
		fsm_enable = FSM_ACTIVE;
		button = BTN_PRESSED;
		direction = LEFT;
		@(posedge clk);
		@(negedge clk);
	end

	//Should remain in same state as the FSM is inactive
	fsm_enable = FSM_INACTIVE;
	for(x = 0; x < 10; x++)begin
	//Wait for some time
	@(posedge clk);
	end
	if(current_state == state && led_out == leds)begin
		$display("Test %d passed!", i);
	end
	else begin
		$display("Test %d failed! Expected state: %h, Actual state: %h", i, state, current_state);
		$stop();
	end
	i++;
	
	//Should remain in same state because even though the FSM is active, no button has been pressed
	fsm_enable = FSM_ACTIVE;
	button = BTN_NOT_PRESSED;
	for(x = 0; x < 10; x++)begin
	//Wait for some time
	@(posedge clk);
	end	
	if(current_state == state && led_out == leds)begin
		$display("Test %d passed!", i);
	end
	else begin
		$display("Test %d failed! Expected state: %h, Actual state: %h", i, state, current_state);
		$stop();
	end
	i++;
	

	if(state == LED0)begin
	//Cannot move backwards if in LEDO state 
	button = BTN_PRESSED;
	direction = RIGHT;
	for(x = 0; x < 10; x++)begin
	//Wait for some time
	@(posedge clk);
	end
		if(current_state == state && led_out == leds)begin
			$display("Test %d passed!", i);
		end
		else begin
			$display("Test %d failed! Expected state: %h, Actual state: %h", i, state, current_state);
			$stop();
		end
	end
	else if(state == LED3) begin
	//Cannot move forwards if in LED3 state 	 
	button = BTN_PRESSED;
	direction = LEFT;
	for(x = 0; x < 10; x++)begin
	//Wait for some time
	@(posedge clk);
	end	
		if(current_state == state && led_out == leds)begin
			$display("Test %d passed!", i);
		end
		else begin
			$display("Test %d failed! Expected state: %h, Actual state: %h", i, state, current_state);
			$stop();
		end		
	end
	i++;
		
endtask

//Clock
always
#2 clk = ~clk;

endmodule
