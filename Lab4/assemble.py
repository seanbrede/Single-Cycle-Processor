# assemble.py: turns valid assembly code into machine code; if not valid, produces errors
import assemble_helpers as ash  # helper functions and definitions
import sys                      # for exit()


line      = 0  # keep track of the line number, mostly for errors
inst_addr = 0  # how many operations have been parsed


addr_table = ash.processLabels()  # create a table of {label: address}
ash.writeLUTAdd(addr_table)       # generate LUT_Add.sv


for file in ash.filenames:
    m_code = open(file[1], "w")  # changes .as to .mc; will create if does not exist

    # parse each line of assembly
    for a_inst in open(file[0], "r"):
        line += 1                               # increment the line number at the beginning
        inst  = ash.processInstruction(a_inst)  # operation as inst[0]; operands as inst[1], inst[2]

        # BLANK LINE OR ONLY COMMENT
        if not inst: continue

        # OPERATION
        if inst[0] in ash.ops_dict.keys():  # if operation exists in the dictionary
            m_inst = ash.decodeInstruction(inst, a_inst, addr_table, line)
            m_code.write(m_inst)
            inst_addr += 1  # instruction address only increases from operations

        # LABEL
        elif inst[0].find(":") == len(inst[0]) - 1:  # only one colon, and it must be at the end
            continue

        # UNRECOGNIZED
        else:
            sys.exit("TERMINATING: operation on line " + str(line) + " not recognized: " + inst[0])

    m_code.close()  # close machine code
