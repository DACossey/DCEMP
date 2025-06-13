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
       echo "    `basename $0` [options: [-t] [-g] [-k]] <prefix> <reads.fastq>"
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


# Directories' prep (making directies forbasecalling outputs)

## inputs
PREFIX=$1 #sample
POD5=$2  #pod5 files location

## output dirs
# mkdir -p logs/
mkdir -p ${PREFIX}_dorado
mkdir -p ${PREFIX}_dorado/dorado_basecalls/
mkdir -p ${PREFIX}_dorado/dorado_demux/

echo "Max cores: $THREADS"


# BASECALLING
echo "Running basecalling..."
dorado basecaller ${MODEL} ${POD5} --no-trim --kit-name ${KIT_NAME}  > ${PREFIX}_dorado/dorado_basecalls/${PREFIX}_calls.bam

# DEMULTIPLEXING
echo "Running demultiplexing"
dorado demux -t ${THREADS} --output-dir ${PREFIX}_dorado/dorado_demux/ --kit-name ${KIT_NAME} ${PREFIX}_dorado/dorado_basecalls/${PREFIX}_calls.bam


echo "BAM files ready and saved to: dorado_demux"
echo "Your next steps are converting BAM files to FASTQ and then quality filtering."


