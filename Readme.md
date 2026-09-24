To compile the code you must have Questa sim installed
Use the command: vlog -f files.f

You must also have a riscv compiler present to convert regular c code to machine code
we use that machine code to load into the ram (need to update steps)

python version 3.12.10 used
py -3.12 -m venv gpt2env
.\gpt2env\Scripts\Activate.ps1 (run this first: Set-ExecutionPolicy -Scope CurrentUser RemoteSigned)

pip install torch --index-url https://download.pytorch.org/whl/cpu

// to verify installation
python -c "import torch, transformers; print(torch.__version__, transformers.__version__)"

if this gives error:
    winget install Microsoft.VCRedist.2015+.x64 (run this in powershell)

