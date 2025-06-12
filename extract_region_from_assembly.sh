#!/bin/sh

module load Bioinformatics
module load samtools

# Assembly path
## Test: assembly='/scratch/esnitkin_root/esnitkin1/kgontjes/Project_Penn_KPC/Analysis/Colistin_lab/2025-06-11_blast_kfoC_gene/assemblies/PCMP_H96_contigs_l1000.fasta'
## Multi-hit test: assembly='/scratch/esnitkin_root/esnitkin1/kgontjes/Project_Penn_KPC/Analysis/Colistin_lab/2025-06-11_blast_kfoC_gene/assemblies/PCMP_H99_contigs_l1000.fasta'
assembly=$1

# region path
region=$2

# Step 1: Index the assembly
samtools faidx $assembly

# Step 2: Extract the region from the blast file 
samtools faidx $assembly $region > "$output_name.fasta"

# Step 5: Remove faidx index file
rm "${assembly}.fai"