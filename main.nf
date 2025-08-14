#!/usr/bin/env nextflow

/*
========================================================================================
    IMPORT MODULES
========================================================================================
*/
include { basecalling }    from './modules/basecalling.nf'
include { demultiplexing } from './modules/demultiplexing.nf'
include { bam2fastq }      from './modules/bam2fastq.nf'
include { fastplong }      from './modules/fastplong.nf'

/*
========================================================================================
    WORKFLOW
========================================================================================
*/
workflow {

    // If starting from POD5
    if (params.pod5_dir) {
        pod5_ch = Channel.fromPath(params.pod5_dir)
        basecalling(pod5_ch)
        demultiplexing(basecalling.out.basecalls)
        bam2fastq(demultiplexing.out.demux_bams)
    }

    // If starting from BAMs directly
    if (params.bam_files) {
        bam_ch = Channel.fromPath(params.bam_files)
        bam2fastq(bam_ch)
    }

}


