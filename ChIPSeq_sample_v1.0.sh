#!/bin/bash
### get the sample from command line

sample=$1
dir_wk='' # working directory

### softwares and reference to use
## softwares
java='/usr/bin/java'
trim='/home/D/pgm/java/trimmomatic.jar'
fastqc='/home/D/pgm/bin/fastqc'
bwa='/home/D/pgm/bin/bwa'
sambamba='/home/D/pgm/bin/sambamba'
picard='/home/D/pgm/java/picard.java'
macs='/home/D/pgm/bin/macs2'

## reference
ref_fa='/home/D/ref/fasta/gencode_v27/GRCh38.primary_assembly.genome.fa'


### trim the adapters and low-quality reads

adapters='/home/D/ref/fasta/adapters/Adapters_PE.fa'
dir_fq=${dir_wk}'/fastq'
dir_trim=${dir_wk}'/Trim_results'
mkdir -p ${dir_trim}/${sample}
fq1=`ls ${dir_fq}/${sample}/*_R1.fastq.gz`
fq2=`ls ${dir_fq}/${sample}/*_R2.fastq.gz`
fh_r1=`echo ${fq1} | cut -d '/' -f 9`
fh_r2=`echo ${fq2} | cut -d '/' -f 9`
OLD_IFS="$IFS"
IFS="_"
fns_r1=(${fn_r1})
fns_r2=(${fn_r2})
IFS="$OLD_IFS"
filt_fn_r1=${fns_r1[0]}'_'${fns_r1[1]}'_filtered_R1.fastq.gz'
unp_fn_r1=${fns_r1[0]}'_'${fns_r1[1]}'_unpaired_R1.fastq.gz'
filt_fn_r2=${fns_r2[0]}'_'${fns_r2[1]}'_filtered_R2.fastq.gz'
unp_fn_r1=${fns_r2[0]}'_'${fns_r2[1]}'_unpaired_R2.fastq.gz'

${java} -jar ${trim} PE ${fq1} ${fq2} ${dir_trim}/${sample}/${filt_fn_r1} ${dir_trim}/${sample}/${unp_fn_r1} \
        ${dir_trim}/${sample}/${filt_fn_r2} ${dir_trim}/${sample}/${unp_fn_r2} \
		'ILLUMINACLIP:'${adapters}':2:30:10' LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 \
		2> ${dir_trim}/${sample}/read_surviving_stat.txt

### Quality Control of trimmed reads

dir_fqc=${dir_wk}'/Trim_QC_results'
mkdir -p ${dir_fqc}/${sample}
trim_fq=(`ls ${dir_trim}/${sample}/*filtered_*.fastq.gz`)
${fastqc} -t 5 -o ${dir_fqc}/${sample} ${trim_fq[0]} ${trim_fq[1]}

### Alignment
#Note: make sure the bwa index is in the same directory as the ${ref_fa}
dir_alignment=${dir_wk}'/alignment_bwa'
mkdir -p ${dir_alignment}/${sample}
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

### PeakCalling
#Note: You should run input file first
if [${sample} = 'Input']; 
then
	echo "This is an Input sample!\ns"
	exit
fi
input_bam=${dir_alignment}'/Input/Input_alignment_sorted_mkdup.bam'
dir_macs=${dir_wk}'/macs2_results'
mkdir -p ${dir_macs}/${sample}
${macs} callpeak -t ${dir_alignment}/${sample}/${sample}'_alignment_sorted_mkdup.bam' -c ${input_bam} -f BAM -g hs -n ${sample} --outdir ${dir_macs}/${sample}
