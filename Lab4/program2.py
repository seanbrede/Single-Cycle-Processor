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
write_ptr      = 0             # r11
write_end      = 64            # r12
# r13
# r14
# r15
# cannot h

def cycle_LFSR( LFSR_st, tap):
    x = LFSR_st & tap
    new_bit = chs.redXOR(x)
    LFSR_st = LFSR_st | new_bit  # put in the new bit
    # LFSR_st = LFSR_st >> 1  # shift over by 1  # TODO:: isnt left shift ?
    return  LFSR_st

# 1. Figure out the tap pattern
     # WHILE_TAP_SEARCH JUMP (dummy label for while loops)
while tap_select < 9:
    if found == 0:  # IF STATEMENT IS NOT NEEDED IF JUMPS ARE AVAILABLE
        #TODO-> NEXT_TAP: HERE
        curr_tap = chs.tap_LUT[tap_select]
        LFSR_st  = LFSR_st_init
        read_ptr = 65  # start at the space after the seed value
        last_ptr = 74  # read in the other 9 spaces

    # iterate through each state making sure they're the same
    while read_ptr < last_ptr:
        # get the predicted adn actual next state
        expected_state = MEM[read_ptr] ^ 32
        LFSR_st        = cycle_LFSR( LFSR_st, tap_select)

        # if the same check next state, else go to next tap
        if LFSR_st == expected_state:
            if read_ptr == last_ptr-1:
                found = 1 # not needed for assembly
                break#TODO-> FOUND_TAP: JUMP
            read_ptr   += 1
        else:
            tap_select += 1 # jump to the label of "while tap < 9"
            break #TODO-> NEXT_TAP: JUMP
# WHILE_TAP_SEARCH JUMP

#TODO-> FOUND_TAP: HERE

# 2.  decode the message by iterating through
while write_ptr < write_end:
    MEM[write_ptr] = LFSR_st ^ MEM[read_ptr]
    #TODO:: maybe djust for parity bit
    LFSR_st = cycle_LFSR(LFSR_st, tap_select)
    write_ptr += 1
    read_ptr  += 1

# The decoded message should be in MEM[0] - MEM[64]