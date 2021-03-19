import compile_helpers as chs; MEM = chs.initMemory1()

# variable            # register location
parityExpected  = 0              # r4
lfsr_st_init    = MEM[64] ^ 0x20 # r5
lfsr_st         = 0              # r6
tap_select      = 0              # r7
last_ptr        = 75             # r8
read_ptr        = 0              # r9
expected_state  = 0              # r10
found           = 0              # r10
write_ptr       = 0              # r11
read_end        = 128            # r12
echar_no_parity = 0              # r13
parity          = 0              # r14
dchar_no_parity = 0              # r15


def cycle_LFSR( LFSR_st, tap):
    x       = LFSR_st & tap
    new_bit =  chs.redXOR(x)
############# *** DEBUG ONLY **** ###################  b/c verilog shift left will clear the last bit
    #GET MSB
    MSB     = (LFSR_st >> 6) & 1
    MSB = MSB << 6
    # CLEAR MSB
    LFSR_st  = LFSR_st ^ MSB
############ *** DEBUG ONLY **** ###################
    #SHIFT LEFT
    LFSR_st   = LFSR_st << 1
    #lfsr_st = shift_left(LFSR_st)
    nextState = LFSR_st | new_bit
    return  nextState

# 0. Figure out tap
parity = lfsr_st_init  & 128
lfsr_st_init = lfsr_st_init ^ parity

while found == 0:
    curr_tap = chs.tap_LUT[tap_select]
    lfsr_st  = lfsr_st_init
    read_ptr = 65  # start at the space after the seed value
    last_ptr = 74  # read up until the last space value

    # For given tap, cycle through lfsr each state and check expected_state of true lfsr vs guess lfsr
    while read_ptr < last_ptr:
        parity          = MEM[read_ptr] & 128
        echar_no_parity = MEM[read_ptr] ^ parity
        # compute expected lfsr and lfsr with the selected tap
        expected_state   = echar_no_parity ^ 32          # what we should be get if its the correct LSFR
        lfsr_st          = cycle_LFSR(lfsr_st, curr_tap) # what the current tap pattern produces

        # actual    != expected, go to next tap
        if lfsr_st != expected_state:
            tap_select += 1
            break

        if read_ptr == last_ptr - 1:
            found = 1
        # read in the next MEM value and continue checking
        read_ptr += 1

print('tap selection done.  tap selected -> ', hex(curr_tap) )

# 2.  RESET READ POINTER
read_ptr = 64
found    = 0

# 3. Detect first location of non-space character
while found == 0:
    #  get rid of the parity bit
    parity          = MEM[read_ptr] & 128
    echar_no_parity = MEM[read_ptr] ^ parity

    # decrypt character
    if read_ptr == 64:
        lfsr_st        = echar_no_parity ^ 32

    dchar_no_parity = lfsr_st ^ echar_no_parity

    if 32 < dchar_no_parity:
        found = 1

    # cycle the LFSR, move to next char
    if found == 0:
        lfsr_st = cycle_LFSR(lfsr_st, curr_tap)
        read_ptr  += 1


# 4. check parity and copy over char.  ( copy first non-space character into MEM[0] )
while read_ptr < read_end:
  # check the global parity at bit 7
    parity          = MEM[read_ptr] & 128
    parityExpected  = chs.redXOR( MEM[read_ptr] )
    echar_no_parity = MEM[read_ptr] ^ parity

    # if parity does not match:
    if parity < parityExpected:
        # insert 0x80 into MEM[i]
        MEM[write_ptr] = 0x80

    # if parity does not match:
    if parityExpected < parity:
        MEM[write_ptr] = 0x80

    # insert MEM[i] as is
    if parity == parityExpected:
        MEM[write_ptr] = echar_no_parity

    lfsr_st = cycle_LFSR(lfsr_st, curr_tap)
    read_ptr  += 1
    write_ptr += 1


# 5. if message stops early, lets say at x, pad with spaces until MEM[63]
while write_ptr < 64:
    MEM[write_ptr] = 0x20
    write_ptr += 1