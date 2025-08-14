process bam2fastq {

    tag { demux.simpleName() }
    publishDir "fastqs",mode: 'copy'

    input:
    path demux //demultiplexing output

    output:
    path "fastqs/${bam.simpleName}.fastq", emit: fastqs

    script:
    """
    samtools fastq --threads 20 -0 fastqs/${demux.simpleName}.fastq "$demux"

    """
}
