process demultiplexing {
    tag "demux"
    publishDir "demux_bams", mode: 'copy'

    input:
    path basecalling

    output:
    path "demux_bams/*.bam", emit: demux_bams

    script:
    """
    mkdir -p demux_bams 
    
    dorado demux -t 20 \
        --output-dir demux_bams \
        --kit-name ${params.kit_name} \
        ${basecalling}
  
    """
    // need to run mkdir because directory needs to exist before running demux
}
