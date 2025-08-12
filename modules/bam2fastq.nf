process bam2fastq { 

  tag "bam"
  
  input:
  path bam_files
  
  output:
  path "fastq_files/*.fastq", emit: fastqs

  script:
  """
  mkdir -p fastq_files

 for bam in ${bam_files}; do
    base=\$(basename \$bam .bam)  # Now Bash sees $bam, not Nextflow
    samtools fastq --threads 20 -0 fastq_files/\${base}.fastq \$bam
  done

  """


}
