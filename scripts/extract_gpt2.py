import os
import numpy as np
from huggingface_hub import hf_hub_download
from safetensors.numpy import load_file

path = hf_hub_download("gpt2", "model.safetensors")
sd = load_file(path)

out = "gpt2_weights"
os.makedirs(out, exist_ok=True)

total = 0
for name, arr in sd.items():
    total += arr.size
    print(f"{name:45s} {str(arr.shape):15s} {arr.dtype}")
    np.save(os.path.join(out, f"{name}.npy"), arr)
    arr.tofile(os.path.join(out, f"{name}.bin"))

print(f"\nTotal parameters: {total:,}")