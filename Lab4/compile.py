import collections     as col
import compile_helpers as chs
import sys


num_refs  = 0
ref_table = col.defaultdict()
imm_table = chs.buildImmTable()
programs  = ["program1", "program2", "program3"]


# parse each line of Python code
for program in programs:
    for line in open(program + ".py", "r"):
        line  = chs.processLine(line)

        # TODO skip lines with import or print
        if 0 < 1:
            pass

        # BLANK LINE OR ONLY COMMENT
        if not inst: continue

        # ASSIGNMENT
        if inst[1] == "=":
            # add the reference if it doesn't exist
            if ref_table[inst[0]]["index"] == -1:
                ref_table[inst[0]]["index"] = num_refs
                num_refs += 1

            # TODO then if
            pass

        # IF

        # TODO error
        else:
            sys.exit("error!")


# write LUT_Imm.sv
chs.writeLUTImm(imm_table)
