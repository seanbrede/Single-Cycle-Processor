import collections     as col
import compile_helpers as chs
import sys


num_vars  = 0
var_table = col.defaultdict()
imm_table = chs.buildImmTable()
programs  = ["program1", "program2", "program3"]


# write LUT_Imm.sv
chs.writeLUTImm(imm_table)


# parse each line of Python code
for program in programs:
    for line in open(program + ".py", "r"):
        line = chs.processLine(line)

        # TODO skip lines with import or print
        if 0 < 1:
            pass

        # BLANK LINE OR ONLY COMMENT
        if not line: continue

        # ASSIGNMENT
        if line[1] == "=":
            # add the reference if it doesn't exist
            if var_table[line[0]]["index"] == -1:
                var_table[line[0]]["index"] = num_vars
                num_vars += 1

            # TODO then if
            pass

        # IF

        # TODO error
        else:
            sys.exit("error!")
