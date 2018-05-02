float frequency = 100; //the frequency of the cycle
float cycle_length; //how long each pwm cycle should be on for

float duty_cycle; //the percentage of power we want
int time_on; // how long the output should be high
int time_off; //how long the output should be low
int v_out; //the amount of voltage the led should draw
int val = 0;
int pwm_pin = 0; // pin that will act like a pwm pin
int in1_pin = 4;
int in2_pin = 3;

int in1 = 0;
int in2 = 0;

void setup() {

pinMode(pwm_pin, OUTPUT);
digitalWrite(pwm_pin, LOW);

pinMode(in1_pin, INPUT);
pinMode(in2_pin, INPUT);

//calculate the length of the cycle
cycle_length = 1000000/frequency; //length of one pwm cycle in microseconds
v_out = 0;

}

void loop() {


/*val = (val + 1) % 1024;

if      ( val < (1*1024)/3 )  { duty_cycle = (float) 1/3; }
else if ( val < (2*1024)/3 )  { duty_cycle = (float) 2/3; }
else                          { duty_cycle = (float) 3/3; }
*/

in1 = digitalRead(in1_pin);
in2 = digitalRead(in2_pin);

if      ( in1 == HIGH && in2 == HIGH )  { duty_cycle = (float) 1; }
else if ( in1 == LOW && in2 == HIGH )  { duty_cycle = (float) 2/3; }
else if ( in1 == HIGH && in2 == LOW  ) { duty_cycle = (float) 1/4; }
else                              { duty_cycle = (float) 0; }

//if (in1 == HIGH) { duty_cycle = (float) 1; }
//else             { duty_cycle = (float) 0; }

time_on = duty_cycle * cycle_length; // work out the time it should be on
time_off = cycle_length-time_on; // work out the time it should be off

if(time_on > 0)
{
  digitalWrite(pwm_pin, HIGH);
  delayMicroseconds(time_on); // turns led on for short anount of time
}

digitalWrite(pwm_pin, LOW);
delayMicroseconds(time_off);

}
