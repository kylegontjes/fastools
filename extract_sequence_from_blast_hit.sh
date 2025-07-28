#!/bin/sh

module load Bioinformatics
module load samtools
 
# Assembly path
## Sample: '/nfs/turbo/umms-esnitkin/Project_Penn_KPC/Sequence_data/assembly/illumina/spades/PCMP_H107/PCMP_H107_contigs_l1000.fasta'
assembly=$1
# Blast file
## Sample: '/nfs/turbo/umms-esnitkin/Project_Penn_KPC/Analysis/Colistin_lab/2025-06-11_kfoC_gene_blast/results/PCMP_H107_contigs_l1000_blast_clean.tsv'
blast_file=$2
# Flanking difference upstream:
upstream_flank=$3

# Output name
name=$4

# Step 1: Index the assembly
samtools faidx $assembly

# Step 2: First, find the columns with name qseqid, qstart, and qend from the $blast_file
qseqid_col=$(head -1 "$blast_file" | tr ' ' '\n' | grep -ni 'qseqid' | cut -d: -f1)
qstart_col=$(head -1 "$blast_file" | tr ' ' '\n' | grep -ni 'qstart' | cut -d: -f1)
qend_col=$(head -1 "$blast_file" | tr ' ' '\n' | grep -ni 'qend' | cut -d: -f1)
sstart_col=$(head -1 "$blast_file" | tr ' ' '\n' | grep -ni 'sstart' | cut -d: -f1)
send_col=$(head -1 "$blast_file" | tr ' ' '\n' | grep -ni 'send' | cut -d: -f1)
 
# Step 3: Then print the contents as  $qseqid":"$qstart"-"$qend} 
region=$(awk -v qseqid_col="$qseqid_col" \
             -v qstart_col="$qstart_col" \
             -v qend_col="$qend_col" \
             -v flank="$upstream_flank" \
             -v sstart_col="$sstart_col" \
             -v send_col="$send_col" \
    'FNR==NR { contig_len[$1]=$2; next }  # Read .fai file into array
    FNR==1 { next }
   {
         contig = $qseqid_col
         if ($sstart_col < $send_col) {
             start = $qstart_col - flank;
             if (start < 1) start = 1;
             end = $qend_col;
         } else {
             start = $qstart_col;
             end = $qend_col + flank;
         }
         # Check if end is outside contig
         if (end > contig_len[contig]) end = contig_len[contig];
         # Check if start is outside contig
         if (start > contig_len[contig]) start = contig_len[contig];
         print contig ":" start "-" end
     }' "$assembly.fai" "$blast_file")

 
# Step 4: Extract the region from the assembly using samtools faidx
samtools faidx $assembly $region > "$name.fasta"

# Step 5: Remove the index file  
rm "$assembly.fai" 

# End of script
echo "Region extracted:"
echo "$region"
echo "Assembly indexed: $assembly.fai"
echo "Amount of upstream flanking sequence provided: $upstream_flank"
echo "Blast file processed: $blast_file"
echo "Output saved to: $name.fasta" 