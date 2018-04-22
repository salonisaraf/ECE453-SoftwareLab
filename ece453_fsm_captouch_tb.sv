module ece453_fsm_captouch_tb();

//Inputs and outputs of DUT
logic clk, reset; //Inputs of iDUT
logic [2:0] cap_touch_sig; //Output 
logic [1:0] pwm_level; //Output

//Instantiate DUT
ece453_fsm_example iDUT(.clk(clk), .reset(reset), .cap_touch_sig(cap_touch_sig), .pwm_level(pwm_level));
 
// Include the header file with the state definitions
`include "ece453_fsm_example.vh"

reg [5:0] i;

initial begin
clk = 0;
reset = RESET_ACTIVE; //Reset is an active high signal
cap_touch_sig = 3'h05;

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
	if(iDUT.current_state != OFF || pwm_level != 2'h00)begin
		$display("Test 1 failed: Was supposed to be in OFF");
		$stop();
	end
	else begin
		$display("Test 1 passed!");
	end

//Test state transitions for START state
cap_touch_sig = 3'h01;
@(posedge clk);
@(posedge clk);
@(negedge clk);
//Check transition out of HI state
	if(iDUT.current_state == HI &&  pwm_level == 2'h03)begin
		$display("Test 2 passed!");
	end
	else begin
		$display("Test failed: Was supposed to be in HI");
		$stop();	
	end
	cap_touch_sig = 3'h02;		
@(posedge clk);
@(posedge clk);
@(negedge clk);
	if(iDUT.current_state == MED && pwm_level == 2'h02)begin
		$display("Test passed!");	
		end
		else begin
		$display("Test failed: Was supposed to be in MED");	
	end
	cap_touch_sig = 3'h04;	
@(posedge clk);
@(posedge clk);
@(negedge clk);		
	if(iDUT.current_state == LOW && pwm_level == 2'h01)begin
		$display("Test passed!");	
		end
		else begin
		$display("Test failed: Was supposed to be in LOW");	
	end		
		
//	same_state_trans(LED0, LED_OUT_LED0);
//	same_state_trans(LED1, LED_OUT_LED1);
//	same_state_trans(LED2, LED_OUT_LED2);
//	same_state_trans(LED3, LED_OUT_LED3);

$display("All tests passed!");
$stop();

end



//Clock
always
#2 clk = ~clk;

endmodule
