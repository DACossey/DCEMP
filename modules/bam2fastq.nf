process bam2fastq {

    // tag { demux.baseName }
    publishDir "fastqs",mode: 'copy'

    input:
    path demux //demultiplexing output
    
    // publishDir "fastqs", mode: 'copy'
    
    output:
    path "${demux}.fastq", emit: fastqs

    script:
    """
    
    samtools fastq --threads 20 -0 ${demux}.fastq $demux
    """

}
