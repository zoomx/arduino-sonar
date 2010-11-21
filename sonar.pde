#include <Servo.h>
#define PING_PIN     2
#define SERVO_PIN   12
#define SERVO_DELAY  5

int x = 0;
int y = 0;
Servo myservo;  

void setup() 
{  
  lcd_init();
  myservo.attach(SERVO_PIN);  
  myservo.write(0);
  delay(1000);
} 

void loop() 
{
  cls();
  scan();
}   

float ping()
{
  unsigned long time;
  
  pinMode(PING_PIN, OUTPUT);
  
  digitalWrite(PING_PIN, LOW);
  delayMicroseconds(2); 
  
  digitalWrite(PING_PIN, HIGH);
  delayMicroseconds(5);
  
  digitalWrite(PING_PIN, LOW);
  
  pinMode(PING_PIN, INPUT);
  while (digitalRead(PING_PIN) == LOW);
  time = micros();

  while (digitalRead(PING_PIN) == HIGH);
  time = micros() - time;
 
  return ((float)time / 1050); 
}


void scan()
{
  int s = 1;
  
  if(x == 180){ 
    s = -1;
  }
  
  while ((x += s) != 0 && x < 180) {
    myservo.write(x);
    delay(SERVO_DELAY);
    
    y = int(ping() * 128);    
   
    for (int i=y; i < 128; i++) {
      lcd_put_pixel((x / 180.0f) * 128, i, 0xFFFFFF); 
    }
  }
  
}
