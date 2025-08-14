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

    // Start with empty channel
    Channel.empty()

        // Case 1: POD5 input
        .mix(
            params.pod5_dir ? Channel.fromPath(params.pod5_dir)
                .ifEmpty { error "No POD5 files found at ${params.pod5_dir}" }
                .into { pod5_ch }
                .tap { basecalling(it) }
                .tap { demultiplexing(basecalling.out.basecalls) }
                .map { demultiplexing.out.demux_bams }
            : Channel.empty()
        )

        // Case 2: BAM input
        .mix(
            params.bam_files ? Channel.fromPath(params.bam_files)
                .ifEmpty { error "No BAM files found at ${params.bam_files}" }
            : Channel.empty()
        )

        // Unify BAMs → FASTQs
        .set { bam_ch }

    // Convert BAMs to FASTQs if BAM channel not empty
    fastq_from_bam_ch = bam_ch.isEmpty() ? Channel.empty() : bam2fastq(bam_ch).out.fastqs

    // Case 3: FASTQ input (direct)
    fastq_from_user_ch = params.fastq_files ? Channel.fromPath(params.fastq_files)
        .ifEmpty { error "No FASTQ files found at ${params.fastq_files}" }
        : Channel.empty()

    // Merge FASTQs from BAMs and user input
    fastq_ch = fastq_from_bam_ch.mix(fastq_from_user_ch)

    // Run fastplong on all FASTQs
    fastplong(fastq_ch)
}

