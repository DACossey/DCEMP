process fastplong {

    tag { fastq.simpleName }
    // Send trimmed FASTQs to fastplong folder
    publishDir "${params.outdir}/fastplong", mode: 'copy', pattern: "*_trimmed.fastq"

    // Send reports to qc_reports folder
    publishDir "${params.outdir}/qc_reports", mode: 'copy', pattern: "*.{html,json}"

    //container
    container 'community.wave.seqera.io/library/fastplong:0.3.0--7ac22bc1d1bce90c' //fastplong
    

    input:
    path fastq

    output:
    path "*_trimmed.fastq", emit: trimmed_fastqs
    path "*_fastp_report.html", emit: fastp_html
    path "*_fastp_report.json", emit: fastp_json

    script:
    """
    fastplong \
        -i ${fastq} \
        -o ${fastq.simpleName}_trimmed.fastq \
        -s '${params.start_adapter}' \
        -e '${params.end_adapter}' \
        -h ${fastq.simpleName}_fastp_report.html \
        -j ${fastq.simpleName}_fastp_report.json \
        ${params.trim_5 ? "-5" : ""} \
        ${params.trim_3 ? "-3" : ""} \
        -M ${params.mean_quality} \
        -q ${params.qualified_quality} \
        -u ${params.unqualified_percent} \
        -l ${params.min_length}
    """
}
