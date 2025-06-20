#!/bin/bash

# Intro message and flags
echo "Fastplong is a wrapper for fastp to trim Nanopore reads."
echo "Please make sure you are analysing long reads; otherwise, use fastp directly."
echo "Default flags have been set, but you can change them according to https://github.com/OpenGene/fastplong?tab=readme-ov-file#quality-filter"
echo "You can also run fastplong -h for more information."
echo "Remember to put flags before the input directory."


# Set default options for flags (will be overwritten if specified)
START_ADAPTER="TTTCTGTTGGTGCTGATATTGC"
END_ADAPTER="ACTTGCCTGTCGCTCTATCTTC"
TRIM_5=false
TRIM_3=false

# Output directories
OUTDIR="TRIMMED_FASTQ" #will change if specified with -o
OUTDIR_REPORTS="QC_reports"


while getopts ":ho:s:e:53M:q:u:l:" opt; do
  case "${opt}" in
    h) echo ""
       echo "Uses fastplong to quality control long read sequencing fastq files. Allows manipulation of adapter trimming, start and end trimming, read quality filtering, and read length filtering. "
       echo "Usage: "
       echo "    `basename $0` [options: [-o] [-s] [-e] [-5] [-3] [-M] [-q] [-u] [-l] <fastq.gz files directory> ]"
       echo "Options: "
       echo "    -o  -  Specify output directory [Default: ./output]"
       echo "    -s  -  Specify start adapter sequence (5' to 3') for trimming [Default: TTTCTGTTGGTGCTGATATTGC]"
       echo "    -e  -  Specify end adapter sequence (5' to 3') for trimming [Default: ACTTGCCTGTCGCTCTATCTTC]"
       echo "    -5  -  Enable 5' adapter trimming cut front; move a sliding window from front (5') to tail, drop the bases in the window if its mean quality < threshold, stop otherwise. [Default is disabled, enable by adding -5]"
       echo "    -3  -  Enable 3' adapter trimming cut tail; move a sliding window from front (3') to tail, drop the bases in the window if its mean quality < threshold, stop otherwise. [Default is disabled, enable by adding -3]"
       echo "    -M  -  Cut mean quality requirement option shared by cut_front, cut_tail or cut_sliding. Range: 1~36 [Default: 20 (Q20)]. (int [=20]))"
       echo "    -q -  Qualified quality phred; the quality value that a base is qualified. Default 15 means phred quality >=Q15 is qualified. (int [=15])"
       echo "    -u  -  Unqualified percent limit; how many percents of bases are allowed to be unqualified (0~100) [Default 40 means 40%. (int [=40])]"
       echo "    -l  -  Specify minimum length for reads [Default for this pipeline: 50. (int [=50])]"
       echo ""
       exit 0
      ;;
    o) OUTDIR="${OPTARG}" ;;
    s) START_ADAPTER="${OPTARG}" ;;
    e) END_ADAPTER="${OPTARG}" ;;
    5) TRIM_5=true;;
    3) TRIM_3=true;;
    M) MEAN_QUALITY="${OPTARG}" ;;
    q) QUALIFIED_QUALITY="${OPTARG}" ;;
    u) UNQUALIFIED_PERCENT="${OPTARG}" ;;
    l) MIN_LENGTH="${OPTARG}" ;;
    \?)echo "Invalid Option: -$OPTARG" 1>&2
       exit 1
      ;;
  esac
done


shift $((OPTIND -1))

INPUT_DIR=$1
mkdir -p "$OUTDIR" "$OUTDIR_REPORTS"

#Finding fastq files in the FASTQ directory
FASTQS=("$INPUT_DIR"/*.fastq.gz)

echo "Filtering FASTQ files..."
for fq in "${FASTQS[@]}"; do
  base=$(basename "$fq" .fastq.gz)
  CMD=(fastplong \
    -i "$fq" \
    -o "$OUTDIR/${base}_trimmed.fastq.gz" \
    -s "$START_ADAPTER" \
    -e "$END_ADAPTER" \
    -h "$OUTDIR_REPORTS/${base}_fastp_report.html" \
    -j "$OUTDIR_REPORTS/${base}_fastp_report.json" \
  )
    # Only add -5 if specified
    if [ "$TRIM_5" = true ]; then
      CMD+=(-5)
    fi
  
    # Only add -3 if specified
    if [ "$TRIM_3" = true ]; then
      CMD+=(-3)
    fi

    # Add mean quality if specified
    if [ -n "$MEAN_QUALITY" ]; then
      CMD+=(-M "$MEAN_QUALITY")
    fi

    # Add qualified quality if specified
    if [ -n "$QUALIFIED_QUALITY" ]; then
      CMD+=(-q "$QUALIFIED_QUALITY")
    fi

    # Add unqualified percent if specified
    if [ -n "$UNQUALIFIED_PERCENT" ]; then
      CMD+=(-u "$UNQUALIFIED_PERCENT")
    fi 

    # Add minimum length if specified
    if [ -n "$MIN_LENGTH" ]; then
      CMD+=(-l "$MIN_LENGTH")
    
    else
      CMD+=(-l 50)
    fi
   echo "Running Quality filtering with command: ${CMD[@]}"   
  "${CMD[@]}"  
  echo "Quality filtering complete."
done

echo "Quality filtering complete.\
Trimmed files were saved to: ${OUTDIR} \
and the reports can be found in ${OUTDIR_REPORTS}."
