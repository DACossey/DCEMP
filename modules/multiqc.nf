process MULTIQC {
    publishDir "$params.outdir/00_multiqc", mode: "copy"

    input:
    path ("*")  

    output:
    path "multiqc_summary_data", emit: multiqc_data
    path "multiqc_summary.html", emit: multiqc_report

    script:
    """
    multiqc -c $params.multiqc_config \
    --filename multiqc_summary.html .
    """
}