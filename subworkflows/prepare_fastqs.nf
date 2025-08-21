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
    fastqs_ch = Channel.empty()

    if (params.pod5_dir) {
        pod5_ch   = Channel.fromPath(params.pod5_dir, type: 'dir')
        // pod5_ch.view()
        bc_out    = basecalling(pod5_ch)
        demux_out = demultiplexing(bc_out.basecalls)
        bam_out   = bam2fastq(demux_out.demux_bams.flatten())
        fastqs_ch = bam_out.fastqs
        

    }
    else if (params.bam_files) {
        bam_ch    = Channel.fromPath("${params.bam_files}/*.bam")
        bam_out   = bam2fastq(bam_ch)
        fastqs_ch = bam_out.fastqs
    }
    else if (params.fastq_files) {
        fastq_ch  = Channel.fromPath("${params.fastq_files}/*.fastq")
        fastqs_ch = fastq_ch
    }
    else {
        error "You must provide either --pod5_dir, --bam_files, or --fastq_files"
    }

    emit:
    fastqs_ch
}
