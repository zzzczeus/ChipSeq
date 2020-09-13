#!/bn/bash
sample=$1
dir_wk='/extraspace/sli/DNA_helicase/data/ChIPSeq/Huh7'
dir_alignment=${dir_wk}'/alignment_bwa'
dir_peakcalling=${dir_wk}'/PeakCalling'
input_bam=${dir_alignment}'/Input/Huh7_Input_alignment_sorted_mkdup.bam'
mkdir -p ${dir_peakcalling}/${sample}
${macs} callpeak -t ${dir_alignment}/${sample}/${sample}'_alignment_sorted_mkdup.bam' -c ${input_bam} -f BAM -g hs -n ${sample} --outdir ${dir_peakcalling}/${sample}
