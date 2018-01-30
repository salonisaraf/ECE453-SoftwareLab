module ece453_fsm_example_tb();

//Inputs and outputs of DUT
logic clk, reset, fsm_enable, button, direction; //Inputs of iDUT
logic [3:0] led_out; //Output 
logic [2:0] current_state; //Output

//Instantiate DUT
ece453_fsm_example iDUT(.clk(clk), .reset(reset), .fsm_enable(fsm_enable), .button(button), .direction(direction), .led_out(led_out), .current_state(current_state));
  
  // Include the header file with the state definitions
  `include "ece453_fsm_example.vh"
initial begin
clk = 0;
reset = 1; //Reset is an active high signal
fsm_enable = 0;
button = 0;
direction = 0;

//Wait for sometime before changing inputs
@(posedge clk);
@(posedge clk);
@(negedge clk);

//Deassert reset
reset = 0;

@(posedge clk);
@(posedge clk);
@(negedge clk);
//Since reset was asserted and then deasserted, we should start in the START state
	if(current_state != START)begin
		$display("Test 1 failed: Was supposed to be in START state, was in: %h", current_state);
		$stop();
	end

//Test state transitions for START state
fsm_enable = 1;
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(negedge clk);
fsm_enable = 0;
//Check transition out of START state
	if(current_state != LED0)begin
		$display("Test 2 failed: Was supposed to be in START state, was in: %h", current_state);
		$stop();	
	end



$display("All tests passed!");
$stop();
end

//Clock
always
#2 clk = ~clk;

endmodule