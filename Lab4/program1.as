
# num_spaces = mem[61] 
LDT 0  # 11
LOD r1
MVL r2 r1

# lfsr_tap = mem[62] 
LDT 1
LOD r1
MVL r3 r1

# lfsr_st = mem[63] 
LDT 2
LOD r1
MVL r4 r1

# read_ptr = 0 
LDT 3
MVL r5 r1

# write_ptr = 64 
LDT 4
MVL r6 r1

# last_ptr = 0 
LDT 3
MVL r7 r1

# enc_char = 0 
LDT 3
MVL r8 r1

# new_bit = 0 
LDT 3
MVL r9 r1

# parity = 0 
LDT 3
MVL r10 r1

# lfsr_tap = lfsr_tap + 128 
MVH r3 r0  # 32
LDT 5   # 33
ADD r0 r1  # 34
MVL r3 r0  # 35

# lfsr_tap = mem[lfsr_tap] 
LOD r3     # 36
MVL r3 r1  # 37

# if num_spaces < 10: 
MVH r2 r0   # 38
LDT 6       # 39
SLT r0 r1   # 40
JNE label0  # 41

	# num_spaces = 10 
	LDT 6
	MVL r2 r1

label0:
# if 26 < num_spaces: 
LDT 7
MVH r1 r0
MVH r2 r1
SLT r0 r1
JNE label1

	# num_spaces = 26 
	LDT 7
	MVL r2 r1

label1:
# last_ptr = write_ptr + num_spaces 
MVH r6 r0
MVH r2 r1
ADD r0 r1
MVL r7 r0

# while write_ptr < last_ptr: 
label2:
	# enc_char = lfsr_st ^ 32 
	MVH r4 r0
	LDT 8
	XOR r0 r1
	MVL r8 r0

	# mem[write_ptr] = enc_char 
	MVH r6 r0
	MVH r8 r1
	STR r0

	# new_bit = lfsr_st & lfsr_tap 
	MVH r4 r0
	MVH r3 r1
	AND r0 r1
	MVL r9 r0

	# new_bit = chs.redxor(new_bit) 
	RDX r9
	MVL r9 r0

	# lfsr_st = lfsr_st << 1 
	MVH r4 r0
	LDT 9
	SHL r0
	MVL r4 r0

	# lfsr_st = lfsr_st | new_bit 
	MVH r4 r0
	MVH r9 r1
	OR  r0 r1
	MVL r4 r0

	# lfsr_st = lfsr_st & 127 
	MVH r4 r0
	LDT 10
	AND r0 r1
	MVL r4 r0

	# write_ptr = write_ptr + 1 
	MVH r6 r0
	LDT 9
	ADD r0 r1
	MVL r6 r0

	MVH r6 r0
	MVH r7 r1
	SLT r0 r1
	JE  label2
	
# last_ptr = 128 
LDT 5
MVL r7 r1

# while write_ptr < last_ptr: 
label3:
	# enc_char = mem[read_ptr] 
	LOD r5
	MVL r8 r1

	# enc_char = lfsr_st ^ enc_char 
	MVH r4 r0
	MVH r8 r1
	XOR r0 r1
	MVL r8 r0

	# mem[write_ptr] = enc_char 
	MVH r6 r0
	MVH r8 r1
	STR r0

	# new_bit = lfsr_st & lfsr_tap 
	MVH r4 r0
	MVH r3 r1
	AND r0 r1
	MVL r9 r0

	# new_bit = chs.redxor(new_bit) 
	RDX r9
	MVL r9 r0

	# lfsr_st = lfsr_st << 1 
	MVH r4 r0
	LDT 9
	SHL r0
	MVL r4 r0

	# lfsr_st = lfsr_st | new_bit 
	MVH r4 r0
	MVH r9 r1
	OR  r0 r1
	MVL r4 r0

	# lfsr_st = lfsr_st & 127 
	MVH r4 r0
	LDT 10
	AND r0 r1
	MVL r4 r0

	# read_ptr = read_ptr + 1 
	MVH r5 r0
	LDT 9
	ADD r0 r1
	MVL r5 r0

	# write_ptr = write_ptr + 1 
	MVH r6 r0
	LDT 9
	ADD r0 r1
	MVL r6 r0

	MVH r6 r0
	MVH r7 r1
	SLT r0 r1
	JE  label3
	
# write_ptr = 64 
LDT 4
MVL r6 r1

# while write_ptr < last_ptr: 
label4:
	# enc_char = mem[write_ptr] 
	LOD r6
	MVL r8 r1

	# parity = chs.redxor(enc_char) 
	RDX r8
	MVL r10 r0

	# if 0 < parity: 
	LDT 3
	MVH r1 r0
	MVH r10 r1
	SLT r0 r1
	JNE label5

		# enc_char = enc_char | 128 
		MVH r8 r0
		LDT 5
		OR  r0 r1
		MVL r8 r0

	label5:
	# mem[write_ptr] = enc_char 
	MVH r6 r0
	MVH r8 r1
	STR r0

	# write_ptr = write_ptr + 1 
	MVH r6 r0
	LDT 9
	ADD r0 r1
	MVL r6 r0

	MVH r6 r0
	MVH r7 r1
	SLT r0 r1
	JE  label4
	
ACK