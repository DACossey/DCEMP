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
include { basecalling }    from '../modules/basecalling.nf'
include { demultiplexing } from '../modules/demultiplexing.nf'
include { bam2fastq }      from '../modules/bam2fastq.nf'

/*
========================================================================================
    WORKFLOW
========================================================================================
*/

workflow prepare_fastqs {

    // initialize empty channel
    fastqs_ch = Channel.empty()

    // POD5 input
    if (params.pod5_dir) {
        pod5_ch    = Channel.fromPath(params.pod5_dir)
        bc_out     = basecalling(pod5_ch)
        demux_out  = demultiplexing(bc_out.basecalls)
        bam_out    = bam2fastq(demux_out.demux_bams)

        fastqs_ch = fastqs_ch.mix(bam_out.out.fastqs)
    }

    // BAM input
    if (params.bam_files) {
        bam_ch    = Channel.fromPath(params.bam_files)
        bam_out   = bam2fastq(bam_ch)

        fastqs_ch = fastqs_ch.mix(bam_out.out.fastqs)
    }

    // FASTQ input
    if (params.fastq_files) {
        fastq_ch  = Channel.fromPath(params.fastq_files)
        fastqs_ch = fastqs_ch.mix(fastq_ch)
    }

    // emit the final channel
    emit: fastqs_ch
}

