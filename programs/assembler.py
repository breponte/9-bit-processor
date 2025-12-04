""" """ """ """ """ """ """ """" FUNCTIONS """" """ """ """ """ """ """ """ 
def translate_opcode(opcode):
    """
    Given an opcode, convert it to the corresponding machine code
    """
    match opcode.lower():
        case "add":
            return "100"
        case "and":
            return "000"
        case "xor":
            return "001"
        case "slt":
            return "010"
        case "bnz":
            return "011"
        case "ror":
            return "101"
        case "ldr":
            return "110"
        case "str":
            return "111"
        case _:
            # unrecognized opcode
            return "???"

def translate_reg(reg):
    """
    Given a register, convert it to the corresponding machine code
    """
    reg = reg.lower()
    reg = reg.replace("r", "")
    try:
        return f'{int(reg):03b}'
    except:
        return "???"

def translate_immed(immed):
    """
    Given an immediate, convert it to the corresponding machine code
    """
    try:
        # check if valid input, convert to binary if valid
        immed = int(immed)
        if (immed >= 0 or immed <= 7):
            return f'{immed:03b}'
        else:
            return "???"
    except:
        return "???"


""" """ """ """ """ """ """ """" MAIN """" """ """ """ """ """ """ """ 
# prepare input/output files
assembly_code = open("assembly_code.txt", "r")
machine_code = open("mach_code.txt", "w")

# read from assembly
assembly = assembly_code.readlines()
machine = []
# translate assembly into machine code
for line in assembly:
    insn = line.split()
    if (len(insn) == 3):
        machine.append("".join([translate_opcode(insn[0]),
                                translate_reg(insn[1]),
                                translate_immed(insn[2]),
                                "\n"]))

# write to machine code file
machine_code.writelines(machine)

