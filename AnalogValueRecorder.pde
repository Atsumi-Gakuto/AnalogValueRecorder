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
int[] pins = {0, 1, 2}; //Enter the pin number to record the analog input. The maximum number is 8.

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
	int[] readData = new int[0];
	for(int i = 0; i < pins.length; i++) {
		int input = arduino.analogRead(pins[i]);
		readData = append(readData, input);
		text("Analog" + i + "(" + pins[i] + ") = " + input, 15, 30 * (i + 1));
	}

	//draw messages
	fill(255);
	textSize(30);
	if(isRecording) {
		//Record process
		steps++;
		for(int i = 0; i < pins.length; i++) data[i] = append(data[i], readData[i]);

		//draw
		text("Recording...", 60, 330);
		text("Press Space key to end recording and save data.", 60, 380);
		if(second() % 2 == 1) {
			noStroke();
			fill(255, 0, 0);
			circle(40, 321, 20);
			fill(255);
    	}
	}
	else {
		text("Press Space key to record.", 60, 330);
		text("Press Esc key to exit.", 60, 380);
	}
	text("Steps: " + steps + " (" + nf(floor(floor(steps / 30) / 60), 2) + ":" + nf(floor(steps / 30) % 60, 2) + ")", 60, 430);

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
		
		//draw line
		stroke(colors[i][0], colors[i][1], colors[i][2]);
		for(int j = steps; j > max(2, steps -300); j--) line(900 - (steps - j) * 1.53, 10 + 230 * ((float)(1024 - min(max(data[i][j - 1], 0), 1023)) / (float)1024), 900 - (steps - (j - 1)) * 1.53, 10 + 230 * ((float)(1024 - min(max(data[i][j - 2], 0), 1023)) / (float)1024));
	}
	stroke(255);
	fill(255);
	for(int i = steps; i > steps - 300; i -= 150) {
		if(i >= 0) {
			float lineX = 900 - 460 * ((float)(steps - (i - i % 150)) / (float)300);
			line(lineX, 10, lineX, 270);
			text(i - i % 150, lineX + 10, 270);
		}
	}
}

void keyPressed() {
	if(keyCode == 32) {
		if(isRecording) {
			isRecording = false;

			//Export to csv file.
			String[] lines = new String[steps + 1];
			lines[0] = "Steps,";
			for(int i = 0; i < pins.length; i++) lines[0] += "Analog" + i + ",";
			lines[0] = lines[0].substring(0, lines[0].length() - 1);
			for(int i = 0; i < steps; i++) {
				lines[i + 1] = i + ",";
				for(int j = 0; j < pins.length; j++) lines[i + 1] += data[j][i] + ",";
				lines[i + 1] = lines[i + 1].substring(0, lines[i + 1].length() - 1);
			}
			saveStrings("Rec_" + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".csv", lines);
		}
		else {
			data = new int[pins.length][];
			for(int i = 0; i < data.length; i++) data[i] = new int[0];
			steps = 0;
			isRecording = true;
		}
	}
}