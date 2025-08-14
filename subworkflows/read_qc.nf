#!/usr/bin/env nextflow


/*
========================================================================================
DESCRIPTION
========================================================================================
*/


// My description
// goes 
// here


include { RUN_FASTPLONG } from '../modules/fastplong.nf'
include { MULTIQC       } from '../modules/multiqc.nf'


/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow READQC {

    take:
    manifest        // tuple( meta, read_1 )

    main:
    fastplong_ch = RUN_FASTPLONG(manifest_ch)

    multiqc_ch = MULTIQC(fastplong_ch.fastp_json.collect())

}
