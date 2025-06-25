#!/bin/bash
# Script for metagenomic profiling with sylph
echo "Sylph is a tool for metagenomic profiling."

#Pre-built database(s) of interest
echo "You can use db_prebuilt.sh to download Sylph databases or use your own pre-built database in .syldb format."

# Set default output directory if not provided
OUTDIR="metagenomic_profiling"
UNKOWN_PROFILES=false

# should I add threads? sylph doesn't specifiy bc they use 4 as default... but idk and later sylph-tax uses -t as the metada id not as threads
# so it might be confusing

# Help menu and flags
while getopts ":huo:" opt; do
  case "${opt}" in
    h) echo ""
       echo "Uses Sylph to profile metagenomic samples against a pre-built database and assigns taxonomy."
       echo "Usage: "
       echo "    $(basename "$0") [options]: [-u] [o] <fastq or fastq.gz files directory path> <pre-built database .syldb path> <metadata .tsv.gz path>"
       echo "Options: "
       echo "    -u  -Specify if required estimation of unknown reads percentage. [Default is disabled, enable by adding -u]"
       echo "    -o  -Specify output directory [Default: ./output] the directory needs to exist."
       echo ""
       exit 0
      ;;
    u) UNKNOWN_PROFILES=true;;
    o) OUTDIR="${OPTARG}" ;;
    \?)echo "Invalid Option: -$OPTARG" 1>&2
       exit 1
      ;;
  esac
done
shift $((OPTIND -1))

#input directory check
if [ -z "$1" ]; then
  echo "Error: Please provide the input directory containing fastq or fastq.gz files."
  exit 1
fi

# make directories
INPUT_DIR="$1"
DATABASE="$2"
METADATA="$3"
mkdir -p "$OUTDIR"



#Finding fastq files in the FASTQ directory
READS=()
for fq in "$INPUT_DIR"/*.fastq; do
  [ -e "$fq" ] && READS+=("$fq")
  
done

if [ ${#READS[@]} -eq 0 ]; then
  echo "No FASTQ files found in $INPUT_DIR"
  exit 1
fi

#PROFILE AGAINST DATABASE and ESTIMATE UNKNOWN READS
for fq in "${READS[@]}"; do
 base=$(basename "$fq" .fastq)
  echo "Profiling $base against database $DATABASE..."

  # Check if the database file exists
  if [ ! -f "$DATABASE" ]; then
    echo "Error: Database file $DATABASE not found."
    exit 1
  fi

  # Check if the metadata file exists
  if [ ! -f "$METADATA" ]; then
    echo "Error: Metadata file $METADATA not found."
    exit 1
  fi

  # Create command array for profiling
 CMD=(
    sylph profile \
    "$DATABASE" \
    "$fq" \
    -o "$OUTDIR/${base}_results.tsv"
  )
    # Only add -u if specified
 if [ "$UNKNOWN_PROFILES" = true ]; then
     CMD+=(-u)
 fi

 echo "Running Profiling with command: ${CMD[@]}"
 "${CMD[@]}"
 echo "Profiling completed for $base, results are saved in $OUTDIR/${base}_results.tsv."

 echo "Integrating taxonomy for $base..."
 sylph-tax taxprof "$OUTDIR/${base}_results.tsv" -o "$OUTDIR/" -t "$METADATA"
 orig="$OUTDIR/${base}.fastq.sylphmpa"
 new="$OUTDIR/${base}.sylphmpa"
 if [ -f "$orig" ]; then
    mv "$orig" "$new"
 else
    echo "Warning: Expected $orig not found!"
 fi

 echo "Taxonomy integration completed for $new, results are saved in $OUTDIR."

done

# Merge multiple taxonomic profiles based on relative abundance
TAXONOMIES=("$OUTDIR"/*.sylphmpa)
if [ ${#TAXONOMIES[@]} -eq 0 ]; then
  echo "No taxonomic profiles found in $OUTDIR"
  exit 1
fi

echo "Merging taxonomic profiles based on relative abundance..."
sylph-tax merge "${TAXONOMIES[@]}" --column relative_abundance -o "$OUTDIR/merged_tax_ra.tsv"
