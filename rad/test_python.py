# %%
import matplotlib.pyplot as plt

Ic = 236
t = 8e-6
w = 4e-3
L = 64e-3

Jc = Ic / (t * L)
print(f"Jc: {Jc/1e6}")

# %%
plt.plot([0, L], [0, 0], "k-")
plt.show()

