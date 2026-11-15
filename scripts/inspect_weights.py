import numpy as np

w = np.load("C:/Users/Sufiyan Sadiq/Desktop/work/cache/RV64/scripts/gpt2_weights/h.11.ln_1.bias.npy")
print(w.shape)    # (768, 2304)
print(w.dtype)    # float32
print(w.size)     # total number of values: 1,769,472
print(w)    # a single value: row 0, column 0