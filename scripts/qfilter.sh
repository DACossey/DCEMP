#!/bin/bash

# Intro message and flags
echo "Fastplong is a wrapper for fastp to trim Nanopore reads."
echo "Please make sure you are analysing long reads; otherwise, use fastp directly."
echo "Default flags have been set, but you can change them according to https://github.com/OpenGene/fastplong?tab=readme-ov-file#quality-filter"
echo "You can also run fastp -h for more information."


# Set default options for flags (will be overwritten if specified)
START_ADAPTER="TTTCTGTTGGTGCTGATATTGC"
END_ADAPTER="ACTTGCCTGTCGCTCTATCTTC"

# Directories
OUTDIR="TRIMMED_FASTQ" #will change if specified with -o
OUTDIR_REPORTS="QC_reports"


while getopts ":hm:o:s:e:5:3:M:u:l" opt; do
  case "${opt}" in
    h) echo ""
       echo "Wrapper for Dorado to Basecall Nanopore pod5 files."
       echo "Usage: "
       echo "    `basename $0` [options: <fastq.gz files directory> [-o] [-s] [-e] [-5] [-3] [-M] [-u] [-l]]"
       echo "Options: "
       echo "    -o  -  Specify output directory [Default: ./output]"
       echo "    -s  -  Specify start adapter sequence (5' to 3') for trimming [Default: TTTCTGTTGGTGCTGATATTGC]"
       echo "    -e  -  Specify end adapter sequence (5' to 3') for trimming [Default: ACTTGCCTGTCGCTCTATCTTC]"
       echo "    -5  -  Enable 5' adapter trimming cut front; move a sliding window from front (5') to tail, drop the bases in the window if its mean quality < threshold, stop otherwise."
       echo "    -3  -  Enable 3' adapter trimming cut tail; move a sliding window from front (3') to tail, drop the bases in the window if its mean quality < threshold, stop otherwise."
       echo "    -M  -  Cut mean quality requirement option shared by cut_front, cut_tail or cut_sliding. Range: 1~36 [Default: 20 (Q20)])"
       echo "    -u  -  Unqualified percent limit; how many percents of bases are allowed to be unqualified (0~100) [Default 40 means 40%]"
       echo "    -l  -  Specify minimum length for reads [Default for this pipeline: 50]"
       echo ""
       exit 0
      ;;
    o) OUTDIR="${OPTARG}" ;;
    s) START_ADAPTER="${OPTARG}" ;;
    e) END_ADAPTER="${OPTARG}" ;;
    5) TRIM_5=true ;;
    3) TRIM_3=true ;;
    M) MEAN_QUALITY="${OPTARG}" ;;
    u) UNQUALIFIED_PERCENT="${OPTARG}" ;;
    l) MIN_LENGTH="${OPTARG}" ;;
    \?)echo "Invalid Option: -$OPTARG" 1>&2
       exit 1
      ;;
  esac
done


shift $((OPTIND -1))

mkdir -p "$OUTDIR" "$OUTDIR_REPORTS"
INPUT_DIR=$1

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
      
  "${CMD[@]}"  

done

echo "Quality filtering complete.\
Trimmed files were saved to: ${OUTDIR} \
and the reports can be found in ${OUTDIR_REPORTS}."
