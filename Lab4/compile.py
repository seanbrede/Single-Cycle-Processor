import collections     as col
import compile_helpers as chs
import sys


num_vars  = 0
curr_tabs = 0
cf_stack  = []
var_table = col.defaultdict()
imm_table = chs.buildImmTable()


# write LUT_Imm.sv
chs.writeLUTImm(imm_table)


# parse each line of Python code
for read, write in chs.filenames:
    write_file = open(write, "w")

    # derp
    for line in open(read, "r"):
        line, next_tabs = chs.processLine(line)

        # IMPORT or PRINT
        if line[0] == "import" or (len(line[0]) > 4 and line[0][0:5] == "print"): continue

        # BLANK or COMMENT
        if not line: continue

        # END IF or END WHILE
        if next_tabs < curr_tabs:
            # take the next if/while end out of the cf_stack and write it to the file
            # TODO make sure it prints the correct number of tabs?
            for _ in range(curr_tabs - next_tabs):
                nextwrite = cf_stack.pop()
                write_file.write(nextwrite)
            curr_tabs = next_tabs

        # TODO write the line of code as a comment, with the correct number of tabs
        pass

        # ASSIGNMENT
        if len(line[1]) > 1 and line[1] == "=":
            # add the reference if it doesn't exist
            if var_table[line[0]]["index"] == -1:
                var_table[line[0]]["index"] = num_vars
                num_vars += 1
            # TODO var = mem[num]
            pass
            # TODO var = num
            pass
            # TODO var = num/var op num/var
            pass

        # IF
        elif len(line) == 4 and line[0] == "if":
            # TODO
            pass

        # WHILE
        elif len(line) == 4 and line[0] == "while":
            # TODO
            pass

        # UNRECOGNIZED
        else:
            sys.exit("error!")

    # at the end of the file, if we're still inside of any if/whiles, we need to end them
    # TODO make sure it prints the correct number of tabs?
    for _ in range(curr_tabs):
        nextwrite = cf_stack.pop()
        write_file.write(nextwrite)

    # close the file that we've been writing to
    write_file.close()
