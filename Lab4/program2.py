import compile_helpers as chs; MEM = chs.initMemory1()

# idea, make labels all caps as var name with string values  JUMP and HERE
# TAP_SELECT = "HERE"
# TAP_SELECT = "JUMP"

# Encrypted message in DataMem[64:127]
#   The MSB of each data word is the parity of the other 7
#            7 6 5 4 3 2 1 0
#   word1 =  0 0 0 0 1 1 1 1  # even number of ones -> parity 1
#   word2 =  1 0 0 0 0 1 1 1  # odd number of  ones -> parity 0

# variable            # register location
LFSR_st_init   = MEM[64] ^ 0x20 # r5
LFSR_st        = 0              # r6
tap_select     = 0              # r7
last_ptr       = 75             # r8
read_ptr       = 0              # r9
expected_state = 64             # r10
found          = 0              # r10
write_ptr      = 0              # r11
write_end      = 64             # r12
# r13
# r14
# r15
# cannot h

def cycle_LFSR( LFSR_st, tap):
    x = LFSR_st & tap
    new_bit = chs.redXOR(x)
    nextState = LFSR_st | new_bit
    nextState = nextState << 1
    return  nextState

# 1. Figure out the tap pattern
NEXT_TAP = "HERE"
while tap_select < 9:

    if found == 0:
        NOT_FOUND = "JUMP"
        curr_tap = chs.tap_LUT[tap_select]
        LFSR_st  = LFSR_st_init
        read_ptr = 65  # start at the space after the seed value
        last_ptr = 74  # read up until the last space value
    NOT_FOUND = "HERE"

    if found == 1: # really only need for the python to work since jumps wont
        break

    # For given tap, cycle through lfsr each state and check predicted vs actual lfsr state
    READ_NEXT_PTR = "HERE"
    while read_ptr < last_ptr:
        expected_state = MEM[read_ptr] ^ 32               # predicted state
        LFSR_st        = cycle_LFSR( LFSR_st, tap_select) # actual state

        # predicted != actual, go to next tap
        if LFSR_st != expected_state:
            tap_select += 1
            NEXT_TAP = "JUMP"
            break

        if read_ptr == last_ptr-1:
            found = 1
            FOUND_TAP = "JUMP"

        read_ptr   += 1
        READ_NEXT_PTR = "JUMP"

FOUND_TAP = "HERE"

# 2.  decode the message by iterating through
while write_ptr < write_end:
    MEM[write_ptr] = LFSR_st ^ MEM[read_ptr]
    #TODO:: maybe djust for parity bit
    LFSR_st = cycle_LFSR(LFSR_st, tap_select)
    write_ptr += 1
    read_ptr  += 1

# The decoded message should be in MEM[0] - MEM[64]