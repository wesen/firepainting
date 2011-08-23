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

#if defined(__AVR_ATmega1280__)
#define ARDUINO_MEGA
#else
#define ARDUINO_DUEMILANOVE
#endif

#define IS_ARDUINO_NOZZLE 1


//#############################################################
//for the glove (arduino Nano)
#define CONTROL0 7  //for mux control
#define CONTROL1 6
#define CONTROL2 5
#define CONTROL3 4
//A6 - analog pin for MUX
//A4 and A5 for I2C

int mux_array[16]; // wired to A6 on the nano
int senzor_array[4]; // z to A0, y to A1, x to A2, g to A3
int cutoff_array[4]; // for calibration
boolean calibration_status = false; //for calibration
//int black_button = 2; 
//int red_button = 3; 





// ==========================================================================================
void masterHandleWire() {
   

 getGloveData();  // function for reading the glove sensors
 actuate();       // calculate and exe. function for valves and pumps


}




// ==========================================================================================
void getGloveData(){   // it is inside masterHandleWire
  
 if(calibration_status == false){   // delay before calibration
     delay(3000);
         }
      
 //read MUX 5x flex sensor status
  for (int i=6; i<=10; i++)
  {
    // http://www.arduino.cc/en/Reference/BitwiseAnd
    // http://www.arduino.cc/en/Reference/Bitshift
    digitalWrite(CONTROL0, (i&15)>>3); 
    digitalWrite(CONTROL1, (i&7)>>2);  
    digitalWrite(CONTROL2, (i&3)>>1);  
    digitalWrite(CONTROL3, (i&1));     
      
    //analogReference(DEFAULT);
    mux_array[i] = analogRead(6);
    delay(10);     
  }
  
  
   // flex sensor data (mux_array[i]) becomes the actual PWM value for the pumps:
   // in theory: val = map(val, 0, 1023, 0, 255);
  





  
  // ______ tle sem dal samo prst 2 in prst 3
 /*   
   mux_array[10] = constrain(mux_array[10], 280, 440);       
   mux_array[10] = map(mux_array[10], 440, 180, 0, 255);     // P1  //280
 */   
   mux_array[9]  = constrain(mux_array[9],  160, 330);   
   mux_array[9]  = map(mux_array[9],  330, 60, 0, 255);     // P2   //160
   
   mux_array[8]  = constrain(mux_array[8],  270, 360);   
   mux_array[8]  = map(mux_array[8],  360, 170, 0, 255);     // P3  //270
 /* 
   mux_array[7]  = constrain(mux_array[7],  205, 330);   
   mux_array[7]  = map(mux_array[7],  330, 105, 0, 255);     // P4  //205
 
   mux_array[6]  = constrain(mux_array[6],  310, 438);     
   mux_array[6]  = map(mux_array[6],  438, 310, 0, 255);     // P5   
 */

  
  //read IMU senzor status
  for (int i=0; i<=3; i++)
  {     
    //analogReference(EXTERNAL);  //WARNING!  if changed check if above is DEFAULT
    senzor_array[i] = analogRead(i);
    delay(10); //10
  }
  
  //set all IMU readings to 0 - initial calibration
  if(calibration_status == false){   
     for (int i=0; i<=3; i++){             
          cutoff_array[i] = senzor_array[i];
          calibration_status = true;
         }
     }


  for (int i=0; i<=3; i++){             
          senzor_array[i] = senzor_array[i] - cutoff_array[i] ;
         }







  #ifdef DEBUG
  Serial.print("X = " );                       
  Serial.print(senzor_array[2]);      
  Serial.print("\t");  
   
  Serial.print("Y = " );                       
  Serial.print(senzor_array[1]);      
  Serial.print("\t"); 
  
  Serial.print("Z = " );                       
  Serial.print(senzor_array[0]);      
  Serial.print("\t");   
  
  Serial.print("G = " );                       
  Serial.print(senzor_array[3]);      
  Serial.print("\t");   
  
  Serial.print("\t");  
  Serial.print("\t");  
  
  
  
  Serial.print("P1 = " );                       
  Serial.print(mux_array[10]);  
  Serial.print("\t"); 
  
  Serial.print("P2 = " );                       
  Serial.print(mux_array[9]);  
  Serial.print("\t");   

  Serial.print("P3 = " );                       
  Serial.print(mux_array[8]);  
  Serial.print("\t");   
  
  Serial.print("P4 = " );                       
  Serial.print(mux_array[7]);  
  Serial.print("\t");   
   
  Serial.print("P5 = " );                       
  Serial.print(mux_array[6]);  
  Serial.print("\t");   
                          
  Serial.println();  
  #endif

 }

// ==========================================================================================
void actuate(){     // it is inside masterHandleWire
   // it is done like this: 
  //   for pumps: setPump(id,nozzle,value) 
  //   for analog read: setPump(1, 0, analogRead(0) >> 2);  
  //   for valves openValve(id,nozzle) or closeValve(id,nozzle)
  // the inbetween delays are inside the functions
   
  // tamala elektronika za portland ima id1   (pin 2 to GND)
   
   
   
 //################################################################################ palm facing down   
 if(senzor_array[1] <= 40){ // hand rotation (around Y axis)
 

// set the pump values   (požene pumpe)
          
      setPump(1, 11, mux_array[9] );    // P2
      //delay(10);
   
        
      setPump(1, 10, mux_array[8] );   // P3
      //delay(10);
      


// ************************************************************ only one line for Portland
     if(senzor_array[2] < 5){   
              
              openValve(1,9);
              openValve(1,8);
        }


  // ************************************************************ lower limit - bellow all valves are closed      
      if(senzor_array[2] > 5){   //19
        
            closeValve(1,9);
            closeValve(1,8);
      }





 //################################################################################ palm facing up  
  if(senzor_array[1] > 40){ // hand rotation (around Y axis)     
      
    // set the pump values (opposite finger direction)

     
     
      setPump(1, 11, mux_array[8] );   // P3 na pixlu 1
      //delay(10);
   
        
      setPump(1, 10, mux_array[9] );   // P2 na pixlu 2
      //delay(10);
     

      }
  
    
         
    
     // ************************************************************ palm facing up - all valves are opened      
      if(senzor_array[2] < 30){  // lower limit = bellow all valves are closed 
       
       
              openValve(1,9);
              openValve(1,8);
       
       
       
            }
      }
    
    
 
     
 






/* tko je bilo original
 // set the pump values  (požene pumpe)
    for (int i=0; i <= 3; i++){              // P1 on collumn one
      setPump(2, i, mux_array[10] );
      //delay(10);
      }
  
    for (int i=4; i <= 7; i++){              // P2 on collumn two
      setPump(2, i, mux_array[9] );
      //delay(10);
      } 
 
    for (int i=0; i <= 3; i++){              // P3 on collumn three
      setPump(1, i, mux_array[8] );
      //delay(10);
      } 
 
    for (int i=4; i <= 7; i++){              // P4 on collumn four
      setPump(1, i, mux_array[7] );
      //delay(10);
      }     
 





 
     // ************************************************************ line 1
     if(senzor_array[2] < -11){   
        for (int i=1; i <= 7; i=i+2){     //line 1 (1 to 4)
            openValve(1,i);
            }
        for (int i=9; i <= 15; i=i+2){    //line 2 (5 to 8)
            closeValve(1,i); 
            }
        for (int i=1; i <= 7; i=i+2){     //line 3 (9 to 12)
            closeValve(2,i); 
            }
        for (int i=9; i <= 15; i=i+2){    //line 4 (13 to 16)
            closeValve(2,i); 
            }
        }
        
        
     // ************************************************************ transition 1 to 2         
     if((senzor_array[2] > -11) && (senzor_array[2] < -9)){   
        for (int i=1; i <= 7; i=i+2){     //line 1 (1 to 4)
            openValve(1,i);
            }
        for (int i=9; i <= 15; i=i+2){    //line 2 (5 to 8)
            openValve(1,i); 
            }
        for (int i=1; i <= 7; i=i+2){     //line 3 (9 to 12)
            closeValve(2,i); 
            }
        for (int i=9; i <= 15; i=i+2){    //line 4 (13 to 16)
            closeValve(2,i); 
            }
       }    
        
              
         
     // ************************************************************ line 2         
     if((senzor_array[2] > -9) && (senzor_array[2] < -1)){   
        for (int i=1; i <= 7; i=i+2){     //line 1 (1 to 4)
            closeValve(1,i);
            }
        for (int i=9; i <= 15; i=i+2){    //line 2 (5 to 8)
            openValve(1,i); 
            }
        for (int i=1; i <= 7; i=i+2){     //line 3 (9 to 12)
            closeValve(2,i); 
            }
        for (int i=9; i <= 15; i=i+2){    //line 4 (13 to 16)
            closeValve(2,i); 
            }
       }   
      
     // ************************************************************ transition 2 to 3         
     if((senzor_array[2] > -1) && (senzor_array[2] < 1)){   
        for (int i=1; i <= 7; i=i+2){     //line 1 (1 to 4)
            closeValve(1,i);
            }
        for (int i=9; i <= 15; i=i+2){    //line 2 (5 to 8)
            openValve(1,i); 
            }
        for (int i=1; i <= 7; i=i+2){     //line 3 (9 to 12)
            openValve(2,i); 
            }
        for (int i=9; i <= 15; i=i+2){    //line 4 (13 to 16)
            closeValve(2,i); 
            }
       } 
         
     // ************************************************************ line 3         
     if((senzor_array[2] > 1) && (senzor_array[2] < 9)){   
        for (int i=1; i <= 7; i=i+2){     //line 1 (1 to 4)
            closeValve(1,i);
            }
        for (int i=9; i <= 15; i=i+2){    //line 2 (5 to 8)
            closeValve(1,i); 
            }
        for (int i=1; i <= 7; i=i+2){     //line 3 (9 to 12)
            openValve(2,i); 
            }
        for (int i=9; i <= 15; i=i+2){    //line 4 (13 to 16)
            closeValve(2,i); 
            }
       }  
       
     // ************************************************************ transition 3 to 4         
     if((senzor_array[2] > 9) && (senzor_array[2] < 11)){   
        for (int i=1; i <= 7; i=i+2){     //line 1 (1 to 4)
            closeValve(1,i);
            }
        for (int i=9; i <= 15; i=i+2){    //line 2 (5 to 8)
            closeValve(1,i); 
            }
        for (int i=1; i <= 7; i=i+2){     //line 3 (9 to 12)
            openValve(2,i); 
            }
        for (int i=9; i <= 15; i=i+2){    //line 4 (13 to 16)
            openValve(2,i); 
            }
       }  
      
     // ************************************************************ line 4           
     if(senzor_array[2] > 11 && (senzor_array[2] < 19)){   
        for (int i=1; i <= 7; i=i+2){     //line 1 (1 to 4)
            closeValve(1,i);
            }
        for (int i=9; i <= 15; i=i+2){    //line 2 (5 to 8)
            closeValve(1,i); 
            }
        for (int i=1; i <= 7; i=i+2){     //line 3 (9 to 12)
            closeValve(2,i); 
            }
        for (int i=9; i <= 15; i=i+2){    //line 4 (13 to 16)
            openValve(2,i); 
            }
        }      
     
     // ************************************************************ lower limit - bellow all valves are closed      
      if(senzor_array[2] > 19){   
        for (int i=1; i <= 7; i=i+2){     //line 1 (1 to 4)
            closeValve(1,i);
            }
        for (int i=9; i <= 15; i=i+2){    //line 2 (5 to 8)
            closeValve(1,i); 
            }
        for (int i=1; i <= 7; i=i+2){     //line 3 (9 to 12)
            closeValve(2,i); 
            }
        for (int i=9; i <= 15; i=i+2){    //line 4 (13 to 16)
            closeValve(2,i); 
            }
      }
      
 }  
  
  
    
      
  //################################################################################ palm facing up  
  if(senzor_array[1] > 40){ // hand rotation (around Y axis)     
      
    // set the pump values (opposite finger direction)
    for (int i=0; i <= 3; i++){              // P4 on collumn one
      setPump(2, i, mux_array[7] );
      //delay(10);
      }
  
    for (int i=4; i <= 7; i++){              // P3 on collumn two
      setPump(2, i, mux_array[8] );
      //delay(10);
      } 
 
    for (int i=0; i <= 3; i++){              // P2 on collumn three
      setPump(1, i, mux_array[9] );
      //delay(10);
      } 
 
    for (int i=4; i <= 7; i++){              // P1 on collumn four
      setPump(1, i, mux_array[10] );
      //delay(10);
      }  
         
    
     // ************************************************************ palm facing up - all valves are opened      
      if(senzor_array[2] < 30){  // lower limit = bellow all valves are closed
        for (int i=1; i <= 7; i=i+2){     //line 1 (1 to 4)
            openValve(1,i);
            }
        for (int i=9; i <= 15; i=i+2){    //line 2 (5 to 8)
            openValve(1,i); 
            }
        for (int i=1; i <= 7; i=i+2){     //line 3 (9 to 12)
            openValve(2,i); 
            }
        for (int i=9; i <= 15; i=i+2){    //line 4 (13 to 16)
            openValve(2,i); 
            }
      }
    
     } 
 
     

 
 
  */ 
 
 
}
 














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





#if IS_ARDUINO_NOZZLE
char idString[] = "nozleX";
#else
char idString[] = "gloveX";
#endif

#define CMD_VALVE 1
#define CMD_PUMP  2

void handleWire() {
  if (isMaster()) {
    masterHandleWire();
  }
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
  uint8_t msg[3] = { 
    0, 1, 2       };
  if (!isMaster()) {
    Wire.send(msg, 3);
  }
}

void openValve(uint8_t id, uint8_t nozzle) {
  Wire.beginTransmission(id);
  uint8_t msg[3] = { 
    CMD_VALVE, nozzle, 1     };
  Wire.send(msg, 3);
  Wire.endTransmission();
     //delay(10); //10
      delayMicroseconds(1500);
}

void closeValve(uint8_t id, uint8_t nozzle) {
  Wire.beginTransmission(id);
  uint8_t msg[3] = { 
    CMD_VALVE, nozzle, 0     };
  Wire.send(msg, 3);
  Wire.endTransmission();
      //delay(10); // 10
      delayMicroseconds(1500);
}

void setPump(uint8_t id, uint8_t nozzle, uint8_t value) {
  Wire.beginTransmission(id);
  uint8_t msg[3] = { 
    CMD_PUMP, nozzle, value     };
  Wire.send(msg, 3);
  Wire.endTransmission();
      //delay(10);
      delayMicroseconds(1500);
}

void setup() {
  Serial.begin(115200);
  setupWire();
  
 
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

  
//#################################################
// for the glove
  pinMode(CONTROL0, OUTPUT);
  pinMode(CONTROL1, OUTPUT);
  pinMode(CONTROL2, OUTPUT);
  pinMode(CONTROL3, OUTPUT);
  //pinMode(black_button, INPUT);
  //pinMode(red_button, INPUT);
}

void loop() {
  handleWire();

  delay(100);  // modify to increse the speed of the code ?
}




