import math
import random
import matplotlib.pyplot as plt

size = 10002
data = [] * size
mu = 9
sigma = 8

for i in range(size-1):
    data.append(random.gammavariate(mu, sigma))

print(max(data), min(data))
plt.hist(data, bins=100)
plt.savefig("abdonpanizz.png")