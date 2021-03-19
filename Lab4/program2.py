import compile_helpers as chs; MEM = chs.initMemory1()
# *** DEBUG ONLY ****
#f = open('./Tests/p2t60s1.txt', "r")
#f = open('./Tests/p2taphex48seedhex20space26.txt', "r")
#f = open('./Tests/p2taphex69seedhex18spaces26.txt', "r")
a = []
for line in f:
    last4 = line[-5:]
    last4 = last4[0:4]
    h = int(last4, 16)
    a.append(h)
f.close()
for i in range(len(a)):
    MEM[64+i] = a[i]
# *** DEBUG ONLY ****

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
echar_no_parity = 0              # r13
parity          = 0              # r14
# r15
# cannot h


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

parity = lfsr_st_init  & 128
lfsr_st_init = lfsr_st_init ^ parity

# 1. Figure out the tap pattern
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

# 3.  decode the message by iterating through
while write_ptr < write_end:
    #  get rid of the parity bit
    parity          = MEM[read_ptr] & 128
    echar_no_parity = MEM[read_ptr] ^ parity

    # decrypt character
    if read_ptr == 64:
        lfsr_st        = echar_no_parity ^ 32
        MEM[write_ptr] = 32  # since we know the frist 10 chars are a space, we can fill the first one like so

    if 64 < read_ptr:
        MEM[write_ptr] = lfsr_st ^ echar_no_parity

    # cycle the LFSR
    lfsr_st = cycle_LFSR(lfsr_st, curr_tap)
    # increment the write and read ptr
    write_ptr += 1
    read_ptr  += 1


# *** DEBUG ONLY ****
# The decoded message should be in MEM[0] - MEM[64]
s = ""
for i in range(64):
    v = MEM[i]
    s += chr(v)
print('start->',s,'<-end')
# *** DEBUG ONLY ****