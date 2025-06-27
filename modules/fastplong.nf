process RUN_FASTPLONG { // Taken from some code I wrote a while ago
    // For testing purposes you can use conda later on it would be good to pull from dockerhub
    // replace with your path (conda env list)
    conda '/miniconda/users/envs/fastplong' 
    publishDir "${params.outdir}/01_fastp", mode: 'copy'

    input:
    tuple val(sample) , path(reads)

    output:
    val sample, emit: sample
    path "${sample}_qc_report.fastp.html", emit: fastp_html
    path "${sample}_qc_report.fastp.json", emit: fastp_json
    path "${sample}_trimmed.fastq.gz", emit: fastp_fastq

    script:
    """
    fastplong -i ${reads} \
    -o ${sample}_trimmed.fastq.gz \
    --cut_front \
    --cut_tail \
    --cut_window_size $params.window_size \
    --cut_mean_quality $params.window_quality \
    --json ${sample}_qc_report.fastp.json \
    --html ${sample}_qc_report.fastp.html \
    --thread 1 \
    --length_required $params.min_length
    """
}