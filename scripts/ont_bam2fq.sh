#!/bin/bash

OUTDIR=$1

shift

mkdir -p $OUTDIR

echo "Making: $OUTDIR"

BAMS=$@

for f in $BAMS; do
    file=$(basename $f)
    samtools fastq --threads 20 -0 $OUTDIR/${file/.bam/.fastq.gz} $f ;
done
