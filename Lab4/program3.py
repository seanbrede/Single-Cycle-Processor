import compile_helpers as chs; MEM = chs.initMemory2()


# variable        value    register location
parityExpected  = 0        # r2
lfsr_st_init    = MEM[64]  # r3
LFSR_st         = 0        # r4
tap_select      = 0        # r5
last_ptr        = 75       # r6
read_ptr        = 0        # r7
expected_state  = 0        # r9
found           = 0        # r8
write_ptr       = 0        # r10
echar_no_parity = 0        # r11
parity          = 0        # r12
dummyLoad       = 0        # r13
curr_tap        = 0        # r14
# cannot have more variables after r15


# 0. Figure out tap
lfsr_st_init = lfsr_st_init ^ 32
parity       = lfsr_st_init & 128
lfsr_st_init = lfsr_st_init ^ parity


while found == 0:
    # get the tap pattern
    curr_tap = tap_select + 128
    curr_tap = MEM[curr_tap]
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
        new_bit = LFSR_st & curr_tap   # extract the tap bits
        new_bit = chs.redXOR(new_bit)  # get the new bit; use reduction-xor
        LFSR_st = LFSR_st << 1         # shift left by 1
        LFSR_st = LFSR_st | new_bit    # put in the new bit
        LFSR_st = LFSR_st & 127        # set MSB to 0

        # actual != expected, go to next tap (first check since != comparitor not available)
        if LFSR_st < expected_state:
            tap_select = tap_select + 1
            read_ptr   = last_ptr
        if expected_state < LFSR_st:
            tap_select = tap_select + 1
            read_ptr   = last_ptr

        # no more chars to check, made it to the last one, therefore found tap
        if read_ptr == 73:
            found = 1

        # read in the next MEM value and continue checking
        read_ptr = read_ptr + 1

print('tap selection done.  tap selected -> ', hex(curr_tap))

# 2. RESET READ POINTER
read_ptr = 64
found    = 0

# 3. Detect first location of non-space character
while found == 0:
    # get rid of the parity bit
    dummyLoad       = MEM[read_ptr]
    parity          = dummyLoad & 128
    echar_no_parity = dummyLoad ^ parity

    # decrypt character
    if read_ptr == 64:
        LFSR_st = echar_no_parity ^ 32

    echar_no_parity = LFSR_st ^ echar_no_parity

    if 32 < echar_no_parity:
        found = 1

    # cycle the LFSR, move to next char
    if found == 0:
        # cycle the lfsr
        new_bit = LFSR_st & curr_tap   # extract the tap bits
        new_bit = chs.redXOR(new_bit)  # get the new bit; use reduction-xor
        LFSR_st = LFSR_st << 1         # shift left by 1
        LFSR_st = LFSR_st | new_bit    # put in the new bit
        LFSR_st = LFSR_st & 127        # set MSB to 0

        read_ptr = read_ptr + 1

print('found first non space at index =', read_ptr - 64)

# 4. check parity and copy over char.  ( copy first non-space character into MEM[0] )
while read_ptr < 128:
    # check the global parity at bit 7
    dummyLoad       = MEM[read_ptr]
    # print("dummyLoad is:", dummyLoad)
    parity          = dummyLoad & 128
    echar_no_parity = dummyLoad ^ parity
    # echar_no_parity = echar_no_parity ^ LFSR_st
    # print("decrypted:", echar_no_parity)

    if parity == 128:
        parity = 1

    parityExpected  = chs.redXOR(echar_no_parity)
    echar_no_parity = echar_no_parity ^ LFSR_st

    # if parity does not match, insert 0x80 into MEM[i]
    if parity < parityExpected:
        MEM[write_ptr] = 128

    # if parity does not match, insert 0x80 into MEM[i]
    if parityExpected < parity:
        MEM[write_ptr] = 128

    # insert MEM[i] as is
    if parity == parityExpected:
        MEM[write_ptr] = echar_no_parity

    # cycle the lfsr
    print("LFSR_st: ", LFSR_st)
    new_bit = LFSR_st & curr_tap   # extract the tap bits
    new_bit = chs.redXOR(new_bit)  # get the new bit; use reduction-xor
    LFSR_st = LFSR_st << 1         # shift left by 1
    LFSR_st = LFSR_st | new_bit    # put in the new bit
    LFSR_st = LFSR_st & 127        # set MSB to 0

    read_ptr  = read_ptr  + 1
    write_ptr = write_ptr + 1


# 5. if message stops early, lets say at x, pad with spaces until MEM[63]
while write_ptr < 64:
    MEM[write_ptr] = 32
    write_ptr = write_ptr + 1


# print results for testing
print(MEM[0:64])
