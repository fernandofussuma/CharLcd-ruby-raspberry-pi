require 'pi_piper'

class CharLcd
  # commands
  LCD_CLEARDISPLAY = 0x01
  LCD_RETURNHOME = 0x02
  LCD_ENTRYMODESET = 0x04
  LCD_DISPLAYCONTROL = 0x08
  LCD_CURSORSHIFT = 0x10
  LCD_FUNCTIONSET = 0x20
  LCD_SETCGRAMADDR = 0x40
  LCD_SETDDRAMADDR = 0x80

  # flags for display entry mode
  LCD_ENTRYRIGHT = 0x00
  LCD_ENTRYLEFT = 0x02
  LCD_ENTRYSHIFTINCREMENT = 0x01
  LCD_ENTRYSHIFTDECREMENT = 0x00

  # flags for display on/off control
  LCD_DISPLAYON = 0x04
  LCD_DISPLAYOFF = 0x00
  LCD_CURSORON = 0x02
  LCD_CURSOROFF = 0x00
  LCD_BLINKON = 0x01
  LCD_BLINKOFF = 0x00

  # flags for display/cursor shift
  LCD_DISPLAYMOVE = 0x08
  LCD_CURSORMOVE = 0x00
  LCD_MOVERIGHT = 0x04
  LCD_MOVELEFT = 0x00

  # flags for function set
  LCD_8BITMODE = 0x10
  LCD_4BITMODE = 0x00
  LCD_2LINE = 0x08
  LCD_1LINE = 0x00
  LCD_5x10DOTS = 0x04
  LCD_5x8DOTS = 0x00
  
  def initialize(pin_rs = 25, pin_e = 24, pins_db = [23, 17, 27, 22])
    @pin_rs = PiPiper::Pin.new(:pin => pin_rs, :direction => :out)
    @pin_e = PiPiper::Pin.new(:pin => pin_e, :direction => :out)
    @pins_db = []
    
    pins_db.each { |pin_db| @pins_db.push(PiPiper::Pin.new(:pin => pin_db, :direction => :out)) }
    
    write_4_bits(0x33) # initialization
    write_4_bits(0x32) # initialization
    write_4_bits(0x28) # 2 line 5x7 matrix
    write_4_bits(0x0C) # turn cursor off 0x0E to enable cursor
    write_4_bits(0x06) # shift cursor right
    
    @display_control = LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF

    @display_function = LCD_4BITMODE | LCD_1LINE | LCD_5x8DOTS 
    @display_function |= LCD_2LINE

    # Initialize to default text direction (for romance languages)
    @display_mode = LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT
    write_4_bits(LCD_ENTRYMODESET | @display_mode) # set the entry mode
    
    clear
  end
  
  def begin(cols, lines)
    if lines > 1
      @number_lines = lines
      @display_function |= LCD_2LINE
    end
  end
  
  def home
    write_4_bits(LCD_RETURNHOME)
    delay_microseconds(3000)
  end
  
  def clear
    write_4_bits(LCD_CLEARDISPLAY) # command to clear display
    delay_microseconds(3000)	# 3000 microsecond sleep, clearing the display takes a long time
  end
  
  def set_cursor(col, row)
    row_offsets = [0x00, 0x40, 0x14, 0x54]
    
    row = @number_lines - 1 if (row > @number_lines)
    
    write_4_bits(LCD_SETDDRAMADDR | col + row_offsets[row])
  end
  
  def no_display
    @display_control &= ~LCD_DISPLAYON
    write_4_bits(LCD_DISPLAYCONTROL | @display_control)
  end
  
  def display
    @display_control |= LCD_DISPLAYON
  	write_4_bits(LCD_DISPLAYCONTROL | @display_control)
  end
  
  def no_cursor
    @display_control &= ~LCD_CURSORON
    write_4_bits(LCD_DISPLAYCONTROL | @display_control)
  end

  def cursor
    @display_control |= LCD_CURSORON
    write_4_bits(LCD_DISPLAYCONTROL | @display_control)
  end

  def blink
    @display_control |= LCD_BLINKON
    write_4_bits(LCD_DISPLAYCONTROL | @display_control)
  end

  def no_blink
    @display_control &= ~LCD_BLINKON
    write_4_bits(LCD_DISPLAYCONTROL | @display_control)
  end

  def scroll_display_left
    write_4_bits(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVELEFT)
  end

  def scroll_display_right
    write_4_bits(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVERIGHT)
  end

  def left_to_right
    @display_mode |= LCD_ENTRYLEFT
    write_4_bits(LCD_ENTRYMODESET | @display_mode)
  end

  def right_to_left
    @display_mode &= ~LCD_ENTRYLEFT
    write_4_bits(LCD_ENTRYMODESET | @display_mode)
  end

  def autoscroll
    @display_mode |= LCD_ENTRYSHIFTINCREMENT
    write_4_bits(LCD_ENTRYMODESET | @display_mode)
  end

  def no_autoscroll
    @display_mode &= ~LCD_ENTRYSHIFTINCREMENT
    write_4_bits(LCD_ENTRYMODESET | @display_mode)
  end
  
  def message(text)
    text.each_char do |char|
      if char.eql?("\n")
        write_4_bits(0xC0)
      else
        write_4_bits(char.ord, true)
      end
    end
  end
  
  private
  
  def write_4_bits(bits, char_mode = false)
    delay_microseconds(1000)

    bits = bits.to_s(2).rjust(8, "0")

    @pin_rs.update_value(char_mode)

    @pins_db.each { |pin_db| pin_db.off }
    (0..3).each { |i| @pins_db.reverse[i].on if bits[i].eql?("1") }

    pulse_enable

    @pins_db.each { |pin_db| pin_db.off }
    (4..7).each { |i| @pins_db.reverse[i - 4].on if bits[i].eql?("1") }

    pulse_enable
  end
  
  def pulse_enable
    @pin_e.off
    delay_microseconds(1)
    @pin_e.on
    delay_microseconds(1)
    @pin_e.off
  end
  
  def delay_microseconds(microseconds)
    seconds = microseconds/1_000_000.0
    sleep(seconds)
  end
  
end