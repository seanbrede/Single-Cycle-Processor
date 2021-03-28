import collections     as col
import compile_helpers as chs
import sys


num_labels = 0
# var_index  = 2
# curr_tabs  = 0
# cf_stack   = []
# var_table  = col.defaultdict(lambda: -1)
imm_table  = chs.buildImmTable()


# write LUT_Imm.sv
chs.writeLUTImm(imm_table)


# parse each line of Python code
for read, write in chs.filenames:
    write_file = open(write, "w")
    var_index  = 2
    var_table  = col.defaultdict(lambda: -1)
    cf_stack   = []
    curr_tabs  = 0

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
            for i in range(curr_tabs - next_tabs):
                if cf_stack[len(cf_stack) - 1][0:5] == "label":
                    chs.writeWithTabs(0, write_file, "\n")
                    chs.writeWithTabs(curr_tabs - (1+i), write_file, cf_stack.pop())
                else:
                    chs.writeWithTabs(0, write_file, "\n")
                    chs.writeWithTabs(curr_tabs - i, write_file, cf_stack.pop())
            curr_tabs = next_tabs
        elif next_tabs > curr_tabs:
            curr_tabs = next_tabs

        # write the line of code as a comment above the instructions, with the correct number of tabs?
        writeme = ""
        for e in line:
            writeme = writeme + e + " "
        chs.writeWithTabs(0, write_file, "\n")
        chs.writeWithTabs(curr_tabs, write_file, "# " + writeme + "\n")

        # ASSIGNMENT
        if len(line) >= 2 and line[1] == "=":
            # add the variable if it doesn't exist
            # if var_table[line[0]] == -1 and not line[0] == 'mem[write_ptr]':
            if var_table[line[0]] == -1 and not (len(line[0]) >= 4 and line[0][0:4] == "mem["):
                var_table[line[0]] = var_index
                var_index += 1

            # mem[NUM/VAR] = NUM/VAR
            if len(line) == 3 and (len(line[0]) >= 4 and line[0][0:4] == "mem["):
                lhs, rhs = line[0][4:len(line[0])-1], line[2]
                # if lhs is a num, handle that
                if lhs.isdigit():
                    chs.writeWithTabs(curr_tabs, write_file, "LDT " + str(imm_table[lhs]) + "\n")
                    chs.writeWithTabs(curr_tabs, write_file, "MVH r1 r0\n")
                else:
                    chs.writeWithTabs(curr_tabs, write_file, "MVH r" + str(var_table[lhs]) + " r0\n")
                # if rhs is a num, handle that
                if rhs.isdigit():
                    chs.writeWithTabs(curr_tabs, write_file, "LDT " + str(imm_table[rhs]) + "\n")
                else:
                    chs.writeWithTabs(curr_tabs, write_file, "MVH r" + str(var_table[rhs]) + " r1\n")
                # now store
                chs.writeWithTabs(curr_tabs, write_file, "STR r0\n")

            # VAR = chs.redXOR(VAR)
            elif len(line) == 3 and (len(line[2]) >= 12 and line[2][0:11] == "chs.redxor("):
                lhs, var = line[0], line[2][11:len(line[2])-1]
                chs.writeWithTabs(curr_tabs, write_file, "RDX r" + str(var_table[var]) + "\n")
                chs.writeWithTabs(curr_tabs, write_file, "MVL r" + str(var_table[lhs]) + " r0\n")

            # VAR = mem[NUM/VAR]
            elif len(line) == 3 and (len(line[2]) >= 4 and line[2][0:4] == "mem["):
                mem_loc = line[2][4:len(line[2]) - 1]  # get the thing inside the brackets
                # if it's a num, handle it
                if mem_loc.isdigit():
                    chs.writeWithTabs(curr_tabs, write_file, "LDT " + str(imm_table[mem_loc]) + "\n")
                    chs.writeWithTabs(curr_tabs, write_file, "LOD r1\n")
                # else it's a var, handle that instead
                else:
                    chs.writeWithTabs(curr_tabs, write_file, "LOD r" + str(var_table[mem_loc]) + "\n")
                # move loaded value into the assigned variable's register
                chs.writeWithTabs(curr_tabs, write_file, "MVL r" + str(var_table[line[0]]) + " r1\n")

            # VAR = NUM/VAR
            elif len(line) == 3:
                # get each token
                lhs, rhs = line[0], line[2]
                # if the rhs is a num
                if rhs.isdigit():
                    chs.writeWithTabs(curr_tabs, write_file, "LDT " + str(imm_table[rhs]) + "\n")
                # else the rhs is a var
                else:
                    chs.writeWithTabs(curr_tabs, write_file, "MVH r" + str(var_table[rhs]) + " r1\n")
                # move the value to the assigned variable's register
                chs.writeWithTabs(curr_tabs, write_file, "MVL r" + str(var_table[lhs]) + " r1\n")

            # VAR = NUM/VAR OP NUM/VAR
            elif len(line) == 5:
                # get each token
                lhs, oper1, op, oper2 = line[0], line[2], line[3], line[4]
                # if oper1 is a NUM
                if oper1.isdigit():
                    chs.writeWithTabs(curr_tabs, write_file, "LDT " + str(imm_table[oper1]) + "\n")
                    chs.writeWithTabs(curr_tabs, write_file, "MVH r1 r0\n")
                # if oper1 is a VAR
                else:
                    chs.writeWithTabs(curr_tabs, write_file, "MVH r" + str(var_table[oper1]) + " r0\n")
                # if oper2 is a NUM
                if oper2.isdigit():
                    chs.writeWithTabs(curr_tabs, write_file, "LDT " + str(imm_table[oper2]) + "\n")
                # if oper2 is a VAR
                else:
                    chs.writeWithTabs(curr_tabs, write_file, "MVH r" + str(var_table[oper2]) + " r1\n")
                # if op is ADD, XOR, AND, SHIFT, OR
                if op == "+":
                    chs.writeWithTabs(curr_tabs, write_file, "ADD r0 r1\n")
                elif op == "^":
                    chs.writeWithTabs(curr_tabs, write_file, "XOR r0 r1\n")
                elif op == "&":
                    chs.writeWithTabs(curr_tabs, write_file, "AND r0 r1\n")
                elif op == "<<":
                    chs.writeWithTabs(curr_tabs, write_file, "SHL r0\n")
                elif op == "|":
                    chs.writeWithTabs(curr_tabs, write_file, "OR  r0 r1\n")
                # write the result back into the assigned variable's register
                chs.writeWithTabs(curr_tabs, write_file, "MVL r" + str(var_table[lhs]) + " r0\n")

        # IF VAR/NUM CMP VAR/NUM
        elif len(line) == 4 and line[0] == "if":
            # get each token
            oper1, cmp, oper2 = line[1], line[2], line[3][0:len(line[3])-1]  # take off the ":"
            # put a label into the stack
            cf_stack.append("label" + str(num_labels) + ":")
            # if oper1 is a NUM
            if oper1.isdigit():
                chs.writeWithTabs(curr_tabs, write_file, "LDT " + str(imm_table[oper1]) + "\n")
                chs.writeWithTabs(curr_tabs, write_file, "MVH r1 r0\n")
            # if oper1 is a VAR
            else:
                chs.writeWithTabs(curr_tabs, write_file, "MVH r" + str(var_table[oper1]) + " r0\n")
            # if oper2 is a NUM
            if oper2.isdigit():
                chs.writeWithTabs(curr_tabs, write_file, "LDT " + str(imm_table[oper2]) + "\n")
            # if oper2 is a VAR
            else:
                chs.writeWithTabs(curr_tabs, write_file, "MVH r" + str(var_table[oper2]) + " r1\n")
            # do comparison
            if cmp == "<":
                chs.writeWithTabs(curr_tabs, write_file, "SLT r0 r1\n")
            elif cmp == "==":
                chs.writeWithTabs(curr_tabs, write_file, "SEQ r0 r1\n")
            else:
                print(raw_line)
                sys.exit("error1!")
            # jump if necessary
            chs.writeWithTabs(curr_tabs, write_file, "JNE label" + str(num_labels) + "\n")
            num_labels += 1

        # WHILE
        elif len(line) == 4 and line[0] == "while":
            stackwrite = ""
            # get each token
            oper1, cmp, oper2 = line[1], line[2], line[3][0:len(line[3])-1]  # take off the ":"
            # put a label down
            chs.writeWithTabs(curr_tabs, write_file, "label" + str(num_labels) + ":")

            # if oper1 is a NUM
            if oper1.isdigit():
                stackwrite = stackwrite + "LDT " + str(imm_table[oper1]) + "\n"
                stackwrite = stackwrite + "MVH r1 r0\n"
            # if oper1 is a VAR
            else:
                stackwrite = stackwrite + "MVH r" + str(var_table[oper1]) + " r0\n"
            # if oper2 is a NUM
            if oper2.isdigit():
                stackwrite = stackwrite + "LDT " + str(imm_table[oper2]) + "\n"
            # if oper2 is a VAR
            else:
                stackwrite = stackwrite + "MVH r" + str(var_table[oper2]) + " r1\n"
            # do comparison
            if cmp == "<":
                stackwrite = stackwrite + "SLT r0 r1\n"
            elif cmp == "==":
                stackwrite = stackwrite + "SEQ r0 r1\n"
            else:
                print(raw_line)
                sys.exit("error2!")
            # jump if necessary
            stackwrite = stackwrite + "JE  label" + str(num_labels) + "\n"

            # put the comparison into the stack
            cf_stack.append(stackwrite)
            num_labels += 1

        # UNRECOGNIZED
        else:
            print(raw_line)
            sys.exit("error3!")

    # at the end of the file, if we're still inside of any if/whiles, we need to end them
    for _ in range(curr_tabs):
        if cf_stack[len(cf_stack)-1][0:5] == "label":
            chs.writeWithTabs(0, write_file, "\n")
            chs.writeWithTabs(curr_tabs-1, write_file, cf_stack.pop())
        else:
            chs.writeWithTabs(0, write_file, "\n")
            chs.writeWithTabs(curr_tabs, write_file, cf_stack.pop())

    # reset the number of tabs
    curr_tabs = 0

    # add ACK at the end
    chs.writeWithTabs(0, write_file, "\nACK")
    # TODO debug
    # print(var_table)

    # close the file that we've been writing to
    write_file.close()
