To use the compiler, run compile.py; the script will take valid assembly code from assembly_code.txt and attempt to
translate it, putting the results into machine_code.txt. If there's a problem, a relevant error will be printed and the
program will exit.



example of a valid assembly_code.txt:

# you can write comments like this
# comments # with # lots # of # pound # signs # still # work
add r14 r1               # comments on the same line as code work too
      AdD     r1       R0# this line will work despite weird capitalization and spacing


# blank lines will be ignored during compilation