# assemble.py: turns valid assembly code into machine code; if not valid, produces errors
import sys      # for exit()
import helpers  # helper functions and definitions


line      = 0  # keep track of the line number, mostly for errors
inst_addr = 0  # how many operations have been parsed

addr_table = helpers.processLabels("assembly_code.txt")  # create a table of {label: address}
m_code     = open("machine_code.txt", "w")              # will create the file if it doesn't exist


# parse each line of assembly
for raw_inst in open("assembly_code.txt", "r"):
    line += 1                                     # increment the line number at the beginning
    inst  = helpers.processInstruction(raw_inst)  # operation as inst[0]; operands as inst[1], inst[2]

    # BLANK LINE OR ONLY COMMENT
    if not inst: continue

    # OPERATION
    if inst[0] in helpers.ops_dict.keys():  # if operation exists in the dictionary
        to_write = helpers.decodeInstruction(inst, raw_inst, addr_table, line)
        m_code.write(to_write)
        inst_addr += 1  # instruction address only increases from operations

    # LABEL
    elif inst[0].find(":") == len(inst[0]) - 1:  # only one colon, and it must be at the end
        continue

    # UNRECOGNIZED
    else:
        sys.exit("TERMINATING: operation on line " + str(line) + " not recognized: " + inst[0])


helpers.buildLUTAdd(addr_table)  # generate LUT_Add.sv
m_code.close()                   # close machine code

