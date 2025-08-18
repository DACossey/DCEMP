#!/usr/bin/env python3

import os
import glob

def get_read_id(header):
    return header[1:].strip()

# Directory containing your FASTQ and host ID files
directory = "./"  # update if needed

# Pattern to find all host ID files
host_id_files = glob.glob(os.path.join(directory, "EXP-PBC096_barcode*_combined_trimmed_hostIDs.fastq*"))

for host_ids_file in host_id_files:
    # Extract sample prefix, e.g. EXP-PBC096_barcode02
    basename = os.path.basename(host_ids_file)
    prefix = basename.split("_combined_trimmed_hostIDs")[0]

    # Construct paths for original fastq and output filtered fastq
    original_fastq = os.path.join(directory, prefix + "_combined_trimmed.fastq")
    output_fastq = os.path.join(directory, prefix + "_hr.fastq")

    print(f"Processing sample {prefix} ...")

    # Check if original FASTQ exists
    if not os.path.exists(original_fastq):
        print(f"WARNING: Original FASTQ file not found for {prefix}, skipping.")
        continue

    # Load host IDs into a set
    with open(host_ids_file) as f:
        host_ids = set(line.strip() for line in f)

    with open(original_fastq) as infile, open(output_fastq, "w") as outfile:
        while True:
            header = infile.readline()
            if not header:
                break  # EOF
            seq = infile.readline()
            plus = infile.readline()
            qual = infile.readline()

            read_id = get_read_id(header)

            if read_id not in host_ids:
                outfile.write(header)
                outfile.write(seq)
                outfile.write(plus)
                outfile.write(qual)

    print(f"Finished sample {prefix}, output saved to {output_fastq}")
"host_remove.py" 52L, 1708C                   
