#!/usr/bin/env nextflow

include { SLAMDUNK_ALL      } from './modules/local/slamdunk/all.nf'
include { ALLEYOOP_SUMMARY  } from './modules/local/alleyoop/summary.nf'

workflow {

    // --- Validate required params ---
    if (!params.input)  { error "Please provide a samplesheet with --input (CSV: sample,fastq)" }
    if (!params.fasta)  { error "Please provide a reference FASTA with --fasta" }
    if (!params.bed)    { error "Please provide a 3'UTR BED file with --bed" }

    // --- Reference channels (value channels: reused across every sample) ---
    ch_fasta = file(params.fasta, checkIfExists: true)
    ch_bed   = file(params.bed,   checkIfExists: true)

    // --- Parse samplesheet into [ meta, reads ] ---
    // Relative fastq paths are resolved against the samplesheet's own directory,
    // so bundled test data works while absolute paths / URLs (s3://, http://) pass through.
    def sheet_dir = file(params.input).parent
    ch_reads = channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: true)
        .map { row ->
            if (!row.sample || !row.fastq) {
                error "Samplesheet must have 'sample' and 'fastq' columns. Got: ${row}"
            }
            def is_absolute = row.fastq.startsWith('/') || row.fastq.contains('://')
            def reads = is_absolute ? file(row.fastq, checkIfExists: true)
                                    : file(sheet_dir.resolve(row.fastq), checkIfExists: true)
            def meta = [ id: row.sample ]
            [ meta, reads ]
        }

    // --- Run full slamdunk analysis per sample ---
    SLAMDUNK_ALL(ch_reads, ch_fasta, ch_bed)

    // --- Cross-sample QC summary ---
    ch_bams   = SLAMDUNK_ALL.out.filtered_bam.map { _meta, bam -> bam }.collect()
    ch_counts = SLAMDUNK_ALL.out.tcount.map { _meta, tsv -> tsv }.collect()

    ALLEYOOP_SUMMARY(ch_bams, ch_counts)
}
