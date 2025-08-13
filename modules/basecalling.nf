process basecalling {
    tag "basecalling"
    publishDir "dorado_basecalls", mode: 'copy'

    input:
    path pod5_dir

    output:
    path "basecalls.bam", emit: basecalls

    script:
    """
    dorado basecaller \
        sup \
        ${pod5_dir} \
        --no-trim \
        --kit-name SQK-NBD114-96 \
        > basecalls.bam
    """
}


  
