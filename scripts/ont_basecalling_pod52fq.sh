#!/bin/bash

# Set default options for flags (will be overwritten if specified)

THREADS=20
MODEL=sup
KIT_NAME=SQK-NBD114-96

while getopts ":hm:g:k:c:" opt; do
  case "${opt}" in
    h) echo ""
       echo "Wrapper for Dorado to Basecall Nanopore pod5 files."
       echo "Usage: "
       echo "    `basename $0` [options: [-t] [-g] [-k]] <prefix> <your_pod5_directory>"
       echo "Options: "
       echo "    -t  -  Specify the number of threads for demultiplexing reads [20]"
       echo "    -g  -  Specifiy basecalling model [Default: sup, hac, fast]"
       echo "    -k  -  Specifiy kit name. Check this carfully default for convenience [Default:SQK-NBD114-96]"
       echo ""
       exit 0
      ;;
    t) THREADS="${OPTARG}" ;;
    g) MODEL="${OPTARG}" ;;
    k) KIT_NAME="${OPTARG}" ;;
    \?)echo "Invalid Option: -$OPTARG" 1>&2
       exit 1
      ;;
  esac
done


shift $((OPTIND -1))


# Check that mandatory positional arguments are present (prefix to name assembly files, plus the reads in a single fastq)
if [ $# -ne 2 ]; then
    echo ""
    echo "Splits dorado into 2 steps: basecall and then demultiplex."
    echo ""
    echo "Invalid number of positional arguments"
    echo "Usage: `basename $0` [options: [-t] [-g] [-k]] <prefix> <pod5_dir>"
    echo ""
    exit 1
fi

## Inputs
PREFIX=$1 #sample
POD5=$2  #pod5 files location

## Output dirs
BASE_DIR="${PREFIX}_dorado"
BASECALLS_DIR="${BASE_DIR}/dorado_basecalls"
DEMUX_DIR="${BASE_DIR}/dorado_demux"
FASTQ_OUTDIR="${BASE_DIR}/fastq"

mkdir -p "$BASE_DIR" "$BASECALLS_DIR" "$DEMUX_DIR" "$FASTQ_OUTDIR"

echo "Max cores: $THREADS"


# BASECALLING
echo "Running basecalling..."
echo "${PREFIX}_dorado"
dorado basecaller "${MODEL}" "${POD5}" --no-trim --kit-name "${KIT_NAME}" > "${BASECALLS_DIR}/${PREFIX}_calls.bam"
echo "Basecalling finished successfully, your basecalled BAM file is now in ${BASECALLS_DIR}/${PREFIX}_calls.bam."

# DEMULTIPLEXING
echo "Running demultiplexing"
dorado demux -t "${THREADS}" --output-dir "$DEMUX_DIR" --kit-name "${KIT_NAME}" "${BASECALLS_DIR}/${PREFIX}_calls.bam"
echo "Dorado demux finished successfully, your demultiplexed BAM files are now in $DEMUX_DIR."

#Finding BAM files in the demux directory
BAMS=("$DEMUX_DIR"/*.bam)

# Check if any BAM files were found
if [ ${#BAMS[@]} -eq 0 ]; then
    echo "No BAM files found in $DEMUX_DIR. Please check the demultiplexing step."
    exit 1
else
    echo "Converting BAM files to FASTQ format..."
fi

for f in ${BAMS[@]}; do
    file=$(basename $f)
    samtools fastq --threads "$THREADS" -0 "$FASTQ_OUTDIR/${file/.bam/.fastq.gz}" "$f"
done


echo "BAM to FASTQ conversion finished successfully, your FASTQ files are now in $FASTQ_OUTDIR."