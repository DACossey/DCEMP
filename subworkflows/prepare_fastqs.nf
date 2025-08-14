/*
========================================================================================
    Subworkflow: prepare_fastqs
    Handles POD5, BAM, or FASTQ inputs and outputs a unified FASTQ channel
========================================================================================
*/

/*
========================================================================================
    IMPORT MODULES
========================================================================================
*/
include { basecalling }    from './modules/basecalling.nf'
include { demultiplexing } from './modules/demultiplexing.nf'
include { bam2fastq }      from './modules/bam2fastq.nf'

/*
========================================================================================
    WORKFLOW
========================================================================================
*/

workflow prepare_fastqs {

    input:
    // input channels or params are optional; we'll handle logic inside
    val pod5_dir  from params.pod5_dir
    val bam_files from params.bam_files
    val fastq_files from params.fastq_files

    output:
    path "*.fastq", emit: fastqs_ch

    // Initialize an empty channel
    fastqs_ch = Channel.empty()

    /*
    ------------------------------
        POD5 input
    ------------------------------
    */
    if (pod5_dir) {
        pod5_ch = Channel.fromPath(pod5_dir)

        bc_out = basecalling(pod5_ch)
        demux_out = demultiplexing(bc_out.out.basecalls)
        bam_out = bam2fastq(demux_out.out.demux_bams)

        fastqs_ch = fastqs_ch.mix(bam_out.out.fastqs)
    }

    /*
    ------------------------------
        BAM input
    ------------------------------
    */
    if (bam_files) {
        bam_ch = Channel.fromPath(bam_files)
        bam_out = bam2fastq(bam_ch)

        fastqs_ch = fastqs_ch.mix(bam_out.out.fastqs)
    }

    /*
    ------------------------------
        FASTQ input
    ------------------------------
    */
    if (fastq_files) {
        fastq_ch = Channel.fromPath(fastq_files)

        fastqs_ch = fastqs_ch.mix(fastq_ch)
    }

}
