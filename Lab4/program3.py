import compile_helpers as chs; MEM = chs.initMemory3()

# variable            # register location
parityExpected  = 0              # r2
lfsr_st_init    = MEM[64] ^ 0x20 # r3
LFSR_st         = 0              # r4
tap_select      = 0              # r5
last_ptr        = 75             # r6
read_ptr        = 0              # r7
expected_state  = 0              # r8
found           = 0              # r9
write_ptr       = 0              # r10
read_end        = 128            # r11
echar_no_parity = 0              # r12
parity          = 0              # r13
dchar_no_parity = 0              # r14
dummyLoad       = 0              # r15


# 0. Figure out tap
parity = lfsr_st_init  & 128
lfsr_st_init = lfsr_st_init ^ parity

print('started tap search')

while found == 0:
    curr_tap = chs.tap_LUT[tap_select]
    print('curr tap = ', curr_tap )
    LFSR_st  = lfsr_st_init
    read_ptr = 65  # start at the space after the seed value
    last_ptr = 74  # read up until the last space value

    # For given tap, cycle through lfsr each state and check expected_state of true lfsr vs guess lfsr
    while read_ptr < last_ptr:
        dummyLoad       = MEM[read_ptr]
        parity          = dummyLoad & 128
        echar_no_parity = dummyLoad ^ parity

        # compute expected lfsr and lfsr with the selected tap
        expected_state   = echar_no_parity ^ 32          # what we should be get if its the correct LSFR

        # cycle the lfsr
        new_bit = LFSR_st & curr_tap  # extract the tap bits
        new_bit = chs.redXOR(new_bit)  # get the new bit; use reduction-xor
        LFSR_st = LFSR_st << 1  # shift left by 1
        LFSR_st = LFSR_st | new_bit  # put in the new bit
        LFSR_st = LFSR_st & 127  # set MSB to 0

        # actual    != expected, go to next tap  (first check since != comparitor not available )
        if LFSR_st < expected_state:
            tap_select = tap_select + 1
            read_ptr = last_ptr

        # actual    != expected, go to next tap  (second check since != comparitor not available )
        if expected_state < LFSR_st:
            tap_select = tap_select + 1
            read_ptr   = last_ptr

        # no more chars to check, made it to the last one, therefore found tap
        if read_ptr == 74:
            found = 1

        # read in the next MEM value and continue checking
        read_ptr = read_ptr + 1

print('tap selection done.  tap selected -> ', hex(curr_tap) )

# 2.  RESET READ POINTER
read_ptr = 64
found    = 0

# 3. Detect first location of non-space character
while found == 0:
    #  get rid of the parity bit
    dummyLoad = MEM[read_ptr]
    parity = dummyLoad & 128
    echar_no_parity = dummyLoad ^ parity

    # decrypt character
    if read_ptr == 64:
        LFSR_st = echar_no_parity ^ 32

    dchar_no_parity = LFSR_st ^ echar_no_parity

    if 32 < dchar_no_parity:
        found = 1

    # cycle the LFSR, move to next char
    if found == 0:
        # cycle the lfsr
        new_bit = LFSR_st & curr_tap  # extract the tap bits
        new_bit = chs.redXOR(new_bit)  # get the new bit; use reduction-xor
        LFSR_st = LFSR_st << 1  # shift left by 1
        LFSR_st = LFSR_st | new_bit  # put in the new bit
        LFSR_st = LFSR_st & 127  # set MSB to 0
        read_ptr  = read_ptr + 1

print("done detecting the first non-space char")

DEBUG_VAR_CORRECT = 0
DEBUG_VAR_WRONG   = 0

# 4. check parity and copy over char.  ( copy first non-space character into MEM[0] )
while read_ptr < read_end:
    # check the global parity at bit 7
    dummyLoad = MEM[read_ptr]
    parity = dummyLoad & 128
    parityExpected = chs.redXOR( dummyLoad )
    echar_no_parity = dummyLoad ^ parity

    # if parity does not match:
    if parity < parityExpected:
        # insert 0x80 into MEM[i]
        MEM[write_ptr] = 0x80
        DEBUG_VAR_WRONG += 1


    # if parity does not match:
    if parityExpected < parity:
        MEM[write_ptr] = 0x80
        DEBUG_VAR_WRONG += 1

    # insert MEM[i] as is
    if parity == parityExpected:
        MEM[write_ptr] = echar_no_parity
        DEBUG_VAR_CORRECT += 1

    # cycle the lfsr
    new_bit = LFSR_st & curr_tap  # extract the tap bits
    new_bit = chs.redXOR(new_bit)  # get the new bit; use reduction-xor
    LFSR_st = LFSR_st << 1  # shift left by 1
    LFSR_st = LFSR_st | new_bit  # put in the new bit
    LFSR_st = LFSR_st & 127  # set MSB to 0

    read_ptr  = read_ptr  + 1
    write_ptr = write_ptr + 1

print('done checking the parity')

# 5. if message stops early, lets say at x, pad with spaces until MEM[63]
while write_ptr < 64:
    MEM[write_ptr] = 0x20
    write_ptr = write_ptr + 1

print('wrote rest of message as spaces')


print('correct -> ', DEBUG_VAR_CORRECT )
print('wrong   -> ', DEBUG_VAR_WRONG )