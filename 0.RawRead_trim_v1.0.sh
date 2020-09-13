#!/bin/bash
sample=$1
dir_wk='/home/D/cza/ATAC_HCC_tissue/LSL'
dir_fq=${dir_wk}'/fastq'
fq1=${dir_fq}/${sample}/${sample}'_R1.fastq.gz'
fq2=${dir_fq}/${sample}/${sample}'_R2.fastq.gz'
dir_trim=${dir_wk}'/Trim_results'
mkdir -p ${dir_trim}/${sample}
filt_r1=${dir_trim}/${sample}/${sample}'_filtered_R1.fastq.gz'
unp_r1=${dir_trim}/${sample}/${sample}'_unpaired_R1.fastq.gz'
filt_r2=${dir_trim}/${sample}/${sample}'_filtered_R2.fastq.gz'
unp_r2=${dir_trim}/${sample}/${sample}'_unpaired_R2.fastq.gz'
java='/usr/bin/java'
trim='/home/D/pgm/java/trimmomatic.jar'
adapter='/home/D/ref/fasta/adapters/Adapters_PE.fa'
${java} -jar ${trim} PE ${fq1} ${fq2} ${filt_r1} ${unp_r1} ${filt_r2} ${unp_r2} \
        'ILLUMINACLIP:'${adapter}':2:30:10' LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 2> ${dir_trim}/${sample}/read_surviving_stat.txt
