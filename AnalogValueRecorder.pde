import processing.serial.*;
import cc.arduino.*;
Arduino arduino;

int[][] data;
boolean isError = false;
boolean isRecording = false;

/* --- Properties start --- */

String serialPort = ""; //Arduino serial port.
String fontFile = "CourierNewPSMT-48.vlw"; //Font file name.
int[] pins = {}; //Enter the pin number to record the analog input. The maximum number is 8.

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
	size(600, 600);
	textFont(loadFont(fontFile));
}

void draw() {
	if(isError) exit();
	background(120);
	textSize(30);
	fill(255);
	for(int i = 0; i < pins.length; i++) text("Analog" + i + " (" + pins[i] + ") = " + arduino.analogRead(pins[i]), 15, 30 * (i + 1));
}