# he.py: helper definitions and functions for compile.py
import sys


# dictionary that connects an operation to its type and opcode
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
    "jeq": ["IM", "1010"],
    "slt": ["RS", "1011"],
    "seq": ["RS", "1100"],
    "ack": ["IO", "1101"],
    "gbt": ["RF", "1110"],
    "sbt": ["IO", "1111"]
}


# builds LUT_Add.sv from a list of label addresses
def build_LUT_Add_file(addresses):
    if len(addresses) > 32: sys.exit("TERMINATING: LUT_Add size " + str(len(addresses)) + " exceeds maximum: 32")
    LUT_Add = open("LUT_Add.sv", "w")

    # write everything up to the addresses
    LUT_Add.write("module LUT_Add (\n"             +
                  "\tinput        [4:0] index,\n"  +
                  "\toutput logic [9:0] address\n" +
                  ");\n"                           +
                  "always_comb\n"                  +
                  "\tcase (index)\n")

    # write each address
    for i in range(addresses):
        LUT_Add.write("\t\t5'd" + str(i) + ":   address = 10'd" + str(addresses[i]) + ";\n")

    # write everything else
    LUT_Add.write("\t\tdefault: address = 10'd1023;\n" +
                  "\tendcase\n"                        +
                  "endmodule")

    LUT_Add.close()
