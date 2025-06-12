#!/bin/sh

module load Bioinformatics
module load samtools

# Assembly path
## Test: assembly='/scratch/esnitkin_root/esnitkin1/kgontjes/Project_Penn_KPC/Analysis/Colistin_lab/2025-06-11_blast_kfoC_gene/assemblies/PCMP_H96_contigs_l1000.fasta'
## Multi-hit test: assembly='/scratch/esnitkin_root/esnitkin1/kgontjes/Project_Penn_KPC/Analysis/Colistin_lab/2025-06-11_blast_kfoC_gene/assemblies/PCMP_H99_contigs_l1000.fasta'
assembly=$1

# region path
## Test: blast_file='/nfs/turbo/umms-esnitkin/Project_Penn_KPC/Analysis/Colistin_lab/2025-06-11_kfoC_gene_blast/results/PCMP_H96_contigs_l1000_blast_clean.tsv'
## Multi-hit test: blast_file='/nfs/turbo/umms-esnitkin/Project_Penn_KPC/Analysis/Colistin_lab/2025-06-11_kfoC_gene_blast/results/PCMP_H99_contigs_l1000_blast_clean.tsv'
blast_file=$2

## Region name
output_name=$3

# Step 1: Index the assembly
samtools faidx $assembly

# Step 2: First, find the columns with name qseqid, qstart, and qend from the $blast_file
qseqid_col=$(head -1 "$blast_file" | tr ' ' '\n' | grep -ni 'qseqid' | cut -d: -f1)
qstart_col=$(head -1 "$blast_file" | tr ' ' '\n' | grep -ni 'qstart' | cut -d: -f1)
qend_col=$(head -1 "$blast_file" | tr ' ' '\n' | grep -ni 'qend' | cut -d: -f1)

# Step 3: Then print the contents as  $qseqid":"$qstart"-"$qend}
region=$(cat $blast_file |  awk -F' ' -v qseqid_col="$qseqid_col" -v qstart_col="$qstart_col" -v qend_col="$qend_col" '{print $qseqid_col":"$qstart_col"-"$qend_col}'| grep -v qseqid)

# Step 4: Extract the region from the assembly using samtools faidx
samtools faidx $assembly $region > "$output_name.fasta"

# Step 5: Remove faidx index file
rm "${assembly}.fai"