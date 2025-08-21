process basecalling {
    tag "basecalling"

    input:
    path pod5_dir

    output:
    path "basecalls.bam", emit: basecalls

    script:
    """
    dorado basecaller \
        ${params.basecalling_model} \
        ${pod5_dir} \
        ${params.no_trim ? '--no-trim' : ''} \
        --kit-name ${params.kit_name} \
        > ./basecalls.bam
    """
}


  
