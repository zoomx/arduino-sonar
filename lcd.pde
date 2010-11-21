/* mbed Library - MobileLCD - test for MOD-NOKIA6610 (Epson 15G00) 
 * Copyright (c) 2007/8, sford 
 */ 
// Define Software SPI Pin Signal
#define CS   3          // Digital 3 --> #CS
#define CLK   4         // Digital 4 --> SCLK
#define SDA   5         // Digital 5 --> SDATA
#define RESET 6         // Digital 6 --> #RESET

// Epson S1D15G10 Command Set 
#define DISON       0xaf
#define DISOFF      0xae
#define DISNOR      0xa6
#define DISINV      0xa7
#define COMSCN      0xbb
#define DISCTL      0xca
#define SLPIN       0x95
#define SLPOUT      0x94
#define PASET       0x75
#define CASET       0x15
#define DATCTL      0xbc
#define RGBSET8     0xce
#define RAMWR       0x5c
#define RAMRD       0x5d
#define PTLIN       0xa8
#define PTLOUT      0xa9
#define RMWIN       0xe0
#define RMWOUT      0xee
#define ASCSET      0xaa
#define SCSTART     0xab
#define OSCON       0xd1
#define OSCOFF      0xd2
#define PWRCTR      0x20
#define VOLCTR      0x81
#define VOLUP       0xd6
#define VOLDOWN     0xd7
#define TMPGRD      0x82
#define EPCTIN      0xcd
#define EPCOUT      0xcc
#define EPMWR       0xfc
#define EPMRD       0xfd
#define EPSRRD1     0x7c
#define EPSRRD2     0x7d
#define NOP         0x25

#define cbi(reg, bit) (reg&=~(1<<bit))
#define sbi(reg, bit) (reg|= (1<<bit))

#define CS0 cbi(PORTD,CS);
#define CS1 sbi(PORTD,CS);
#define CLK0 cbi(PORTD,CLK);
#define CLK1 sbi(PORTD,CLK);
#define SDA0 cbi(PORTD,SDA);
#define SDA1 sbi(PORTD,SDA);
#define RESET0 cbi(PORTD,RESET);
#define RESET1 sbi(PORTD,RESET);
       
int _width;
int _height;
int _columns;
int _rows;
int  _row; 
int _column;
long _foreground;
long _background;

const unsigned char FONT8x8[97][8] = { 
  0x08,0x08,0x08,0x00,0x00,0x00,0x00,0x00, // columns, rows, num_bytes_per_char 
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, // space 0x20 
  0x30,0x78,0x78,0x30,0x30,0x00,0x30,0x00, // ! 
  0x6C,0x6C,0x6C,0x00,0x00,0x00,0x00,0x00, // " 
  0x6C,0x6C,0xFE,0x6C,0xFE,0x6C,0x6C,0x00, // # 
  0x18,0x3E,0x60,0x3C,0x06,0x7C,0x18,0x00, // $ 
  0x00,0x63,0x66,0x0C,0x18,0x33,0x63,0x00, // % 
  0x1C,0x36,0x1C,0x3B,0x6E,0x66,0x3B,0x00, // & 
  0x30,0x30,0x60,0x00,0x00,0x00,0x00,0x00, // ' 
  0x0C,0x18,0x30,0x30,0x30,0x18,0x0C,0x00, // ( 
  0x30,0x18,0x0C,0x0C,0x0C,0x18,0x30,0x00, // ) 
  0x00,0x66,0x3C,0xFF,0x3C,0x66,0x00,0x00, // * 
  0x00,0x30,0x30,0xFC,0x30,0x30,0x00,0x00, // + 
  0x00,0x00,0x00,0x00,0x00,0x18,0x18,0x30, // , 
  0x00,0x00,0x00,0x7E,0x00,0x00,0x00,0x00, // - 
  0x00,0x00,0x00,0x00,0x00,0x18,0x18,0x00, // . 
  0x03,0x06,0x0C,0x18,0x30,0x60,0x40,0x00, // / (forward slash) 
  0x3E,0x63,0x63,0x6B,0x63,0x63,0x3E,0x00, // 0 0x30 
  0x18,0x38,0x58,0x18,0x18,0x18,0x7E,0x00, // 1 
  0x3C,0x66,0x06,0x1C,0x30,0x66,0x7E,0x00, // 2 
  0x3C,0x66,0x06,0x1C,0x06,0x66,0x3C,0x00, // 3 
  0x0E,0x1E,0x36,0x66,0x7F,0x06,0x0F,0x00, // 4 
  0x7E,0x60,0x7C,0x06,0x06,0x66,0x3C,0x00, // 5 
  0x1C,0x30,0x60,0x7C,0x66,0x66,0x3C,0x00, // 6 
  0x7E,0x66,0x06,0x0C,0x18,0x18,0x18,0x00, // 7 
  0x3C,0x66,0x66,0x3C,0x66,0x66,0x3C,0x00, // 8 
  0x3C,0x66,0x66,0x3E,0x06,0x0C,0x38,0x00, // 9 
  0x00,0x18,0x18,0x00,0x00,0x18,0x18,0x00, // : 
  0x00,0x18,0x18,0x00,0x00,0x18,0x18,0x30, // ; 
  0x0C,0x18,0x30,0x60,0x30,0x18,0x0C,0x00, // < 
  0x00,0x00,0x7E,0x00,0x00,0x7E,0x00,0x00, // = 
  0x30,0x18,0x0C,0x06,0x0C,0x18,0x30,0x00, // > 
  0x3C,0x66,0x06,0x0C,0x18,0x00,0x18,0x00, // ? 
  0x3E,0x63,0x6F,0x69,0x6F,0x60,0x3E,0x00, // @ 0x40 
  0x18,0x3C,0x66,0x66,0x7E,0x66,0x66,0x00, // A 
  0x7E,0x33,0x33,0x3E,0x33,0x33,0x7E,0x00, // B 
  0x1E,0x33,0x60,0x60,0x60,0x33,0x1E,0x00, // C 
  0x7C,0x36,0x33,0x33,0x33,0x36,0x7C,0x00, // D 
  0x7F,0x31,0x34,0x3C,0x34,0x31,0x7F,0x00, // E 
  0x7F,0x31,0x34,0x3C,0x34,0x30,0x78,0x00, // F 
  0x1E,0x33,0x60,0x60,0x67,0x33,0x1F,0x00, // G 
  0x66,0x66,0x66,0x7E,0x66,0x66,0x66,0x00, // H 
  0x3C,0x18,0x18,0x18,0x18,0x18,0x3C,0x00, // I 
  0x0F,0x06,0x06,0x06,0x66,0x66,0x3C,0x00, // J 
  0x73,0x33,0x36,0x3C,0x36,0x33,0x73,0x00, // K 
  0x78,0x30,0x30,0x30,0x31,0x33,0x7F,0x00, // L 
  0x63,0x77,0x7F,0x7F,0x6B,0x63,0x63,0x00, // M 
  0x63,0x73,0x7B,0x6F,0x67,0x63,0x63,0x00, // N 
  0x3E,0x63,0x63,0x63,0x63,0x63,0x3E,0x00, // O 
  0x7E,0x33,0x33,0x3E,0x30,0x30,0x78,0x00, // P 0x50 
  0x3C,0x66,0x66,0x66,0x6E,0x3C,0x0E,0x00, // Q 
  0x7E,0x33,0x33,0x3E,0x36,0x33,0x73,0x00, // R 
  0x3C,0x66,0x30,0x18,0x0C,0x66,0x3C,0x00, // S 
  0x7E,0x5A,0x18,0x18,0x18,0x18,0x3C,0x00, // T 
  0x66,0x66,0x66,0x66,0x66,0x66,0x7E,0x00, // U 
  0x66,0x66,0x66,0x66,0x66,0x3C,0x18,0x00, // V 
  0x63,0x63,0x63,0x6B,0x7F,0x77,0x63,0x00, // W 
  0x63,0x63,0x36,0x1C,0x1C,0x36,0x63,0x00, // X 
  0x66,0x66,0x66,0x3C,0x18,0x18,0x3C,0x00, // Y 
  0x7F,0x63,0x46,0x0C,0x19,0x33,0x7F,0x00, // Z 
  0x3C,0x30,0x30,0x30,0x30,0x30,0x3C,0x00, // [ 
  0x60,0x30,0x18,0x0C,0x06,0x03,0x01,0x00, // \ (back slash) 
  0x3C,0x0C,0x0C,0x0C,0x0C,0x0C,0x3C,0x00, // ] 
  0x08,0x1C,0x36,0x63,0x00,0x00,0x00,0x00, // ^ 
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xFF, // _ 
  0x18,0x18,0x0C,0x00,0x00,0x00,0x00,0x00, // ` 0x60 
  0x00,0x00,0x3C,0x06,0x3E,0x66,0x3B,0x00, // a 
  0x70,0x30,0x3E,0x33,0x33,0x33,0x6E,0x00, // b 
  0x00,0x00,0x3C,0x66,0x60,0x66,0x3C,0x00, // c 
  0x0E,0x06,0x3E,0x66,0x66,0x66,0x3B,0x00, // d 
  0x00,0x00,0x3C,0x66,0x7E,0x60,0x3C,0x00, // e 
  0x1C,0x36,0x30,0x78,0x30,0x30,0x78,0x00, // f 
  0x00,0x00,0x3B,0x66,0x66,0x3E,0x06,0x7C, // g 
  0x70,0x30,0x36,0x3B,0x33,0x33,0x73,0x00, // h 
  0x18,0x00,0x38,0x18,0x18,0x18,0x3C,0x00, // i 
  0x06,0x00,0x06,0x06,0x06,0x66,0x66,0x3C, // j 
  0x70,0x30,0x33,0x36,0x3C,0x36,0x73,0x00, // k 
  0x38,0x18,0x18,0x18,0x18,0x18,0x3C,0x00, // l 
  0x00,0x00,0x66,0x7F,0x7F,0x6B,0x63,0x00, // m 
  0x00,0x00,0x7C,0x66,0x66,0x66,0x66,0x00, // n 
  0x00,0x00,0x3C,0x66,0x66,0x66,0x3C,0x00, // o 
  0x00,0x00,0x6E,0x33,0x33,0x3E,0x30,0x78, // p 
  0x00,0x00,0x3B,0x66,0x66,0x3E,0x06,0x0F, // q 
  0x00,0x00,0x6E,0x3B,0x33,0x30,0x78,0x00, // r 
  0x00,0x00,0x3E,0x60,0x3C,0x06,0x7C,0x00, // s 
  0x08,0x18,0x3E,0x18,0x18,0x1A,0x0C,0x00, // t 
  0x00,0x00,0x66,0x66,0x66,0x66,0x3B,0x00, // u 
  0x00,0x00,0x66,0x66,0x66,0x3C,0x18,0x00, // v 
  0x00,0x00,0x63,0x6B,0x7F,0x7F,0x36,0x00, // w 
  0x00,0x00,0x63,0x36,0x1C,0x36,0x63,0x00, // x 
  0x00,0x00,0x66,0x66,0x66,0x3E,0x06,0x7C, // y 
  0x00,0x00,0x7E,0x4C,0x18,0x32,0x7E,0x00, // z 
  0x0E,0x18,0x18,0x70,0x18,0x18,0x0E,0x00, // { 
  0x0C,0x0C,0x0C,0x00,0x0C,0x0C,0x0C,0x00, // | 
  0x70,0x18,0x18,0x0E,0x18,0x18,0x70,0x00, // } 
  0x3B,0x6E,0x00,0x00,0x00,0x00,0x00,0x00, // ~ 
  0x1C,0x36,0x36,0x1C,0x00,0x00,0x00,0x00}; // DEL 

/**************************************/
/*        Shifting SPI bit out        */
/**************************************/
void shiftBits(byte b) 
{
    CLK0
    if ((b&128)!=0) SDA1 else SDA0
    CLK1

    CLK0
    if ((b&64)!=0) SDA1 else SDA0
    CLK1

    CLK0
    if ((b&32)!=0) SDA1 else SDA0
    CLK1

    CLK0
    if ((b&16)!=0) SDA1 else SDA0
    CLK1

    CLK0
    if ((b&8)!=0) SDA1 else SDA0
    CLK1

    CLK0
    if ((b&4)!=0) SDA1 else SDA0
    CLK1

    CLK0
    if ((b&2)!=0) SDA1 else SDA0
    CLK1

    CLK0
    if ((b&1)!=0) SDA1 else SDA0
    CLK1
}

void data(byte data) {
    CLK1
    CS1
    CS0
    
    CLK0
    SDA1                  
    CLK1
    shiftBits(data);
}

void command(byte data) {
    CLK1
    CS1
    CS0

    CLK0
    SDA0
    CLK1
    shiftBits(data);
}

void _select() { 
  CS0;    
} 

void _deselect() { 
  CS1; 
} 

void foreground(int v) { 
  _foreground = v; 
} 

void background(int v) { 
  _background = v; 
} 

void locate(int column, int row) { 
  _row = row; 
  _column = column; 
} 

void newline() { 
  _column = 0; 
  _row++; 
  if(_row >= _rows) { 
    _row = 0; 
  } 
} 

void _window(int x, int y, int width, int height) { 
  int x1, x2, y1, y2; 
  x1 = x + 0; 
  y1 = y + 2; 
  x2 = x1 + width - 1; 
  y2 = y1 + height - 1;        
  command(0x15); // column 
  data(x1);        
  data(x2); 
  command(0x75); // page 
  data(y1);            
  data(y2); 
  command(0x5C); // start write to ram 
} 

void fill(int x, int y, int width, int height, long colour) { 
  _select(); 
  _window(x, y, width, height); 

  int r4 = (colour >> (16 + 4)) & 0xF; 
  int g4 = (colour >> (8 + 4)) & 0xF; 
  int b4 = (colour >> (0 + 4)) & 0xF; 

  int d1 = (r4 << 4) | g4; 
  int d2 = (b4 << 4) | r4; 
  int d3 = (g4 << 4) | b4; 

  for(int i=0; i<(width*height+1)/2; i++) { 
    data(d1); 
    data(d2); 
    data(d3); 
  } 
  _deselect();        
} 

void lcd_put_pixel(int x, int y, long colour) { 
  fill(x, y, 1, 1, colour); 
} 

void bitblit(int x, int y, int width, int height, const char* bitstream) { 
  _select(); 
  _window(x, y, width, height); 
  for(int i=0; i<height*width/2; i++) { 
    int byte1 = (i*2) / 8; 
    int bit1 = (i*2) % 8;    
    long colour1 = ((bitstream[byte1] << bit1) & 0x80) ? _foreground : _background; 
    int byte2 = (i*2+1) / 8; 
    int bit2 = (i*2+1) % 8;    
    long colour2 = ((bitstream[byte2] << bit2) & 0x80) ? _foreground : _background; 

    int r41 = (colour1 >> (16 + 4)) & 0xF; 
    int g41 = (colour1 >> (8 + 4)) & 0xF; 
    int b41 = (colour1 >> (0 + 4)) & 0xF; 

    int r42 = (colour2 >> (16 + 4)) & 0xF; 
    int g42 = (colour2 >> (8 + 4)) & 0xF; 
    int b42 = (colour2 >> (0 + 4)) & 0xF;    
    int d1 = (r41 << 4) | g41; 
    int d2 = (b41 << 4) | r42; 
    int d3 = (g42 << 4) | b42;                
    data(d1); 
    data(d2); 
    data(d3); 
  } 
  _deselect(); 
} 

void cls() { 
  fill(0, 0, 130, 130, _background); 
  _row = 0; 
  _column = 0; 
}    

int _putc(int value) { 
  int x = _column * 8;  // FIXME: Char sizes 
  int y = _row * 8; 
  bitblit(x + 1, y + 1, 8, 8, (char*)&(FONT8x8[value - 0x1F][0])); 

  _column++; 

  if(_column >= _columns) { 
    _row++; 
    _column = 0; 
  } 

  if(_row >= _rows) { 
    _row = 0; 
  }            

  return value; 
} 

void reset() 
{ 
  RESET0;  
  delay(1); 
  
  RESET1;
  delay(1);   
  
  _select();
  command(0xCA); // display control  
  data(0x00); 
  data(32); 
  data(0);
  data(0x00); 

  command(0xBB);  // scan 
  data(0x01); 

  command(0xD1); // oscillator on 
  command(0x94); // sleep out 
  command(0x20); // power control 
  data(0x0F); 

  command(0xA7); // invert display 

  command(0x81); // Voltage control 
  data(40);      // contrast setting: 0..63 
  data(3);       // resistance ratio 

  delay(1); 

  command(0xBC); // data control 
  data(0x00); // scan dirs 
  data(0x00); // RGB 
  data(0x04); // grayscale 

  command(0xAF);  // turn on the display 

  _deselect();

  _width = 130;
  _height = 130;
  _rows = 16;
  _columns = 16;
  _row = 0;
  _column = 0;
  _foreground = 0xFFFFFF; 
  _background = 0x000000; 
} 

void lcd_init()
{
  DDRD |= B01111100;   // Set SPI pins as output 
  PORTD |= B01111100;  // Set SPI pins HIGH
  reset();
  delay(500);
}

void lcd_test()
{
  cls();
  fill(10, 2, 128, 5, 0xff0000);
  locate(0,5);
  printf("Hello World!");
  for (int i=0; i<130; i++) {
    lcd_put_pixel(i, 80 + sin((float)i / 5.0)*10, 0x00ffffff);
  }
}


