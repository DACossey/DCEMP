process demultiplexing {
    tag "demux"
    publishDir "demux_bams", mode: 'copy'

    input:
    path basecalling //basecalling process output

    output:
    path "demux_bams/*.bam", emit: demux_bams

    script:
    """
    mkdir -p demux_bams // need to run mkdir because directory needs to exist before running demux
    
    dorado demux -t 20 \
        --output-dir demux_bams \
        --kit-name SQK-NBD114-96 \
        ${basecalling}
  
    """
}
