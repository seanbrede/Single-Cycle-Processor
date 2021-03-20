import collections as col
import sys


tap_LUT   = [0x60, 0x48, 0x78, 0x72, 0x6A, 0x69, 0x5C, 0x7E, 0x7B]
filenames = [("program1.py", "program1.as"),
             ("program2.py", "program2.as"),
             ("program3.py", "program3.as")]


# deal with comments, formatting, capitalization
def processLine(line):
    line      = line.split("#")[0]                  # remove comments
    next_tabs = len(line) - len(line.lstrip('\t'))  # count the number of tabs
    if len(line) > 0 and line[0] == " ":
        next_tabs = int((len(line) - len(line.lstrip(" "))) / 4)
    line      = line.strip()                        # remove leading and trailing whitespace
    line      = line.lower().split()                # lowercase and then split
    return line, next_tabs


# create the table that links immediate values to an index, from each of the 3 program files
def buildImmTable():
    imm_table = col.defaultdict(lambda: -1)
    num_imms  = 0
    for read, _ in filenames:
        imm_table, num_imms = addImmEntries(read, imm_table, num_imms)
    return imm_table


# put immediate entries from the file into the table
def addImmEntries(file, imm_table, num_imms):
    for line in open(file, "r"):
        line, _ = processLine(line)  # split line into tokens

        # ASSIGNMENT
        if len(line) > 2 and line[1] == "=":
            # VAR = mem[NUM]
            if len(line[2]) >= 4 and line[2][0:3] == "mem":
                possible_int = line[2][4:len(line[2])-1]
                if possible_int.isdigit() and imm_table[possible_int] == -1:
                    imm_table[possible_int] = num_imms
                    num_imms += 1
            # identifier = int
            if line[2].isdigit() and imm_table[line[2]] == -1:
                imm_table[line[2]] = num_imms
                num_imms += 1
            # identifier = int? op int?
            if len(line) == 5:
                if line[2].isdigit() and imm_table[line[2]] == -1:
                    imm_table[line[2]] = num_imms
                    num_imms += 1
                if line[4].isdigit() and imm_table[line[4]] == -1:
                    imm_table[line[4]] = num_imms
                    num_imms += 1

        # IF or WHILE
        if len(line) == 4 and (line[0] == "if" or line[0] == "while"):
            oper1, oper2 = line[1], line[3][0:len(line[3])-1]
            if oper1.isdigit() and imm_table[oper1] == -1:
                imm_table[oper1] = num_imms
                num_imms += 1
            if oper2.isdigit() and imm_table[oper2] == -1:
                imm_table[oper2] = num_imms
                num_imms += 1

    return imm_table, num_imms


# write LUT_Imm.sv based off of the table
def writeLUTImm(imm_table):
    table_size = len(imm_table)
    if table_size > 32: sys.exit("TERMINATING: LUT_Imm size " + str(table_size) + " exceeds maximum: 32")
    file = open("LUT_Imm.sv", "w")

    # turn imm_table into a list
    imm_list = [None] * table_size
    for imm in imm_table.keys():
        imm_list[imm_table[imm]] = imm

    # write everything up to the immediates
    file.write("module LUT_Imm (\n"                  +
                  "\tinput        [4:0] index,\n"    +
                  "\toutput logic [7:0] immediate\n" +
                  ");\n"                             +
                  "always_comb\n"                    +
                  "\tcase (index)\n")

    # write each address
    for i in range(table_size):
        if i < 10:
            file.write("\t\t5'd" + str(i) + ":    immediate = 8'd" + str(imm_list[i]) + ";\n")
        else:
            file.write("\t\t5'd" + str(i) + ":   immediate = 8'd" + str(imm_list[i]) + ";\n")

    # write everything else
    file.write("\t\tdefault: immediate = 8'd255;\n" +
                  "\tendcase\n"                     +
                  "endmodule")

    file.close()


# reduction xor
def redXOR(red):
    par = 0
    while red != 0:
        par = par + 1
        red = red & (red - 1)
    par = par % 2
    if par > 0:
        return 1
    else:
        return 0


# write a line with a certain number of tabs at the front
def writeWithTabs(num_tabs, write_file, towrite):
    if len(towrite.split("\n")) == 5:
        towrite = towrite.split("\n")
        for i in range(len(towrite)):
            if i == len(towrite) - 1:
                write_file.write(("\t" * num_tabs) + towrite[i])
            else:
                write_file.write(("\t" * num_tabs) + towrite[i] + "\n")
    else:
        write_file.write(("\t" * num_tabs) + towrite)


# set up the memory for program1
def initMemory1():
    MEM = ([32] * 54) + ([0] * (256 - 54))  # initialize the array

    MEM[61] = 10  # number of spaces
    MEM[62] = 5   # LFSR tap pattern index
    MEM[63] = 1   # LFSR initial state

    # embed the tap_LUT in MEM[128:137]
    for i in range(len(tap_LUT)):
        MEM[i + 128] = tap_LUT[i]

    # set the plaintext message
    message = "Mr. Watson, come here. I want to see you."
    for i in range(len(message)):
        MEM[i] = ord(message[i])  # convert character literal to int

    return MEM


# set up the memory for program2
def initMemory2():
    MEM = [0] * 256  # initialize the array

    # embed the tap_LUT in MEM[128:137]
    for i in range(len(tap_LUT)):
        MEM[i + 128] = tap_LUT[i]

    # set the encrypted message; output of program1
    enc_message = [33, 163, 39, 175, 190, 29, 219, 86, 204, 249, 126, 20, 226, 184, 102, 3, 48, 250, 125, 202, 101, 51,
                   68, 33, 113, 92, 83, 15, 170, 237, 219, 210, 89, 187, 68, 63, 113, 78, 53, 34, 240, 231, 177, 80,
                   163, 232, 58, 204, 5, 160, 132, 116, 9, 243, 6, 237, 187, 150, 77, 250, 20, 201, 114, 5]
    for i in range(len(enc_message)):
        MEM[64 + i] = enc_message[i]

    return MEM
