#include <Wire.h>


#ifdef ARDUINO_MEGA
#define ID_PIN1 22
#define ID_PIN2 23
#define ID_PIN3 24
#else
#define ID_PIN1 2
#define ID_PIN2 3
#define ID_PIN3 4
#endif

bool isMaster() {
  return (id == 0);
}

uint8_t readId() {
  id = 0;

  for (uint8_t i = 0; i <= 2; i++) {
    pinMode(i + ID_PIN1, INPUT);
    digitalWrite(i + ID_PIN1, HIGH);
    if (!digitalRead(i + ID_PIN1)) {
      id |= (1 << i);
    }
  }

  return id;
}

void printBuf(uint8_t *msg, uint8_t cnt) {
  Serial.print("received ");
  for (uint8_t i = 0; i < cnt; i++) {
    Serial.print(msg[i], HEX);
    Serial.print(" ");
    if ((i % 16) == 15) {
      Serial.println();
    }
  }
  Serial.println();
}


void onReceiveHandler(int foo) {
  uint8_t msg[3];
  uint8_t idx = 0;

  while (idx < sizeof(msg)) {
    if (Wire.available()) {
      msg[idx] = Wire.receive();
      idx++;
    }
  }

  handleMsg(msg, 3);
}

void setupWire() {
  if (!IS_ARDUINO_NOZZLE) {
    id = 0;
  } else {
    id = 1;
  }
  idString[sizeof(idString) - 1] = id + '0';

  if (isMaster()) {
    Wire.begin();
  } 
  else {
    Wire.begin(id);
  }

  Wire.onReceive(onReceiveHandler);
  Wire.onRequest(onRequestHandler);

  if (IS_ARDUINO_NOZZLE) {
    Serial.println("Nozzle");
  } else {
    Serial.println("Glove");
  }
  
  Serial.print("ID: ");
  Serial.println(idString);
  if (isMaster()) {
    Serial.println("master");
  } else {
    Serial.println("slave");
  }
  
  /* wait for slave to come up */
  if (isMaster()) {
    delay(500);
  }
}


