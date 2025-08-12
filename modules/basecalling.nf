process basecalling {
    tag "$prefix"
  
    input:
    val prefix
    path pod5_dir

    output:
    path "demux_bams/*.bam", emit: demux_bams

    script:
    """
    mkdir -p demux_bams
    mkdir -p dorado_basecalls

    echo "Running basecalling for sample ${prefix}..."
    dorado basecaller sup ${pod5_dir} --no-trim --kit-name SQK-NBD114-96 \
        > dorado_basecalls/basecalls.bam

    echo "Running demultiplexing..."
    dorado demux -t 20 \
        --output-dir demux_bams/ \
        --kit-name SQK-NBD114-96 \
        dorado_basecalls/basecalls.bam

    echo "BAM files saved to: demux_bams/"
    """
}

  
