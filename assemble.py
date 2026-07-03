# Tiny MIPS assembler - prints hex
def R(rs,rt,rd,funct,shamt=0): 
    return (0<<26)|(rs<<21)|(rt<<16)|(rd<<11)|(shamt<<6)|funct
def I(op,rs,rt,imm): 
    return (op<<26)|(rs<<21)|(rt<<16)|(imm & 0xFFFF)
def J(op,addr): 
    return (op<<26)|(addr & 0x3FFFFFF)

ADD,SUB,AND,OR,SLT = 0x20,0x22,0x24,0x25,0x2a
LW,SW,BEQ,JOP = 0x23,0x2b,0x04,0x02

prog = [
    R(8,9,10,ADD),        # 0: add  $t2,$t0,$t1   -> 30
    R(9,8,11,SUB),        # 1: sub  $t3,$t1,$t0   -> 10
    R(8,9,12,AND),        # 2: and  $t4,$t0,$t1   -> 10&20
    R(8,9,13,OR ),        # 3: or   $t5,$t0,$t1   -> 10|20
    R(8,9,14,SLT),        # 4: slt  $t6,$t0,$t1   -> 1
    I(SW,0,10,0),         # 5: sw   $t2,0($zero)  -> mem[0]=30
    I(LW,0,15,0),         # 6: lw   $t7,0($zero)  -> $t7=30
    I(BEQ,8,8,2),         # 7: beq  $t0,$t0,+2    -> taken
    R(8,9,16,ADD),        # 8: add $s0
    R(8,9,17,ADD),        # 9: add $s1
    R(10,15,18,SUB),      # 10: sub $s2,$t2,$t7   -> 30-30=0 
    J(JOP,12),            # 11: j   12 
    R(0,0,0,ADD),         # 12: nop (add $zero) - halt-ish loop target
]
for i,w in enumerate(prog):
    print(f"{w & 0xFFFFFFFF:08x}  => {i}")