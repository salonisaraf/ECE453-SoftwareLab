module toggle_detect_tb();

//Inputs and outputs of DUT
logic clk, reset, switch_n, button_out; //Inputs of iDUT
logic toggle_led; //Output 
//logic [2:0] current_state; //Output
logic [1:0] message;

logic button_in;

//Instantiate DUT
ece453_debounce iDUT_debounce(
  .clk(clk),
  .reset(reset),
  .button_in(button_in),
  .button_out(button_out)
);

//Instantiate DUT
	toggle_detect iDUT(
		.clk(clk),
		.reset(reset),
		.switch_n(switch_n),
		.detect_sw(button_out),
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
  
  localparam message_START = 4'b0000;
  localparam message_ON = 4'b0001;
  localparam message_OFF = 4'b0010;  
  localparam message_ERROR = 4'b0011; 

  localparam SW_UP = 1'b1;
  localparam SW_DOWN = 1'b0;
  localparam TOGGLED = 1'b1;

initial begin
clk = 0;
reset = 1; //Reset is an active high signal
button_in = SW_DOWN;
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
	if(iDUT.current_state != START || toggle_led != LED_OFF || button_out == TOGGLED )begin
		$display("Test 1 failed: Was supposed to be in START state, was in: %h, Message: %h, Message_START: %h", iDUT.current_state, message, message_START);
		$stop();
	end if(message != message_START) begin
		$display("Test 1 failed: Was supposed to be in START state, was in: %h, Message: %h, Message_START: %h", iDUT.current_state, message, message_START);
		$stop();
	end
	else begin
		$display("Test 1 passed!");
	end

//Test state transitions for START state
switch_n = SW_HIGH;
button_in = SW_UP;
#5;
button_in = SW_DOWN;
fork 
    begin: timeout
	repeat (25000000)@(posedge clk); 
	$display("Button out testing: Timed out waiting for button_out"); 
	$stop(); 
    end 
    begin 
	@(posedge button_out) disable timeout;
    end 
  join 
@(posedge clk);
@(posedge clk);
@(negedge clk);
//Check transition out of START state
	if(iDUT.current_state != SW_ON || toggle_led != LED_ON || message != message_ON)begin
		$display("Test 2 failed: Was supposed to be in ON state, was in: %h, Expected Message: %h, button_out %h", iDUT.current_state, message_ON, button_out);
		$stop();	
	end
	else begin
		$display("Test 2 passed!");
	end
	
//Test state transitions for START state
switch_n = SW_LOW;
button_in = SW_DOWN;
#5;
button_in = SW_UP;
fork 
    begin: timeout_1
	repeat (25000000)@(posedge clk); 
	$display("Button out testing: Timed out waiting for button_out"); 
	$stop(); 
    end 
    begin 
	@(posedge button_out) disable timeout_1;
	button_in = SW_DOWN;
    end 
  join 
@(posedge clk);
@(posedge clk);
@(negedge clk);
//Check transition out of START state
	if(iDUT.current_state != SW_OFF || toggle_led != LED_OFF || message != message_OFF)begin
		$display("Test 3 failed: Was supposed to be in OFF state, was in: %h, Expected Message: %h, button_out %h", iDUT.current_state, message_ON, button_out);
		$stop();	
	end
	else begin
		$display("Test 3 passed!");
	end
	
//Test state transitions for START state
switch_n = SW_HIGH;
button_in = SW_UP;
#5;
fork 
    begin: timeout_2
	repeat (25000000)@(posedge clk); 
	$display("Button out testing: Timed out waiting for button_out"); 
	$stop(); 
    end 
    begin 
	@(posedge button_out) disable timeout_2;
	button_in = SW_DOWN;
    end 
  join 
@(posedge clk);
@(posedge clk);
@(negedge clk);
//Check transition out of START state
	if(iDUT.current_state != SW_ON || toggle_led != LED_ON || message != message_ON)begin
		$display("Test 4 failed: Was supposed to be in ON state, was in: %h, Expected Message: %h, button_out %h", iDUT.current_state, message_ON, button_out);
		$stop();	
	end
	else begin
		$display("Test 4 passed!");
	end
	
$display("All tests passed!");
$stop();

end




//Clock
always
#2 clk = ~clk;

endmodule
