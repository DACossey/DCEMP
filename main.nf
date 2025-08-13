#!/usr/bin/env nextflow


/*
========================================================================================
    IMPORT MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// MODULES
//

include { basecalling } from './modules/basecalling.nf'
include { demultiplexing } from './modules/demultiplexing.nf'
include { bam2fastq } from './modules/bam2fastq .nf'

workflow {
    // Takes a manifest of reads as csv with a header (sample,reads) and parses it
        manifest_ch = Channel.fromPath(params.manifest)
                      .splitCsv(header: true)
                      .map { row -> 
                          tuple(row.sample, row.reads)
                      }
        // Split by input type
        pod5_ch = manifest_ch.filter { it[1] == 'pod5' }.map { tuple(it[0], it[2]) }
        bam_ch  = manifest_ch.filter { it[1] == 'bam'  }.map { it[2] }

        // From pod5: basecalling → bam2fastq
        basecalling(pod5_ch)
        bam2fastq(basecalling.out.demux_bams)

        // From bam: bam2fastq directly
        bam2fastq(bam_ch)
}
