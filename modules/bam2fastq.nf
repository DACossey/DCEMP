process bam2fastq { 

  tag "$prefix"
  
  input:
  bam_file
  
  output:
  path "$prefix"/fastq_files

  script:
  """
  mkdir -p fastq_filesz

  BAMS=$@

  for f in $BAMS; do
    file=$(basename $f)
    samtools fastq --threads 20 -f 4 -0 $OUTDIR/${file/.bam/.fastq.gz} $f ;
  done

  """


}
