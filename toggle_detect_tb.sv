module toggle_detect_tb();

//Inputs and outputs of DUT
logic clk, reset, switch_n; //Inputs of iDUT
logic toggle_led; //Output 
//logic [2:0] current_state; //Output
logic [1:0] message;

//Instantiate DUT
	toggle_detect iDUT(
		.clk(clk),
		.reset(reset),
		.switch_n(switch_n),
		.led_out(toggle_led),
		.message(message)
	);
  

reg [5:0] i;
  localparam START = 2'b00;
  localparam SW_ON = 2'b01;
  localparam SW_OFF = 2'b10;
  localparam ERROR = 2'b11;
  
  localparam SW_HIGH = 1'b1;
  localparam SW_LOW = 1'b0;
  localparam LED_ON = 1'b1;
  localparam LED_OFF = 1'b0;
  
  localparam message_START = 2'b11;
  localparam message_STOP = 2'b10;  
  
initial begin
clk = 0;
reset = 1; //Reset is an active high signal
switch_n = SW_LOW;
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
	if(iDUT.current_state != START || toggle_led != LED_OFF)begin
		$display("Test 1 failed: Was supposed to be in START state, was in: %h, Message: %h, Message_START: %h", iDUT.current_state, message, message_START);
		$stop();
	end if(message != message_STOP) begin
		$display("Test 1 failed: Was supposed to be in START state, was in: %h, Message: %h, Message_START: %h", iDUT.current_state, message, message_START);
		$stop();
	end
	else begin
		$display("Test 1 passed!");
	end

//Test state transitions for START state
switch_n = SW_HIGH;
@(posedge clk);
@(posedge clk);
@(negedge clk);
//Check transition out of START state
	if(iDUT.current_state != SW_ON || toggle_led != LED_ON || message != message_START)begin
		$display("Test 2 failed: Was supposed to be in LED0 state, was in: %h, Message: %h", iDUT.current_state, message_START);
		$stop();	
	end
	else begin
		$display("Test 2 passed!");
	end
	
//Test state transitions for START state
switch_n = SW_LOW;
@(posedge clk);
@(posedge clk);
@(negedge clk);
//Check transition out of START state
	if(iDUT.current_state != SW_OFF || toggle_led != LED_OFF || message != message_STOP)begin
		$display("Test 3 failed: Was supposed to be in LED0 state, was in: %h", iDUT.current_state);
		$stop();	
	end
	else begin
		$display("Test 3 passed!");
	end
	

$display("All tests passed!");
$stop();

end




//Clock
always
#2 clk = ~clk;

endmodule
