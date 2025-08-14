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

    /*
    ------------------------------
        POD5 input
    ------------------------------
    */
    if (pod5_dir) {
        pod5_ch = Channel.fromPath(pod5_dir)

        basecalling(pod5_ch)
        demultiplexing(basecalling.out.basecalls)
        bam2fastq(demultiplexing.out.demux_bams)
        
        fastqs_from_pod5 = bam2fastq.out.fastqs
    }

    /*
    ------------------------------
        BAM input
    ------------------------------
    */
    if (bam_files) {
        bam_ch = Channel.fromPath(bam_files)
        bam2fastq(bam_ch)

        fastqs_from_bam = bam2fastq.out.fastqs
    }

    /*
    ------------------------------
        FASTQ input
    ------------------------------
    */
    if (fastq_files) {
        fastqs_from_fastq = Channel.fromPath(fastq_files)
    }

    /*
    ------------------------------
        Merge all FASTQs into one channel
    ------------------------------
    */
    fastqs_ch = Channel.empty()

    if (pod5_dir) {
        fastqs_ch = fastqs_ch.mix(fastqs_from_pod5)
    }
    if (bam_files) {
        fastqs_ch = fastqs_ch.mix(fastqs_from_bam)
    }
    if (fastq_files) {
        fastqs_ch = fastqs_ch.mix(fastqs_from_fastq)
    }

    return fastqs_ch
}
