import collections     as col
import compile_helpers as chs
import sys


var_index  = 2
curr_tabs  = 0
cf_stack   = []
var_table  = col.defaultdict(lambda: -1)
imm_table  = chs.buildImmTable()  # TODO probably want to modify this to have all keys be strings


# write LUT_Imm.sv
chs.writeLUTImm(imm_table)


# parse each line of Python code
for read, write in chs.filenames:
    write_file = open(write, "w")

    # look at each line of Python code
    for raw_line in open(read, "r"):
        line, next_tabs = chs.processLine(raw_line)

        # BLANK or COMMENT
        if not line: continue

        # IMPORT or PRINT
        if line[0] == "import" or (len(line[0]) >= 5 and line[0][0:5] == "print"): continue

        # END IF or END WHILE
        if next_tabs < curr_tabs:
            # take the next if/while end out of the cf_stack and write it to the file
            # TODO make sure it prints the correct number of tabs?
            for _ in range(curr_tabs - next_tabs):
                cf_write = cf_stack.pop()
                write_file.write(cf_write)
            curr_tabs = next_tabs

        # TODO write the line of code as a comment above the instructions, with the correct number of tabs?
        pass

        # ASSIGNMENT
        if len(line) >= 2 and line[1] == "=":
            # add the variable if it doesn't exist
            if var_table[line[0]] == -1:
                var_table[line[0]] = var_index
                var_index += 1

            # TODO mem[NUM/VAR] = NUM/VAR
            if len(line) == 3 and "herp" == "derp":
                pass

            # VAR = mem[NUM/VAR]
            elif len(line) == 3 and (len(line[2]) >= 4 and line[2][0:4] == "mem["):
                mem_loc = line[2][4:len(line[2]) - 1]  # get the thing inside the brackets
                # if it's a num, handle it
                if mem_loc.isdigit():
                    write_file.write("LDT " + str(imm_table[mem_loc]) + "\n")
                    write_file.write("LOD 1\n")
                # else it's a var, handle that instead
                else:
                    write_file.write("LOD " + str(var_table[mem_loc]) + "\n")
                # move loaded value back into the assigned variable's register
                write_file.write("MVL " + str(var_table[line[0]]) + " 1\n")  # TODO make sure this is correct later

            # VAR = NUM/VAR
            elif len(line) == 3:
                # get the tokens
                lhs, rhs = line[0], line[2]
                # if the rhs is a num
                if rhs.isdigit():
                    write_file.write("LDT " + str(imm_table[rhs]) + "\n")
                    write_file.write("LOD 1\n")
                # else the rhs is a var
                else:
                    write_file.write("MVH " + str(var_table[rhs]) + " 1\n")  # TODO make sure this is correct later
                # move the value to the assigned variable's register
                write_file.write("MVL " + str(var_table[lhs]) + " 1\n")      # TODO make sure this is correct later

            # TODO VAR = NUM/VAR OP NUM/VAR
            elif len(line) == 5:
                # get the tokens
                lhs, oper1, op, oper2 = line[0], line[2], line[3], line[4]
                # TODO do stuff
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
