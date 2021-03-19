import collections     as col
import compile_helpers as chs
import sys


num_labels = 0
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
                write_file.write(cf_stack.pop())
            curr_tabs = next_tabs
        elif next_tabs > curr_tabs:
            curr_tabs = next_tabs

        # TODO write the line of code as a comment above the instructions, with the correct number of tabs?
        pass

        # ASSIGNMENT
        if len(line) >= 2 and line[1] == "=":
            # add the variable if it doesn't exist
            if var_table[line[0]] == -1:
                var_table[line[0]] = var_index
                var_index += 1

            # mem[NUM/VAR] = NUM/VAR
            if len(line) == 3 and (len(line[0]) >= 5 and line[0][0:5] == "mem["):
                lhs, rhs = line[0][4:len(line[0])-1], line[2]
                # if lhs is a num, handle that
                if lhs.isdigit():
                    write_file.write("LDT " + str(imm_table[lhs]) + "\n")
                    write_file.write("MVH 1 0\n")
                else:
                    write_file.write("MVH " + str(var_table[lhs]) + " 0\n")
                # if rhs is a num, handle that
                if rhs.isdigit():
                    write_file.write("LDT " + str(imm_table[rhs]) + "\n")
                else:
                    write_file.write("MVH " + str(var_table[rhs]) + " 1\n")
                # now store
                write_file.write("STR 0")

            # VAR = chs.redXOR(VAR)
            elif len(line) == 3 and (len(line[2]) >= 12 and line[2][0:12] == "chs.redXOR("):
                lhs, var = line[0], line[2][12:len(line[2])-1]
                write_file.write("RDX " + str(var_table[var]) + "\n")
                write_file.write("MVL " + str(var_table[lhs]) + " 0\n")

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
                # move loaded value into the assigned variable's register
                write_file.write("MVL " + str(var_table[line[0]]) + " 1\n")  # TODO make sure this is correct later

            # VAR = NUM/VAR
            elif len(line) == 3:
                # get each token
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

            # VAR = NUM/VAR OP NUM/VAR
            elif len(line) == 5:
                # get each token
                lhs, oper1, op, oper2 = line[0], line[2], line[3], line[4]
                # if oper1 is a NUM
                if oper1.isdigit():
                    write_file.write("LDT " + str(imm_table[oper1]) + "\n")
                    write_file.write("MVH 1 0\n")
                # if oper1 is a VAR
                else:
                    write_file.write("MVH " + str(var_table[oper1]) + " 0\n")
                # if oper2 is a NUM
                if oper2.isdigit():
                    write_file.write("LDT " + str(imm_table[oper2]) + "\n")
                # if oper2 is a VAR
                else:
                    write_file.write("MVH " + str(var_table[oper2]) + " 1\n")
                # if op is ADD, XOR, AND, SHIFT, OR
                if op == "+":
                    write_file.write("ADD 0 1\n")
                elif op == "^":
                    write_file.write("XOR 0 1\n")
                elif op == "&":
                    write_file.write("AND 0 1\n")
                elif op == "<<":
                    write_file.write("SHL 0\n")
                elif op == "|":
                    write_file.write("OR 0 1\n")
                # write the result back into the assigned variable's register
                write_file.write("MVL " + str(var_table[lhs]) + " 0\n")

        # IF VAR/NUM CMP VAR/NUM
        elif len(line) == 4 and line[0] == "if":
            # get each token
            oper1, cmp, oper2 = line[1], line[2], line[3][0:len(line[3])-1]  # take off the ":"
            # put a label into the stack
            cf_stack.append("label" + str(num_labels) + ":")
            # if oper1 is a NUM
            if oper1.isdigit():
                write_file.write("LDT " + str(imm_table[oper1]) + "\n")
                write_file.write("MVH 1 0\n")
            # if oper1 is a VAR
            else:
                write_file.write("MVH " + str(var_table[oper1]) + " 0\n")
            # if oper2 is a NUM
            if oper2.isdigit():
                write_file.write("LDT " + str(imm_table[oper2]) + "\n")
            # if oper2 is a VAR
            else:
                write_file.write("MVH " + str(var_table[oper2]) + " 1\n")
            # do comparison
            if cmp == "<":
                write_file.write("SLT 1 0\n")
            elif cmp == "==":
                write_file.write("SEQ 1 0\n")
            else:
                sys.exit("error1!")
            # jump if necessary
            write_file.write("JNE label" + str(num_labels) + "\n")
            num_labels += 1

        # WHILE
        elif len(line) == 4 and line[0] == "while":
            stackwrite = ""
            # get each token
            oper1, cmp, oper2 = line[1], line[2], line[3][0:len(line[3])-1]  # take off the ":"
            # put a label down
            write_file.write("label" + str(num_labels) + ":")

            # if oper1 is a NUM
            if oper1.isdigit():
                stackwrite = stackwrite + "LDT " + str(imm_table[oper1]) + "\n"
                stackwrite = stackwrite + "MVH 1 0\n"
            # if oper1 is a VAR
            else:
                stackwrite = stackwrite + "MVH " + str(var_table[oper1]) + " 0\n"
            # if oper2 is a NUM
            if oper2.isdigit():
                stackwrite = stackwrite + "LDT " + str(imm_table[oper2]) + "\n"
            # if oper2 is a VAR
            else:
                stackwrite = stackwrite + "MVH " + str(var_table[oper2]) + " 1\n"
            # do comparison
            if cmp == "<":
                stackwrite = stackwrite + "SLT 1 0\n"
            elif cmp == "==":
                stackwrite = stackwrite + "SEQ 1 0\n"
            else:
                sys.exit("error1!")
            # jump if necessary
            stackwrite = stackwrite + "JE label" + str(num_labels) + "\n"

            # put the comparison into the stack
            cf_stack.append(stackwrite)
            num_labels += 1

        # UNRECOGNIZED
        else:
            sys.exit("error2!")

    # at the end of the file, if we're still inside of any if/whiles, we need to end them
    # TODO make sure it prints the correct number of tabs?
    for _ in range(curr_tabs):
        write_file.write(cf_stack.pop())

    # close the file that we've been writing to
    write_file.close()
