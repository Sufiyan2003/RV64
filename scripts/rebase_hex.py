#!/usr/bin/env python3
"""
rebase_hex.py - Rebase @address markers in objcopy -O verilog hex output
to start at 0, so $readmemh loads correctly into a RAM module indexed by
local offset (0..MEM_BYTES-1) instead of absolute address.

Usage:
    python3 rebase_hex.py firmware.hex firmware_rebased.hex

This only rewrites @<hex_address> marker lines. It finds the first marker
in the file and treats it as the base; every subsequent marker is rewritten
relative to that base. Data lines are copied through unchanged.
"""

import sys

def rebase_hex(infile, outfile):
    base = None
    out_lines = []

    with open(infile, "r") as f:
        for line in f:
            stripped = line.strip()
            if stripped.startswith("@"):
                addr = int(stripped[1:], 16)
                if base is None:
                    base = addr  # first marker sets the base
                new_addr = addr - base
                out_lines.append(f"@{new_addr:08x}\n")
            else:
                out_lines.append(line)

    with open(outfile, "w") as f:
        f.writelines(out_lines)

    print(f"Rebased '{infile}' -> '{outfile}', base was 0x{base:08x}" if base is not None
          else f"No @address markers found in '{infile}', copied unchanged.")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 rebase_hex.py <input.hex> <output.hex>")
        sys.exit(1)
    rebase_hex(sys.argv[1], sys.argv[2])