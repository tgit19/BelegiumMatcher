import os
import sys
import random

wNum = 4
pNum = 4
if len(sys.argv) == 3:
    wNum = int(sys.argv[1])
    pNum = int(sys.argv[2])

with open('rand4x4.csv', 'w+') as f:
    f.write(';')
    for i in range(0, wNum):
        f.write(f"w{i};")
    
    for j in range(0, pNum):
        f.write('\n')
        f.write(f"p{j};")
        for i in range(0, wNum):
            f.write(f"{random.randrange(0, 16)};")

    f.write("\n\n;")
    for i in range(0, pNum):
        f.write(f"p{i};")
    for j in range(0, wNum):
        f.write('\n')
        f.write(f"w{j};")
        for i in range(0, pNum):
            f.write(f"{random.randrange(0, 16)};")
