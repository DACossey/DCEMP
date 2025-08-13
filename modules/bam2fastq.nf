process bam2fastq {

    tag { bam.getSimpleName() }

    input:
    path bam

    output:
    path "fastqs/${bam.simpleName}.fastq", emit: fastqs

    script:
    """
    mkdir -p fastqs
    samtools fastq --threads 20 -0 fastqs/${bam.simpleName}.fastq "$bam"

    """
}
