import compile_helpers as chs; MEM = chs.initMemory1()

# MEM[64] = 289
# MEM[65] = 290
# MEM[66] = 292
# MEM[67] = 296
# MEM[68] = 304
# MEM[69] = 1
# MEM[70] =
# MEM[71] =
# MEM[72] =
# MEM[73] =

# labels are all caps as var name with string values  JUMP and HERE
# TAP_SELECT = "HERE"
# TAP_SELECT = "JUMP"

# Encrypted message in DataMem[64:127]
#   The MSB of each data word is the parity of the other 7
#            7 6 5 4 3 2 1 0
#   word1 =  0 0 0 0 1 1 1 1  # even number of ones -> parity 1
#   word2 =  1 0 0 0 0 1 1 1  # odd number of  ones -> parity 0

# variable            # register location
lfsr_st_init    = MEM[64] ^ 0x20 # r5
lfsr_st         = 0              # r6
tap_select      = 0              # r7
last_ptr        = 75             # r8
read_ptr        = 0              # r9
expected_state  = 0              # r10
found           = 0              # r10
write_ptr       = 0              # r11
write_end       = 64             # r12
echar_no_parity = 0             # r13
parity          = 0             # r14
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
        lfsr_st  = lfsr_st_init
        read_ptr = 65  # start at the space after the seed value
        last_ptr = 74  # read up until the last space value
    NOT_FOUND = "HERE"

    if found == 1: # really only need for the python to work since jumps wont
        break

    # For given tap, cycle through lfsr each state and check expected_state of true lfsr vs guess lfsr
    READ_NEXT_PTR = "HERE"
    while read_ptr < last_ptr:
        parity          = MEM[read_ptr] & 128
        echar_no_parity = MEM[read_ptr] ^ parity

        expected_state   = echar_no_parity ^ 32             # predicted state
        lfsr_st          = cycle_LFSR(lfsr_st, tap_select) # actual state

        # actual    != predicted, go to next tap
        if lfsr_st != expected_state:
            STATES_EQUAL = "JUMP"
            tap_select += 1
            NEXT_TAP = "JUMP"
            break

        STATES_EQUAL = "JUMP"

        if read_ptr == last_ptr - 1:
            NOT_LAST_CHECK = "JUMP"
            found = 1
            FOUND_TAP = "JUMP"

        NOT_LAST_CHECK = "HERE"
        read_ptr += 1
        READ_NEXT_PTR = "JUMP"

FOUND_TAP = "HERE"

# 2.  decode the message by iterating through
WRITE = "HERE"
while write_ptr < write_end:
    DONE_WRITE = "JUMP"

    #  get rid of the parity bit
    parity          = MEM[read_ptr] & 128
    echar_no_parity = MEM[read_ptr] ^ parity
    # decrypt character
    if read_ptr == 64:
        NOT_SEED = "JUMP"
        lfsr_st        = echar_no_parity ^ 32
        MEM[write_ptr] = 32  # since we know the frist 10 chars are a space, we can fill the first one like so
    NOT_SEED = "HERE"

    if read_ptr != 64:
        SEED = "JUMP"
        MEM[write_ptr] = lfsr_st ^ echar_no_parity
    SEED = "HERE"

    # cycle the LFSR
    lfsr_st = cycle_LFSR(lfsr_st, tap_select)
    # increment the write and read ptr
    write_ptr += 1
    read_ptr  += 1
    WRITE = "JUMP"

DONE_WRITE = "HERE"


# *** DEBUG ONLY ****
# The decoded message should be in MEM[0] - MEM[64]
for i in range(64):
    print(MEM[i]+32)