from pathlib import Path

def solutions():
    nums = {'one': '1', 'two': '2', 'three': '3', 'four': '4', 'five': '5', 'six': '6', 'seven': '7', 'eight': '8', 'nine': '9'}
    digits = "123456789"
    data = open('input.txt', 'r').read().splitlines()[23:24]
    sol1, sol2 = 0, 0
    for line in data:
        minidx, maxidx = len(line), -1; l, r = "", ""
        for k in digits:
            if (li := line.find(k)) != -1 and li <= minidx:
                l, minidx = k, li
            if (ri := line.rfind(k)) != -1 and ri >= maxidx:
                r, maxidx = k, ri
        sol1 += int(''.join((l, r)))
        for k in nums:
            if (li := line.find(k)) != -1 and li <= minidx:
                l, minidx = k, li
            if (ri := line.rfind(k)) != -1 and ri >= maxidx:
                r, maxidx = k, ri
        sol2 += int(''.join((nums.get(l, l), nums.get(r, r))))
            
    return sol1, sol2

print(solutions())