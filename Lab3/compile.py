# compile.py: turns valid assembly code into machine code, else errors
import sys  # for exit()
import he   # for ops_dict

line          = 0                       # keep track of the line number
op_num        = 0                       # keep track of how many operations
address_table = {}                      #
m_code = open("machine_code.txt", "w")  # create the file if it doesn't exist

for inst in open("assembly_code.txt", "r"):
    line += 1
    inst = inst.split("#")[0]  # remove comments
    inst = inst.strip()        # remove leading and trailing whitespace
    if inst == "": continue    # line was blank or only a comment, go to next line

    inst = inst.lower().split()  # split instruction into its components

    # OPERATION
    if inst[0] in he.ops_dict.keys():  # if operation exists in the dictionary
        op_num += 1

        # Register Split type
        if he.ops_dict[inst[0]][0] == "RS":
            if len(inst) != 3: sys.exit("TERMINATING: operation on line " + str(line) + " has improper number of operands: " + str(len(inst) - 1))
            m_code.write(he.ops_dict[inst[0]][1])        # write the opcode
            R1_int = 
            R2_int =
            m_code.write(he.intToBinaryString(inst[1]))  # write the binary of the first register
            m_code.write(he.intToBinaryString(inst[2]))  # write the binary of the second register

        # Register Full type
        if he.ops_dict[inst[0]][0] == "RF":
            if len(inst) != 2: sys.exit("TERMINATING: operation on line " + str(line) + " has improper number of operands: " + str(len(inst) - 1))
            m_code.write(he.ops_dict[inst[0]][1])
            # TODO

        # IMmediate type
        if he.ops_dict[inst[0]][0] == "IM":
            if len(inst) != 2: sys.exit("TERMINATING: operation on line " + str(line) + " has improper number of operands: " + str(len(inst) - 1))
            m_code.write(he.ops_dict[inst[0]][1])
            # TODO

        # Instruction Only type
        if he.ops_dict[inst[0]][0] == "IO":
            if len(inst) != 1: sys.exit("TERMINATING: operation on line " + str(line) + " has improper number of operands: " + str(len(inst) - 1))
            m_code.write(he.ops_dict[inst[0]][1])
            # TODO

    # LABEL
    elif inst[0].find(":") == len(inst[0]):  # if the first colon is at the end
        pass

    # UNRECOGNIZED
    else:
        # TODO write error into file?
        sys.exit("TERMINATING: operation on line " + str(line) + " not recognized: " + inst[0])

m_code.close()
