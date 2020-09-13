#!/bin/bash
sample=$1
dir_wk='/extraspace/sli/DNA_helicase/data/ChIPSeq/Huh7'
dir_trim=${dir_wk}'/Trim_results'
fastqc='/extraspace/sli/softwares/FastQC/fastqc'
dir_fastqc=${dir_wk}'/Fastqc'
mkdir -p ${dir_fastqc}/${sample}
trim_fq=(`ls ${dir_trim}/${sample}/*filtered_*.fastq.gz`)
${fastqc} -t 5 -o ${dir_fastqc}/${sample} ${trim_fq[0]} ${trim_fq[1]}
