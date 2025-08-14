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

    prepare_out = prepare_fastqs()
    fastqs_ch = prepare_out.fastqs_ch

    fastplong(fastqs_ch)
}
