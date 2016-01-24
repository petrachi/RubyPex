# memory store, 32 words (numbered 0-31)
# words, 32 digits (numerbred 0-31, left to right)
# accumulator, 32 digits, holds the result of arithmetic operations
# CI, 32 digits, hold a single line: the adress 'line number' of instructions, is incremented before instruction, so 1st instruction to be executed is n°1
# CI, during execution, CI holds a 2nd line, the PI, present instruction, the instruction being executed
# instruction: line number use digits 0,1,2,3,4 - function number use digits 13,14,15 - other digits are not used
# functions:
# 0	000	s,C	 	JMP	Copy content of Store line to CI
# 1	100	c+s,C	 	JRP	Add content of Store line to CI
# 2	010 	-s,A	 	LDN	Copy content of Store line, negated, to accumulator.
# 3 	110	a,S	 	STO	Copy content of acc. to Store line.
# 4	001	a-s, A	 	SUB	Subtract content of Store line from Accumulator
# 5	101	-		-	Same as function number 4
# 6	011	Test		CMP	Skip next instruction if content of Accumulator is negative
# 7	111	Stop		STOP	Light "Stop" neon and halt the machine.

class Tube
  def initialize bits
    @memory = bits.split
  end

  def read address
    # p "reading: #{address[0..4].reverse.to_i(2)} -> #{@memory[address[0..4].reverse.to_i(2)]}"
    @memory[address[0..4].reverse.to_i(2)]
  end

  def write address, value
    @memory[address[0..4].reverse.to_i(2)] = value
  end

  def display
    @memory.each_with_index do |line, i|
      p "%02i: %s" % [i, line]
    end
    p '&' * 36
  end
end

class Accumulator
  def initialize
    @value = '0'*32
  end

  def write number
    result = @value.reverse.to_i(2) - number.reverse.to_i(2)
    @value = 31.downto(0).map { |n| result[n] }.join.reverse
  end

  def read
    @value
  end

  def reset
    @value = '0'*32
  end
end


class SSEM
  INSTRUCTIONS = ['JMP', 'JRP', 'LDN', 'STO', 'SUB', 'SUB', 'CMB', 'STOP']

  def initialize bits
    @tube = Tube.new(bits)
    @accumulator = Accumulator.new

    @ci = '0'*32
    @stop = false

    start
  end

  def start
    begin
      @ci = ('%032b' % (@ci.reverse.to_i(2) + 0b1)).reverse
      play
    end until @stop
  end

  def play
    @pi = @tube.read @ci

    p "ci : #{@ci}"
    p "instruction: #{INSTRUCTIONS[@pi[13..15].reverse.to_i(2)]} (arg: #{@pi[0..4].reverse.to_i(2)})"

    send INSTRUCTIONS[@pi[13..15].reverse.to_i(2)]
  end

  def JMP
    @ci = @tube.read @pi
  end

  def JRP
    @ci = ('%032b' % (@ci.reverse.to_i(2) + @tube.read(@pi).reverse.to_i(2))).reverse
  end

  def LDN
    @accumulator.reset
    @accumulator.write @tube.read(@pi)
  end

  def STO
    @tube.write @pi, @accumulator.read
  end

  def SUB
    @accumulator.write @tube.read(@pi)
  end

  def CMB
    p "c"
  end

  def STOP
    @stop = true
    @tube.display
  end
end

# 00000111111111000111111111111111

# jump vers la ligne 3, qui stope
# 0 0
# 1 jmp 2
# 2 2
# 3 stop
SSEM.new("00000000000000000000000000000000
01000000000000000000000000000000
01000000000000000000000000000000
00000000000001110000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000")







p "-"*32



# jump vers la ligne 3, qui jump 3 lignes plus bas, qui stope
# 0 0
# 1 jmp 2
# 2 2
# 3 jrp 3
# 4 0
# 5 0
# 6 0
# 7 stop
SSEM.new("00000000000000000000000000000000
01000000000000000000000000000000
01000000000000000000000000000000
11000000000001000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000001110000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000")

p "-"*32

# add numbers 11 + 36 # -> 47
# memory 30 should be "11110100000000000000000000000000"
# 0 0
# 1 lnd 28
# 2 sub 29
# 3 sto 30
# 6 lnd 30
# 7 sto 30
# ...
# 28 11
# 29 36
# 30 0
SSEM.new("00000000000000000000000000000000
00111000000000100000000000000000
10111000000000010000000000000000
01111000000001100000000000000000
01111000000000100000000000000000
01111000000001100000000000000000
00000000000001110000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
11010000000000000000000000000000
00100100000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000")

p "-"*32

# same, with numbers 49, -2 # -> 47
# memory 30 should be "11110100000000000000000000000000"
SSEM.new("00000000000000000000000000000000
00111000000000100000000000000000
10111000000000010000000000000000
01111000000001100000000000000000
01111000000000100000000000000000
01111000000001100000000000000000
00000000000001110000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
10001100000000000000000000000000
01111111111111111111111111111111
00000000000000000000000000000000
00000000000000000000000000000000")