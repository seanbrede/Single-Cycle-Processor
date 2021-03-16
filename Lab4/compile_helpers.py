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
def redXOR(red):
    par = 0
    while red != 0:
        par = par + 1
        red = red & (red - 1)
    par = par % 2
    if par == 1: return 128
    else:        return 0


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
