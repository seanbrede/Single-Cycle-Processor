import collections as col


tap_LUT   = [0x60, 0x48, 0x78, 0x72, 0x6A, 0x69, 0x5C, 0x7E, 0x7B]
filenames = ["program1.py", "program2.py", "program3.py"]


# deal with comments, formatting, capitalization
def processLine(line):
    line = line.split("#")[0]    # remove comments by getting rid of everything after the first "#"
    line = line.strip()          # remove leading and trailing whitespace
    line = line.lower().split()  # lowercase and then split
    return line                  # inst[0] is operation, inst[1], inst[2] are operands


# create the table that links immediate values to an index, from each of the 3 program files
def buildImmediateTable():
    imm_table = col.defaultdict(lambda: -1)
    for file in filenames:
        imm_table = addImmEntries(file, imm_table)
    return


# put immediate entries from the file into the table
def addImmEntries(file, imm_table):
    for line in open(file, "r"):
        pass  # TODO

    return imm_table


# write LUT_Imm.sv based off of the table
def writeLUTImm(imm_table):
    pass  # TODO


# reduction xor
def redXOR( red ):
    par = 0
    while red != 0:
        par = par + 1
        red = red & (red - 1)
    par = par % 2
    if par > 0:
        return 1
    else:
        return 0



# set up the memory for program1
def initMemory1():
    MEM = ([32] * 54) + ([0] * (256 - 54))
    MEM[61] = 10          # number of spaces
    MEM[62] = tap_LUT[0]  # LFSR tap pattern
    MEM[63] = 64          # LFSR initial state
    message = "Mr. Watson, come here. I want to see you."
    for i in range(len(message)):
        MEM[i] = ord(message[i])  # convert char to int

    return MEM



def initMemory3(test):
    MEM = ([32] * 54) + ([0] * (256 - 54))

    if test == 0:
        f = open('./Tests/p3taphex60seedhex1spaces13.txt', "r")
    elif test == 1:
        f = open('./Tests/p3taphex78seed20spaces13.txt', "r")
    else:
        f = open('./Tests/pa3taphex6aseed6dspaces18.txt', "r")

    a = []
    c = 0
    for line in f:
        if c >= 65:
            last4 = line[-5:]
            last4 = last4[0:4]
            h = int(last4, 16)
            a.append(h)
        c += 1
    f.close()
    for i in range(len(a)):
        MEM[64 + i] = a[i]

    return MEM




def program3CheckWork( test, indexOfFirstNonSpaceChar, results, MEM ):
    hexValues       = []
    isFlippedValues = []
    c = 0
    if test == 0:
        f = open('./Tests/p3taphex60seedhex1spaces13.txt', "r")
    elif test == 1:
        f = open('./Tests/p3taphex78seed20spaces13.txt', "r")
    else:
        f = open('./Tests/pa3taphex6aseed6dspaces18.txt', "r")

    for line in f:
        if c >= 65:
            isFlipped =  line[13+2]
            last4 = line[-5:]
            last4 = last4[0:4]
            h = int(last4, 16)
            hexValues.append(h)
            if isFlipped == 'f':
                isFlippedValues.append(1)
            else:
                isFlippedValues.append(0)
        c += 1
    f.close()

    hexValues = hexValues[indexOfFirstNonSpaceChar:]
    isFlippedValues = isFlippedValues[indexOfFirstNonSpaceChar:]

    correct = 0
    total = 0
    for i in range(len(results)):

        if isFlippedValues[i] != results[i]:
            print("i= ", i + indexOfFirstNonSpaceChar, " tb = ", hex(hexValues[i]), "vs.  MEM=",
                  hex(MEM[i]))
            print("TEST_BENCH_IS_FLIPPED_VALS[ti]= ", isFlippedValues[i], " DEBUG_ARR[i] = ", results[i])
            raise Exception("Wrong Val")
        else:
            correct += 1
            # print("match @ i =", i+DEBUG_FIRST_NON_SPACE_INDEX, " tb = ", hex(TEST_BENCH_HEX_VALS[i]), "vs.  MEM=", hex(MEM[i]))
        total += 1
    
    #print('values checked -> ', total)
    print('correctness = ', correct / total * 100, ' %')