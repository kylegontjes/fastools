#!/bin/bash

# Specify the input and output file paths
input_fasta_file=$1
isolate_name=`echo $input_fasta_file | cut -f1 -d. | sed 's/_contigs_l1000/_reference/'`
output_fasta_name=`echo $isolate_name | sed 's/$/.fasta/'`

# Use `awk` to merge contigs and remove white spaces
awk '
    # Ignore headers (lines starting with ">")
    !/^>/ {
        # Remove white spaces and append sequence to buffer
        gsub(/\s+/, "", $0);
        buffer = buffer $0;
    }
    # When the end of the file is reached, print the header and merged sequence
    END {
        print ">'"$isolate_name"'" > "'"$output_fasta_name"'";
        print buffer >> "'"$output_fasta_name"'";
    }
' "$input_fasta_file"
