module ece453_debounce_tb();

logic clk;
logic reset;
logic button_in;
logic button_out;

//Instantiate DUT
ece453_debounce iDUT(
  .clk(clk),
  .reset(reset),
  .button_in(button_in),
  .button_out(button_out)
);

localparam SW_UP = 1'b1;
localparam SW_DOWN = 1'b0;
localparam TOGGLED = 1'b1;

initial begin
clk = 0;
reset = 1; //Reset is an active high signal
button_in = SW_DOWN;
//Wait for sometime before changing inputs
@(posedge clk);
@(posedge clk);
@(negedge clk);

//Deassert reset
reset = 0;

button_in = SW_UP;
#5;
button_in = SW_DOWN;
//Wait for sometime before changing inputs
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


if(iDUT.button_out != TOGGLED)begin
	$display("Should have detected toggle on switch on, but did not! Expected: %h, Received: %h", TOGGLED, iDUT.button_out);
	$stop();
end
else begin
	$display("Test 1 passed!");
end


#5;
button_in = SW_UP;
//Wait for sometime before changing inputs
fork 
    begin: timeout_1
	repeat (25000000)@(posedge clk); 
	$display("Button out testing: Timed out waiting for button_out"); 
	$stop(); 
    end 
    begin 
	@(posedge button_out) disable timeout_1;
    end 
  join 

if(iDUT.button_out != TOGGLED)begin
	$display("Should have detected toggle on switch off, but did not! Expected: %h, Received: %h", TOGGLED, iDUT.button_out);
	$stop();
end
else begin
	$display("Test 2 passed!");
end
button_in = SW_DOWN;
repeat(50000)begin
@(posedge clk);
end

$display("All tests passed!");
$stop();
end

//Clock
always
#2 clk = ~clk;

endmodule
