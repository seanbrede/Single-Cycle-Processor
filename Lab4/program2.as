
# lfsr_st_init = mem[64] 
LDT 4
LOD r1
MVL r2 r1

# lfsr_st = 0 
LDT 3
MVL r3 r1

# tap_select = 0 
LDT 3
MVL r4 r1

# last_ptr = 75 
LDT 11
MVL r5 r1

# read_ptr = 0 
LDT 3
MVL r6 r1

# expected_state = 0 
LDT 3
MVL r7 r1

# found = 0 
LDT 3
MVL r8 r1

# write_ptr = 0 
LDT 3
MVL r9 r1

# write_end = 64 
LDT 4
MVL r10 r1

# echar_no_parity = 0 
LDT 3
MVL r11 r1

# parity = 0 
LDT 3
MVL r12 r1

# curr_tap = 0 
LDT 3
MVL r13 r1

# new_bit = 0 
LDT 3
MVL r14 r1

# lfsr_st_init = lfsr_st_init ^ 32 
MVH r2 r0
LDT 8
XOR r0 r1
MVL r2 r0

# parity = lfsr_st_init & 128 
MVH r2 r0
LDT 5
AND r0 r1
MVL r12 r0

# lfsr_st_init = lfsr_st_init ^ parity 
MVH r2 r0
MVH r12 r1
XOR r0 r1
MVL r2 r0

# while found == 0: 
label6:
	# curr_tap = tap_select + 128 
	MVH r4 r0
	LDT 5
	ADD r0 r1
	MVL r13 r0

	# curr_tap = mem[curr_tap] 
	LOD r13
	MVL r13 r1

	# lfsr_st = lfsr_st_init 
	MVH r2 r1
	MVL r3 r1

	# read_ptr = 65 
	LDT 12
	MVL r6 r1

	# last_ptr = 74 
	LDT 13
	MVL r5 r1

	# while read_ptr < last_ptr: 
	label7:
		# parity = mem[read_ptr] 
		LOD r6
		MVL r12 r1

		# parity = parity & 128 
		MVH r12 r0
		LDT 5
		AND r0 r1
		MVL r12 r0

		# echar_no_parity = mem[read_ptr] 
		LOD r6
		MVL r11 r1

		# echar_no_parity = echar_no_parity ^ parity 
		MVH r11 r0
		MVH r12 r1
		XOR r0 r1
		MVL r11 r0

		# expected_state = echar_no_parity ^ 32 
		MVH r11 r0
		LDT 8
		XOR r0 r1
		MVL r7 r0

		# new_bit = lfsr_st & curr_tap 
		MVH r3 r0
		MVH r13 r1
		AND r0 r1
		MVL r14 r0

		# new_bit = chs.redxor(new_bit) 
		RDX r14
		MVL r14 r0

		# lfsr_st = lfsr_st << 1 
		MVH r3 r0
		LDT 9
		SHL r0
		MVL r3 r0

		# lfsr_st = lfsr_st | new_bit 
		MVH r3 r0
		MVH r14 r1
		OR  r0 r1
		MVL r3 r0

		# lfsr_st = lfsr_st & 127 
		MVH r3 r0
		LDT 10
		AND r0 r1
		MVL r3 r0

		# if lfsr_st < expected_state: 
		MVH r3 r0
		MVH r7 r1
		SLT r0 r1
		JNE label8

			# tap_select = tap_select + 1 
			MVH r4 r0
			LDT 9
			ADD r0 r1
			MVL r4 r0

			# read_ptr = last_ptr 
			MVH r5 r1
			MVL r6 r1

		label8:
		# if expected_state < lfsr_st: 
		MVH r7 r0
		MVH r3 r1
		SLT r0 r1
		JNE label9

			# tap_select = tap_select + 1 
			MVH r4 r0
			LDT 9
			ADD r0 r1
			MVL r4 r0

			# read_ptr = last_ptr 
			MVH r5 r1
			MVL r6 r1

		label9:
		# if read_ptr == 73: 
		MVH r6 r0
		LDT 14
		SEQ r0 r1
		JNE label10

			# found = 1 
			LDT 9
			MVL r8 r1

		label10:
		# read_ptr = read_ptr + 1 
		MVH r6 r0
		LDT 9
		ADD r0 r1
		MVL r6 r0

		MVH r6 r0
		MVH r5 r1
		SLT r0 r1
		JE  label7
		
	MVH r8 r0
	LDT 3
	SEQ r0 r1
	JE  label6
	
# read_ptr = 64 
LDT 4
MVL r6 r1

# while write_ptr < write_end: 
label11:
	# parity = mem[read_ptr] 
	LOD r6
	MVL r12 r1

	# parity = parity & 128 
	MVH r12 r0
	LDT 5
	AND r0 r1
	MVL r12 r0

	# echar_no_parity = mem[read_ptr] 
	LOD r6
	MVL r11 r1

	# echar_no_parity = echar_no_parity ^ parity 
	MVH r11 r0
	MVH r12 r1
	XOR r0 r1
	MVL r11 r0

	# if read_ptr == 64: 
	MVH r6 r0
	LDT 4
	SEQ r0 r1
	JNE label12

		# lfsr_st = echar_no_parity ^ 32 
		MVH r11 r0
		LDT 8
		XOR r0 r1
		MVL r3 r0

		# mem[write_ptr] = 32 
		MVH r9 r0
		LDT 8
		STR r0

	label12:
	# if 64 < read_ptr: 
	LDT 4
	MVH r1 r0
	MVH r6 r1
	SLT r0 r1
	JNE label13

		# echar_no_parity = lfsr_st ^ echar_no_parity 
		MVH r3 r0
		MVH r11 r1
		XOR r0 r1
		MVL r11 r0

		# mem[write_ptr] = echar_no_parity 
		MVH r9 r0
		MVH r11 r1
		STR r0

	label13:
	# new_bit = lfsr_st & curr_tap 
	MVH r3 r0
	MVH r13 r1
	AND r0 r1
	MVL r14 r0

	# new_bit = chs.redxor(new_bit) 
	RDX r14
	MVL r14 r0

	# lfsr_st = lfsr_st << 1 
	MVH r3 r0
	LDT 9
	SHL r0
	MVL r3 r0

	# lfsr_st = lfsr_st | new_bit 
	MVH r3 r0
	MVH r14 r1
	OR  r0 r1
	MVL r3 r0

	# lfsr_st = lfsr_st & 127 
	MVH r3 r0
	LDT 10
	AND r0 r1
	MVL r3 r0

	# write_ptr = write_ptr + 1 
	MVH r9 r0
	LDT 9
	ADD r0 r1
	MVL r9 r0

	# read_ptr = read_ptr + 1 
	MVH r6 r0
	LDT 9
	ADD r0 r1
	MVL r6 r0

	MVH r9 r0
	MVH r10 r1
	SLT r0 r1
	JE  label11
	
ACK