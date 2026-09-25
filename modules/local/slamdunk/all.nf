process SLAMDUNK_ALL {
    tag "${meta.id}"
    label 'process_high'

    container 'quay.io/biocontainers/slamdunk:0.4.3--py_0'

    input:
    tuple val(meta), path(reads)
    path fasta
    path bed

    output:
    tuple val(meta), path("${meta.id}/filter/*_filtered.bam"), emit: filtered_bam
    tuple val(meta), path("${meta.id}/count/*_tcount.tsv")   , emit: tcount
    tuple val(meta), path("${meta.id}")                      , emit: outdir
    path 'versions.yml'                                      , emit: versions

    script:
    def args      = task.ext.args ?: ''
    def read_len  = params.max_read_length ? "-rl ${params.max_read_length}" : ''
    def min_bq    = "-mbq ${params.min_base_qual}"
    def trim5     = "-5 ${params.trim_5p}"
    """
    slamdunk all \\
        -r ${fasta} \\
        -b ${bed} \\
        -o ${meta.id} \\
        -t ${task.cpus} \\
        ${read_len} \\
        ${min_bq} \\
        ${trim5} \\
        ${args} \\
        ${reads}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        slamdunk: \$(slamdunk --version 2>&1 | sed 's/^.*slamdunk //; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    """
    mkdir -p ${meta.id}/filter ${meta.id}/count ${meta.id}/map ${meta.id}/snp
    touch ${meta.id}/filter/${meta.id}_slamdunk_mapped_filtered.bam
    touch ${meta.id}/count/${meta.id}_slamdunk_mapped_filtered_tcount.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        slamdunk: 0.4.3
    END_VERSIONS
    """
}
