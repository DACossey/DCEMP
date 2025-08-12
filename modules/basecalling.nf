process basecalling {
    tag "$prefix"
  
    input:
    val prefix
    path pod5_dir

    output:
    path "${prefix}_dorado/dorado_basecalls/"
    path "${prefix}_dorado/dorado_demux/"

    script:
    """
    mkdir -p ${prefix}_dorado/dorado_basecalls/
    mkdir -p ${prefix}_dorado/dorado_demux/

    # BASECALLING
    echo "Running basecalling..."
    dorado basecaller sup ${pod5_dir} --no-trim --kit-name SQK-NBD114-96 > ${prefix}_dorado/dorado_basecalls/${prefix}_calls.bam

    # DEMULTIPLEXING
    echo "Running demultiplexing"
    dorado demux -t 20 --output-dir ${prefix}_dorado/dorado_demux/ --kit-name SQK-NBD114-96 ${prefix}_dorado/dorado_basecalls/${prefix}_calls.bam

    echo "BAM files ready and saved to: dorado_demux"
    echo "Your next steps are converting BAM files to FASTQ and then quality filtering."
    """
}




  
  
