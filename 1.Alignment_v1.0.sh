#!/bin/bash
sample=$1
bwa='/extraspace/sli/softwares/bwa/bwa'
sambamba='/extraspace/sli/softwares/sambamba-0.6.9-linux-static'
picard='/extraspace/sli/softwares/java/jar/picard.jar'
dir_wk='/extraspace/sli/DNA_helicase/data/ChIPSeq/Huh7'
dir_trim=${dir_wk}'Trim_results'
dir_alignment=${dir_wk}'/alignment_bwa'
mkdir -p ${dir_alignment}/${sample}
trim_fq=(`ls ${dir_trim}/${sample}/*filtered_*.fastq.gz`)
out_sam=${dir_alignment}/${sample}/${sample}'_alignment.sam'
header='@RG\tID:'${sample}'\tLB:'${sample}'\tPL:Illumina\tPM:hiseq\tSM:'${sample}
${bwa} mem ${ref_fa} -M -R ${header} ${trim_fq[0]} ${trim_fq[1]} -t 5 > ${out_sam}
out_bam=${dir_alignment}/${sample}/${sample}'_alignment.bam'
out_sortbam=${dir_alignment}/${sample}/${sample}'_alignment_sorted.bam'
${sambamba} view -S -f bam -o ${out_bam} ${out_sam}
${sambamba} sort -tmpdir ${dir_wk} -o ${out_sortbam} ${out_bam}
${sambamba} index ${out_sortbam}
out_mkdupbam=${dir_alignment}/${sample}/${sample}'_alignment_sorted_mkdup.bam'
out_mkdupmetric=${dir_alignment}/${sample}/${sample}'_mkdup_metrics.txt'
${java} -jar ${picard} MarkDuplicates INPUT=${out_sortbam} OUTPUT=${out_mkdupbam} METRICS_FILE=${out_mkdupmetric}
${sambamba} index ${out_mkdupbam}

rm -f ${out_sam}
rm -f ${out_bam}
