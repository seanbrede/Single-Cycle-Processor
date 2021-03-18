import compile_helpers as chs; MEM = chs.initMemory2(); TAP_LUT = []  # TODO need to fill in TAP_LUT


# variable
LFSR_st_init = MEM[64] ^ 0x20  # r2
tap_select   = 0               # r3
last_ptr     = 75              # r4
LFSR_tap     = 0               # r5
LFSR_st      = 0               # r6
read_ptr     = 0               # r7
next_state   = 0               # r8
new_bit      = 0               # r9
tap_found    = 0               # r10
# r11
# r12
# r13
# r14
# r15
# cannot have more variables after r15


# 1. figure out the tap pattern
while tap_found == 0:
    LFSR_tap  = TAP_LUT[tap_select]
    LFSR_st   = LFSR_st_init
    read_ptr  = 65  # the first “next state”
    tap_found = 1   # assume this tap is the correct one until proven otherwise

    # iterate through each state making sure they’re the same
    while read_ptr < last_ptr:
        # get the predicted next LFSR state
        new_bit = LFSR_st & LFSR_tap   # extract the tap bits
        new_bit = chs.redXOR(new_bit)  # get the new bit; use reduction-xor
        LFSR_st = LFSR_st << 1         # shift left by 1
        LFSR_st = LFSR_st | new_bit    # put in the new bit
        LFSR_st = LFSR_st & 127        # set MSB to 0
        # get the actual next LFSR state
        next_state = MEM[read_ptr] ^ 32
        # if the 2 states are different, these aren't the droids you're looking for
        if LFSR_st != next_state:
            tap_found = 0
        # move up the pointer
        read_ptr = read_ptr + 1

    # go to next tap if we failed
    if tap_found == 0:
        tap_select = tap_select + 1


# 2. decode the message TODO
while 1 < 0:
    pass
