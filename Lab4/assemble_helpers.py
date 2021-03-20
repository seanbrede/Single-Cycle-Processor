# assemble_helpers.py: helper definitions and functions for assemble.py
import collections as col  # for defaultdict()
import sys                 # for exit()


# create a table of {operation: [type, opcode]}
ops_dict = {
    "add": ["RS", "0000"],
    "rdx": ["RF", "0001"],
    "xor": ["RS", "0010"],
    "and": ["RS", "0011"],
    "shl": ["RF", "0100"],
    "ldt": ["IM", "0101"],
    "lod": ["RF", "0110"],
    "str": ["RF", "0111"],
    "mvh": ["RS", "1000"],
    "mvl": ["RS", "1001"],
    "je":  ["IM", "1010"],
    "slt": ["RS", "1011"],
    "seq": ["RS", "1100"],
    "ack": ["IO", "1101"],
    "or":  ["RS", "1110"],
    "jne": ["IM", "1111"]
}

# names of input and output files
filenames = [("program1.as", "program1.txt"),
             ("program2.as", "program2.mc"),
             ("program3.as", "program3.mc")]


# deal with comments, formatting, capitalization
def processInstruction(inst):
    inst = inst.split("#")[0]    # remove comments by getting rid of everything after the first "#"
    inst = inst.strip()          # remove leading and trailing whitespace
    inst = inst.lower().split()  # lowercase and then split
    return inst                  # inst[0] is operation, inst[1], inst[2] are operands


# build a table of {label: {"index": int, "address": int}} from the files ahead of time
def processLabels():
    addr_table = col.defaultdict(lambda: {"index": -1, "address": -1})
    num_labels = 0

    # parse each line of assembly
    for a_code, _ in filenames:
        line      = 0
        inst_addr = 0
        for inst in open(a_code, "r"):
            line += 1                        # increment the line number at the beginning of each line
            inst = processInstruction(inst)  # inst[0] is operation, inst[1], inst[2] are operands

            # BLANK LINE OR ONLY COMMENT
            if not inst: continue

            # OPERATION
            if inst[0] in ops_dict.keys(): inst_addr += 1  # instruction address only increases from operations

            # LABEL
            elif inst[0].find(":") == len(inst[0]) - 1:  # must have a single colon, and it must be at the end
                label = inst[0][:(len(inst[0]) - 1)]
                if addr_table[label]["address"] == -1:  # error if it isn't the default
                    addr_table[label]["address"] = inst_addr
                    addr_table[label]["index"]   = num_labels
                    num_labels += 1

                else:
                    sys.exit("TERMINATING: label on line " + str(line) + " has already been defined")

    return addr_table  # {label: {"index": int, "address": int}}


def intToBinaryString(num, num_bits):
    # convert while doing error checking
    if num >= 2 ** num_bits: sys.exit("TERMINATING: " + str(num) + " too big to fit in " + str(num_bits) + " bits.")
    binary_string = ("{0:0" + str(num_bits) + "b}").format(num)
    return binary_string


# builds LUT_Add.sv from the table of {label: address}
def writeLUTAdd(addr_table):
    table_size = len(addr_table)
    if table_size > 32: sys.exit("TERMINATING: LUT_Add size " + str(table_size) + " exceeds maximum: 32")
    file = open("../Lab2/LUT_Add.sv", "w")

    # turn addr_table into a list
    addr_list = [None] * table_size
    for label in addr_table.keys():
        addr_list[addr_table[label]["index"]] = addr_table[label]["address"]

    # write everything up to the addresses
    file.write("module LUT_Add (\n"                +
                  "\tinput        [4:0] index,\n"  +
                  "\toutput logic [9:0] address\n" +
                  ");\n"                           +
                  "always_comb\n"                  +
                  "\tcase (index)\n")

    # write each address
    for i in range(table_size):
        if i < 10:
            file.write("\t\t5'd" + str(i) + ":    address = 10'd" + str(addr_list[i]) + ";\n")
        else:
            file.write("\t\t5'd" + str(i) + ":   address = 10'd" + str(addr_list[i]) + ";\n")

    # write everything else
    file.write("\t\tdefault: address = 10'd1023;\n" +
                  "\tendcase\n"                     +
                  "endmodule")

    file.close()


def decodeInstruction(inst, raw_inst, addr_table, line):
    # use the operation to get the opcode from the dictionary, then write the opcode
    to_write = ops_dict[inst[0]][1]

    # Register Split type
    if ops_dict[inst[0]][0] == "RS":
        if len(inst) != 3: sys.exit("TERMINATING: operation on line " + str(line) + " has improper number of operands: " + str(len(raw_inst) - 1))

        # parse both operands as ints while checking for errors
        if inst[1].find("r") == 0:  # register operands must start with "r"
            op1_int = int(inst[1][1:])  # convert index from string to int; error if not convertible
        else:
            sys.exit("TERMINATING: operand on line " + str(line) + " is not a valid register identifier: " + inst[1])
        if inst[2].find("r") == 0:  # register operands must start with "r"
            op2_int = int(inst[2][1:])  # convert index from string to int; error if not convertible
        else:
            sys.exit("TERMINATING: operand on line " + str(line) + " is not a valid register identifier: " + inst[2])

        # convert both register indices from int to binary string and write them
        to_write += intToBinaryString(op1_int, 4)
        to_write += intToBinaryString(op2_int, 1)

    # Register Full type
    elif ops_dict[inst[0]][0] == "RF":
        if len(inst) != 2: sys.exit("TERMINATING: operation on line " + str(line) + " has improper number of operands: " + str(len(raw_inst) - 1))

        # parse the register index as an int while checking for errors
        if inst[1].find("r") == 0:  # register operands must start with "r"
            op1_int = int(inst[1][1:])  # convert index from string to int; error if not convertible
        else:
            sys.exit("TERMINATING: operand on line " + str(line) + " is not a valid register identifier: " + raw_inst[1])

        # convert the register index from int to binary string and write it with an extra 0
        to_write += intToBinaryString(op1_int, 4) + "0"

    # IMmediate type
    elif ops_dict[inst[0]][0] == "IM":
        if len(inst) != 2: sys.exit("TERMINATING: operation on line " + str(line) + " has improper number of operands: " + str(len(inst) - 1))

        # if the instruction is je
        if inst[0] == "je":
            if addr_table[inst[1]]["address"] != -1:
                to_write += intToBinaryString(addr_table[inst[1]]["index"], 5)
            else:
                print("1 " + inst[1])
                print(addr_table)
                sys.exit("TERMINATING: label referred to on line " + str(line) + " has not been defined")
        # if the instruction is jne
        elif inst[0] == "jne":
            if addr_table[inst[1]]["address"] != -1:
                to_write += intToBinaryString(addr_table[inst[1]]["index"], 5)
            else:
                print("2 " + inst[1])
                print(addr_table)
                sys.exit("TERMINATING: label referred to on line " + str(line) + " has not been defined")
        else:
            to_write += intToBinaryString(int(inst[1]), 5)

    # Instruction Only type
    elif ops_dict[inst[0]][0] == "IO":
        if len(inst) != 1: sys.exit("TERMINATING: operation on line " + str(line) + " has improper number of operands: " + str(len(inst) - 1))

        # use the operation to get the opcode from the dictionary, then write the opcode with 5 extra 0s
        to_write += "00000"

    # finish with a newline and return
    to_write += "\n"
    return to_write
