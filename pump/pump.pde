/*
 * Firepainting arduino code
 *
 * http://vimeo.com/21213264
 *
 * (c) 2010 - 2011
 *
 * Author: Manuel Odendahl - wesen@ruinwesen.com
 * Author: Andrej Primozic
 * Author: Sanela Jahic
 */

#include <Wire.h>

// 21082011 Portland, Oregon, Appendix project space
// pin 2 na Duemillanove vezati na GND = Slave id1

// setup:
// - connect arduino Nano (master) to 2 arduino Mega slaves
// - configure ID of slaves by grounding pin 22, 23, 24
// - master without ID pin
// - ID:1 22 -> GND
// - ID:2 23 -> GND

// nozzles and pumps are counted from 0 to ....


// modify code:
// - on the master commands are sent in masterHandleWire()
//                         setPump(id,nozzle,value);
// - on the slave, pumps are controlled by slaveSetPump()
// - on the slave, valves are controlled by slaveSetValve()

// comment this line to remove debug code by using "//"
// remove debug to increse the speed of the code

#define DEBUG 1

uint8_t id = 1; //0

#define IS_ARDUINO_NOZZLE 1

//A6 - analog pin for MUX
//A4 and A5 for I2C


// ==========================================================================================
void slaveSetValve(uint8_t valve, uint8_t state) {
  #ifdef DEBUG
  Serial.print("VALVE ");
  Serial.print(valve, DEC);
  if (state) {
    Serial.println(" OPEN");
  }
  else {
    Serial.println(" CLOSE");
  }
  #endif

   // control valve here
   // digitalWrite(  valve, state ? HIGH : LOW); //
   // digitalWrite( 24 + valve, state ? HIGH : LOW); // tko je bilo original za Mega slaves
    digitalWrite( valve, state ? HIGH : LOW); // za tamalo elektroniko za Portland
}

// ==========================================================================================
void slaveSetPump(uint8_t pump, uint8_t value) {
  #ifdef DEBUG
  Serial.print("PUMP ");
  Serial.print(pump, DEC);
  Serial.print(" TO ");
  Serial.println(value, DEC);
  #endif

  // set PWM value for pump
  // analogWrite( 2 + pump, value); //2+ because of rxtx pins) // original za Mega slaves
  analogWrite( pump, value); //2+ because of rxtx pins) // tamala elektronka za Potrland
  // delay (10); // NO DELAY - it is inside interupt
}





char idString[] = "nozleX";

#define CMD_VALVE 1
#define CMD_PUMP  2

void handleWire() {
}


void handleMsg(uint8_t *msg, uint8_t cnt) {
  if (!isMaster()) {
    switch (msg[0]) {
    case CMD_VALVE:
      slaveSetValve(msg[1], msg[2]);
      break;

    case CMD_PUMP:
      slaveSetPump(msg[1], msg[2]);
      break;
    }
  }
  else {
    Serial.println("handleMsg");
  }
}

void onRequestHandler() {
  Serial.println("on request");
  uint8_t msg[3] = {
    0, 1, 2       };
  if (!isMaster()) {
    Wire.send(msg, 3);
  }
}

void setup() {
  Serial.begin(115200);
  setupWire();
  
  if (isMaster()) {
    Serial.println("pump should be slave!!");
  }


/*  za Mega Slave
  pinMode(25, OUTPUT);
  pinMode(27, OUTPUT);
  pinMode(29, OUTPUT);
  pinMode(31, OUTPUT);
  pinMode(33, OUTPUT);
  pinMode(35, OUTPUT);
  pinMode(37, OUTPUT);
  pinMode(39, OUTPUT);
  pinMode(41, OUTPUT);
*/

// to je za tamalo elektroniko za Portland (triac valves)
  pinMode(9, OUTPUT);
  pinMode(8, OUTPUT);

/*  Tako je mapirano na tamali elektronki za Portand
 pumpa_1 = 11;
 pumpa_2 = 10;
 valve_1 = 9;
 valve_2 = 8;
*/
}

void loop() {
  // nothing to do here
  
  delay(100);  // modify to increse the speed of the code ?
}
