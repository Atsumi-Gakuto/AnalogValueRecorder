import processing.serial.*;
import cc.arduino.*;
Arduino arduino;

int[][] colors = {{255, 0, 0}, {0, 255, 0}, {0, 0, 255}, {255, 255, 0}, {255, 0, 255}, {0, 255, 255}, {255, 255, 255}, {0, 0, 0}};
int[][] data;
int steps = 0;
boolean isError = false;
boolean isRecording = false;

/* --- Properties start --- */

String serialPort = "COM3"; //Arduino serial port.
String fontFile = "CourierNewPSMT-48.vlw"; //Font file name.
int[] pins = {0, 1, 2, 3, 4, 5, 6, 7}; //Enter the pin number to record the analog input. The maximum number is 8.

/* --- Properties end --- */

void setup() {
	if (serialPort == "") {
		println("Error: \"serialPort\" is not specified.");
		isError = true;
		return;
	}
	if(pins.length > 8) {
		println("Warning: The number of pins specified is greater than 8. 9th and subsequent pin inputs are ignored.");
		int[] pinsTemp = pins;
		pins = new int[8];
		for(int i = 0; i < 8; i++) pins[i] = pinsTemp[i];
	}
	data = new int[pins.length][];
	try {
		arduino = new Arduino(this, serialPort, 57600);
	}
	catch(Exception exception) {
		println("Error: An error occurred while connecting to Arduino.");
		isError = true;
		return;
	}
	frameRate(30);
	size(1005, 470);
	textFont(loadFont(fontFile));
}

void draw() {
	if(isError) exit(); //Exits if any errors occured in setup();

	//draw analog values
	background(120);
	textSize(30);
	fill(255);
	for(int i = 0; i < pins.length; i++) text("Analog" + i + "(" + pins[i] + ") = " + arduino.analogRead(pins[i]), 15, 30 * (i + 1));

	//draw line graph
	noFill();
	stroke(255);
	rect(440, 10, 460, 230);
	line(440, 120, 900, 120);
	textSize(15);
	text("1023", 395, 20);
	text("512", 405, 126);
	text("0", 423, 240);
	for(int i = 0; i < pins.length; i++) {
		noStroke();
		fill(colors[i][0], colors[i][1], colors[i][2]);
		rect(910, i * 25 + 30, 15, 5);
		fill(255);
		text("Analog" + i, 930, i * 25 + 37);
	}

	//draw messages
	fill(255);
	textSize(30);
	if(isRecording) {
		text("Recording", 60, 330);
		text("Press any key to end recording and save data.", 60, 380);
		if(second() % 2 == 1) {
			fill(255, 0, 0);
			ellipse(40, 341, 20, 20);
			fill(255);
    	}
	}
	else {
		text("Press any key to record.", 60, 330);
		text("Press esc key to exit.", 60, 380);
	}
	text("Steps: " + steps + " (" + nf(floor(steps / 180), 2) + ":" + nf(floor(steps / 30) % 60, 2) + ")", 60, 430);
}

void keyPressed() {
	if(isRecording) isRecording = false;
	else isRecording = true;
}