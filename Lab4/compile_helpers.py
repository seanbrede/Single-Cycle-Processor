import collections as col


tap_LUT   = [0x60, 0x48, 0x78, 0x72, 0x6A, 0x69, 0x5C, 0x7E, 0x7B]
filenames = ["program1.py", "program2.py", "program3.py"]


# deal with comments, formatting, capitalization
def processLine(line):
    line = line.split("#")[0]    # remove comments by getting rid of everything after the first "#"
    line = line.strip()          # remove leading and trailing whitespace
    line = line.lower().split()  # lowercase and then split
    return line                  # line is now properly tokenized


# create the table that links immediate values to an index, from each of the 3 program files
def buildImmTable():
    imm_table = col.defaultdict(lambda: -1)
    num_imms  = 0
    for file in filenames:
        imm_table, num_imms = addImmEntries(file, imm_table, num_imms)
    return imm_table


# put immediate entries from the file into the table
def addImmEntries(file, imm_table, num_imms):
    for line in open(file, "r"):
        line = processLine(line)  # split line into tokens

        # ASSIGNMENT
        if len(line) > 2 and line[1] == "=":
            # identifier = MEM[int]
            if line[2][0:3] == "mem":
                possible_int = line[2][2:len(line[2])-1]
                if possible_int.isdigit():
                    imm_table[int(possible_int)] = num_imms
                    num_imms += 1
            # identifier = int
            if line[2].is_digit():
                imm_table[int(line[2])] = num_imms
                num_imms += 1
            # identifier = int? op int?
            if len(line) == 5:
                if line[2].isdigit():
                    imm_table[int(line[2])] = num_imms
                    num_imms += 1
                if line[4].isdigit():
                    imm_table[int(line[4])] = num_imms
                    num_imms += 1

        # IF or WHILE
        if len(line) == 4 and (line[0] == "if" or line[0] == "while"):
            if line[1].isdigit():
                pass
            if line[3].isdigit():
                pass

    return imm_table, num_imms


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
    if par > 0: return 1
    else:       return 0


# set up the memory for program1
def initMemory1():
    MEM = ([32] * 54) + ([0] * (256 - 54))
    MEM[61] = 10          # number of spaces
    MEM[62] = tap_LUT[0]  # LFSR tap pattern
    MEM[63] = 64          # LFSR initial state
    message = "Mr. Watson, come here. I want to see you."
    for i in range(len(message)):
        MEM[i] = ord(message[i])  # convert character literal to int
    return MEM


def initMemory2():
    pass  # TODO


def initMemory3():
    pass  # TODO
