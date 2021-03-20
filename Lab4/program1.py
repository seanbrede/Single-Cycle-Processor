import compile_helpers as chs; MEM = chs.initMemory1()


# variable            # register location
num_spaces = MEM[61]  # r2
LFSR_tap   = MEM[62]  # r3
LFSR_st    = MEM[63]  # r4
read_ptr   = 0        # r5
write_ptr  = 64       # r6
last_ptr   = 0        # r7
enc_char   = 0        # r8
new_bit    = 0        # r9
parity     = 0        # r10
# r11
# r12
# r13
# r14
# r15
# cannot have more variables after r15


# 1. get LFSR tap pattern
LFSR_tap = LFSR_tap + 128
LFSR_tap = MEM[LFSR_tap]


# 2. figure out how many spaces are necessary
if num_spaces < 10:
	num_spaces = 10
if 26 < num_spaces:
	num_spaces = 26


# 3. encrypt spaces as preamble
last_ptr = write_ptr + num_spaces
while write_ptr < last_ptr:
	# encrypt a space and write it
	enc_char       = LFSR_st ^ 32
	MEM[write_ptr] = enc_char
	# cycle the LFSR
	new_bit = LFSR_st & LFSR_tap   # extract the tap bits
	new_bit = chs.redXOR(new_bit)  # get the new bit; use reduction-xor
	LFSR_st = LFSR_st << 1         # shift left by 1
	LFSR_st = LFSR_st | new_bit    # put in the new bit
	LFSR_st = LFSR_st & 127        # set MSB to 0
	# move up pointer
	write_ptr = write_ptr + 1


# 4. encrypt the message
last_ptr = 128  # don't write any more than the message buffer can hold
while write_ptr < last_ptr:
	# encrypt a character and write it
	enc_char       = MEM[read_ptr]
	enc_char       = LFSR_st ^ enc_char
	MEM[write_ptr] = enc_char
	# cycle the LFSR
	new_bit = LFSR_st & LFSR_tap   # extract the tap bits
	new_bit = chs.redXOR(new_bit)  # get the new bit; use reduction-xor
	LFSR_st = LFSR_st << 1         # shift left by 1
	LFSR_st = LFSR_st | new_bit    # put in the new bit
	LFSR_st = LFSR_st & 127        # set MSB to 0
	# move up pointers
	read_ptr  = read_ptr + 1
	write_ptr = write_ptr + 1


# 5. set parity
write_ptr = 64
while write_ptr < last_ptr:
	# read an encrypted character
	enc_char = MEM[write_ptr]
	# set the parity
	parity = chs.redXOR(enc_char)
	if 0 < parity:
		enc_char = enc_char | 128
	# write the character with parity
	MEM[write_ptr] = enc_char
	# move up pointer
	write_ptr = write_ptr + 1


# print results for testing
print(MEM[64:128])
