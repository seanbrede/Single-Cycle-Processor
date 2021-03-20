import compile_helpers as chs; MEM = chs.initMemory2()
# *** DEBUG ONLY ****
# f = open('./Tests/p2taphex60seedhex1spaces10.txt', "r")
# f = open('./Tests/p2taphex48seedhex20space26.txt', "r")
# f = open('./Tests/p2taphex69seedhex18spaces26.txt', "r")
# a = []
# for line in f:
#    last4 = line[-5:]
#    last4 = last4[0:4]
#    h = int(last4, 16)
#    a.append(h)
# f.close()
# for i in range(len(a)):
#    MEM[64+i] = a[i]
# *** DEBUG ONLY ****

# Encrypted message in DataMem[64:127]
#   The MSB of each data word is the parity of the other 7
#            7 6 5 4 3 2 1 0
#   word1 =  0 0 0 0 1 1 1 1  # even number of ones -> parity 1
#   word2 =  1 0 0 0 0 1 1 1  # odd number of  ones -> parity 0

# variable                           # register location
lfsr_st_init    = MEM[64]            # r2
lfsr_st         = 0                  # r3
tap_select      = 0                  # r4
last_ptr        = 75                 # r5
read_ptr        = 0                  # r6
expected_state  = 0                  # r7
found           = 0                  # r8
write_ptr       = 0                  # r9
write_end       = 64                 # r10
echar_no_parity = 0                  # r11
parity          = 0                  # r12
curr_tap        = 0                  # r13
new_bit         = 0                  # r14
# r15
# cannot have more variables after r15


# 0. remove the parity for init
lfsr_st_init = lfsr_st_init ^ 32
parity       = lfsr_st_init & 128
lfsr_st_init = lfsr_st_init ^ parity


# 1. Figure out the tap pattern
while found == 0:
    # get the tap pattern
    curr_tap = tap_select + 128
    curr_tap = MEM[curr_tap]
    # initialize variables for this iteration
    lfsr_st  = lfsr_st_init
    read_ptr = 65  # start at the space after the seed value
    last_ptr = 74  # read up until the last space value

    # For given tap, cycle through lfsr each state and check expected_state of true lfsr vs guess lfsr
    while read_ptr < last_ptr:
        parity          = MEM[read_ptr]
        parity          = parity & 128
        echar_no_parity = MEM[read_ptr]
        echar_no_parity = echar_no_parity ^ parity
        # compute expected lfsr and lfsr with the selected tap
        expected_state = echar_no_parity ^ 32           # what we should be get if its the correct LSFR
        # cycle the LFSR
        new_bit = lfsr_st & curr_tap   # extract the tap bits
        new_bit = chs.redXOR(new_bit)  # get the new bit; use reduction-xor
        lfsr_st = lfsr_st << 1         # shift left by 1
        lfsr_st = lfsr_st | new_bit    # put in the new bit
        lfsr_st = lfsr_st & 127        # set MSB to 0

        # actual != expected, go to next tap
        if lfsr_st < expected_state:
            tap_select = tap_select + 1
            read_ptr = last_ptr
        if expected_state < lfsr_st:
            tap_select = tap_select + 1
            read_ptr = last_ptr

        if read_ptr == 73:
            found = 1
        # read in the next MEM value and continue checking
        read_ptr = read_ptr + 1

print('tap selection done.  tap selected -> ', hex(curr_tap))

# 2.  RESET READ POINTER
read_ptr = 64

# 3.  decode the message by iterating through
while write_ptr < write_end:
    #  get rid of the parity bit
    parity          = MEM[read_ptr]
    parity          = parity & 128
    echar_no_parity = MEM[read_ptr]
    echar_no_parity = echar_no_parity ^ parity

    # decrypt character
    if read_ptr == 64:
        lfsr_st        = echar_no_parity ^ 32
        MEM[write_ptr] = 32

    if 64 < read_ptr:
        echar_no_parity = lfsr_st ^ echar_no_parity
        MEM[write_ptr]  = echar_no_parity

    # cycle the LFSR
    new_bit = lfsr_st & curr_tap   # extract the tap bits
    new_bit = chs.redXOR(new_bit)  # get the new bit; use reduction-xor
    lfsr_st = lfsr_st << 1         # shift left by 1
    lfsr_st = lfsr_st | new_bit    # put in the new bit
    lfsr_st = lfsr_st & 127        # set MSB to 0
    # increment the write and read ptr
    write_ptr = write_ptr + 1
    read_ptr  = read_ptr + 1


# print results for testing
print(MEM[0:64])


# *** DEBUG ONLY ****
# The decoded message should be in MEM[0] - MEM[64]
# s = ""
# for i in range(64):
#     v = MEM[i]
#    s += chr(v)
# print('start->',s,'<-end')
# *** DEBUG ONLY ****
