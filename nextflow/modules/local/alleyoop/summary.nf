process ALLEYOOP_SUMMARY {
    tag 'summary'
    label 'process_low'

    container 'quay.io/biocontainers/slamdunk:0.4.3--py_0'

    input:
    path bams  , stageAs: 'bams/*'
    path counts, stageAs: 'counts/*'

    output:
    path 'summary.txt'      , emit: summary
    path 'summary_PCA.txt'  , emit: pca, optional: true
    path 'versions.yml'     , emit: versions

    script:
    """
    alleyoop summary \\
        -o summary.txt \\
        -t counts \\
        bams/*.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        slamdunk: \$(slamdunk --version 2>&1 | sed 's/^.*slamdunk //; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    """
    touch summary.txt
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        slamdunk: 0.4.3
    END_VERSIONS
    """
}
