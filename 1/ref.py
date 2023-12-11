from pathlib import Path

input = \
    """plckvxznnineh34eight2"""
# input = open('input.txt', 'r').read()

spelled = [
    "one",    "two",    "three", 
    "four",   "five",   "six",
    "seven",  "eight",  "nine"
]
digits = "123456789"

total = 0

for line in input.split("\n"):
    p = 0
    nums = []
    while p < len(line):
        for digit in digits:
            if line.startswith(digit, p):
                nums.append(digits.index(digit)+1)
                break
        else:
            for word in spelled:
                if line.startswith(word, p):
                    nums.append(spelled.index(word)+1)
                    break
        p += 1
    total += nums[0] * 10 + nums[-1]

print(F"sum: {total}")