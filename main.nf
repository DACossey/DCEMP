#!/usr/bin/env nextflow

/*
========================================================================================
    IMPORT MODULES & SUBWORFLOWS
========================================================================================
*/
include { prepare_fastqs }    from './subworkflows/prepare_fastqs.nf'
include { fastplong }         from './modules/fastplong.nf'

/*
========================================================================================
    WORKFLOW
========================================================================================
*/
workflow {

    fastqs_ch = prepare_fastqs()
    fastplong(fastqs_ch)

}
