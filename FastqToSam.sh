
sample=$1

host_dir=$PWD
work_dir=/home/mydocker/project

sample_dir=$work_dir/data/$sample

dropseq_dir=$work_dir/tools/Drop-seq_tools-1.13

picard=$dropseq_dir/3rdParty/picard/picard.jar

# FastqToSam
FastqToSam="java -jar $picard FastqToSam F1=$sample_dir/${sample}_1.fastq.gz F2=$sample_dir/${sample}_2.fastq.gz O=$sample_dir/${sample}.bam SM=$sample"

docker run -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$FastqToSam"

