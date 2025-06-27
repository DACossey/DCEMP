#!/usr/bin/env nextflow


/*
========================================================================================
    IMPORT MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// MODULES
//

include { READQC } from './modules/readqc.nf'


workflow {
    // Takes a manifest of reads as csv with a header (sample,reads) and parses it
        manifest_ch = Channel.fromPath(params.manifest)
                      .splitCsv(header: true)
                      .map { row -> 
                          tuple(row.sample, row.reads)
                      }

    READQC(manifest_ch)
}