Ruby library for lcd display compatible with the hd44780 controller on the raspberrypi.

code based on:
https://github.com/adafruit/Adafruit-Raspberry-Pi-Python-Code/blob/master/Adafruit_CharLCD/Adafruit_CharLCD.py

wiring instructions:
http://learn.adafruit.com/drive-a-16x2-lcd-directly-with-a-raspberry-pi/overview

pi_piper install instructions:
https://github.com/jwhitehorn/pi_piper

example:
```
sudo ruby CharLcd_matrix_example.rb
```

usage:
``` ruby
char_lcd = CharLcd.new
char_lcd.begin(16, 2)
char_lcd.message("First Line\nSecond Line")
```
