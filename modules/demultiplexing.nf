process demultiplexing {
    tag "$prefix"
    publishDir "results/demux_bams", mode: 'copy'

    input:
    val prefix
    path basecall_bam

    output:
    path "*.bam", emit: demux_bams

    script:
    """
    mkdir -p demux_bams // need to run mkdir because directory needs to exist before running demux
    
    dorado demux -t 20 \
    --output-dir demux_bams \
    --kit-name SQK-NBD114-96 \
    ${basecall_bam}
  
    """
}
