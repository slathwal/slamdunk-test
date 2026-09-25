# slamdunk-nf

Nextflow (DSL2) wrapper for the [slamdunk](https://t-neumann.github.io/slamdunk) SLAM-seq analysis tool.

For each sample it runs `slamdunk all` (map → filter → snp → count), then produces a
cross-sample QC table with `alleyoop summary`.

## Usage

```bash
nextflow run main.nf -profile docker \
    --input samplesheet.csv \
    --fasta genome.fa \
    --bed 3utr.bed \
    --max_read_length 100 \
    --outdir results
```

Samplesheet (`--input`) is a CSV with a header:

```csv
sample,fastq
sampleA,s3://bucket/sampleA.fq.gz
sampleB,s3://bucket/sampleB.fq.gz
```

## Key parameters

| Param | Default | slamdunk flag | Description |
|-------|---------|---------------|-------------|
| `--input` | – | – | Samplesheet CSV (`sample,fastq`) |
| `--fasta` | – | `-r` | Reference FASTA |
| `--bed` | – | `-b` | 3′UTR BED file |
| `--trim_5p` | 12 | `-5` | bp trimmed from 5′ end |
| `--min_base_qual` | 27 | `-mbq` | Min base quality for T>C |
| `--max_read_length` | null | `-rl` | Max read length (auto if unset) |
| `--outdir` | results | – | Output directory |

## Test

```bash
nextflow run main.nf -profile test,docker --outdir results
```

Uses the bundled data in `slamdunk/test/data`. Container:
`quay.io/biocontainers/slamdunk:0.4.3--py_0`.
