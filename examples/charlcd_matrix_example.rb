require 'rpi_gpio'

SLEEP_TIME = 0.005
COLUMNS = 16
LINES = 2

lcd = CharLcd.new
lcd.begin(COLUMNS, LINES)

lcd.blink

prng = Random.new

def rand_matrix(prng)
  prng.rand(2).zero? ? prng.rand(33..127) : prng.rand(161..253)
end

(0..100).each do
  c = prng.rand(COLUMNS)
  for l in 0...LINES

      count = prng.rand(5)
      i = 0
      while i < count
        lcd.set_cursor(c, l)
        lcd.write_4_bits(rand_matrix(prng), true)
        lcd.set_cursor(c, l)
        sleep(SLEEP_TIME)
        i += 1
      end

      if prng.rand(10).zero?
        count = prng.rand(5)
        i = 0

        c1 = prng.rand(COLUMNS)
        l1 = prng.rand(LINES)

        while i < count do
          lcd.set_cursor(c1, l1)
          lcd.write_4_bits(rand_matrix(prng), true)
          lcd.set_cursor(c1, l1)
          sleep(SLEEP_TIME)
          i += 1
        end
      end

  end
end

lcd.no_blink
lcd.clear
