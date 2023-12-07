import math
 
with open("input.txt") as file:
    lines = file.readlines()
 
time_values = list(map(int, lines[0].split()[1:]))
distance_values = list(map(int, lines[1].split()[1:]))



total = 1
for t, d in zip(time_values, distance_values):
    count = 0
    for x in range(t):
        if x * (t - x) > d:
            count += 1
    print(F"T = {t}, D = {d}, W = {count}")
    total *= count

print(total)


# def count_wins(self):
#     x1 = math.ceil((self.time / 2) - math.sqrt((self.time / 2) ** 2 - self.winning_distance))
#     x2 = math.floor((self.time / 2) + math.sqrt((self.time / 2) ** 2 - self.winning_distance))

#     return x2 - x1 + 1