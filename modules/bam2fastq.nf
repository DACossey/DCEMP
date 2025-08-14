process bam2fastq {

    tag { demux.getSimpleName() }
    publishDir "fastqs",mode: 'copy'

    input:
    path demux //demultiplexing output

    output:
    path "fastqs/${bam.simpleName}.fastq", emit: fastqs

    script:
    """
    mkdir -p fastqs
    samtools fastq --threads 20 -0 fastqs/${demux.simpleName}.fastq "$demux"

    """
}
