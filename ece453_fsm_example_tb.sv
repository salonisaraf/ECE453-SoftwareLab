module ece453_fsm_example_tb();

//Inputs and outputs of DUT
logic clk, reset, fsm_enable, button, direction; //Inputs of iDUT
logic [3:0] led_out; //Output 
logic [2:0] current_state; //Output

//Instantiate DUT
ece453_fsm_example iDUT(.clk(clk), .reset(reset), .fsm_enable(fsm_enable), .button(button), .direction(direction), .led_out(led_out), .current_state(current_state));
 
// Include the header file with the state definitions
`include "ece453_fsm_example.vh"

reg [2:0] i;

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
	for(i = 0; i < 6; i++)begin
	@(posedge clk);
	@(negedge clk);
	case(i)
		0: if(current_state == LED1 && led_out == LED_OUT_LED1)begin
		$display("Test %h passed!", (i + 3'h2));
		end
		else begin
		$display("Test %h failed: Was supposed to be in LED1 state, was in: %h", (i + 3'h2), current_state);	
		end
		
		1: if(current_state == LED2 && led_out == LED_OUT_LED2)begin
		$display("Test %h passed!", (i + 3'h2));	
		end
		else begin
		$display("Test %h failed: Was supposed to be in LED2 state, was in: %h", (i + 3'h2), current_state);	
		end
			
		2: if(current_state == LED3 && led_out == LED_OUT_LED3)begin
		$display("Test %h passed!", (i + 3'h2));	
		//Reverse direction	
		direction = 0;
		end
		else begin
		$display("Test %h failed: Was supposed to be in LED3 state, was in: %h", (i + 3'h2), current_state);	
		end		
		
		3: if(current_state == LED2 && led_out == LED_OUT_LED2)begin
		$display("Test %h passed!", (i + 3'h2));	
		end		
		else begin
		$display("Test %h failed: Was supposed to be in LED2 state, was in: %h", (i + 3'h2), current_state);
		end	
			
		4: if(current_state == LED1 && led_out == LED_OUT_LED1)begin
		$display("Test %h passed!", (i + 3'h2));
		end
		else begin
		$display("Test %h failed: Was supposed to be in LED1 state, was in: %h", (i + 3'h2), current_state);
		end	
			
		5: if(current_state == LED0 && led_out == LED_OUT_LED0)begin
		$display("Test %h passed!", (i + 3'h2));
		end
		else begin
		$display("Test %h failed: Was supposed to be in LED0 state, was in: %h", (i + 3'h2), current_state);
		end				
	endcase	
	end


$display("All tests passed!");
$stop();

end


//State transitions to ensure that we remain in same state
task same_state_trans(input [2:0] state);

endtask

//Clock
always
#2 clk = ~clk;

endmodule
