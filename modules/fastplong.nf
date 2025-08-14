process fastplong {

    tag { fastq.simpleName }
    publishDir "${params.outdir}/fastplong", mode: 'copy'

    input:
    path fastq from fastqs_ch

    output:
    path "*_trimmed.fastq", emit: trimmed_fastqs
    path "*_fastp_report.html", emit: fastp_html
    path "*_fastp_report.json", emit: fastp_json

    script:
    """
    mkdir -p TRIMMED_FASTQ QC_reports

    fastplong \
    -i ${fastq} \
    -o ${fastq.simpleName}_trimmed.fastq \
    -s '${params.start_adapter}' \
    -e '${params.end_adapter}' \
    ${params.trim_5 ? "-5" : ""} \
    ${params.trim_3 ? "-3" : ""} \
    -M ${params.mean_quality} \
    -q ${params.qualified_quality} \
    -u ${params.unqualified_percent} \
    -l ${params.min_length} \
    -g ${params.basecalling_model} \
    -k ${params.kit_name}

    fastplong \
        -i ${fastq} \
        -o TRIMMED_FASTQ/${fastq.simpleName}_trimmed.fastq \
        -s '${params.start_adapter}' \
        -e '${params.end_adapter}' \
        -h QC_reports/${fastq.simpleName}_fastp_report.html \
        -j QC_reports/${fastq.simpleName}_fastp_report.json \
        ${params.trim_5 ? "-5" : ""} \
        ${params.trim_3 ? "-3" : ""} \
        -M ${params.mean_quality} \
        -q ${params.qualified_quality} \
        -u ${params.unqualified_percent} \
        -l ${params.min_length}
    """
}
