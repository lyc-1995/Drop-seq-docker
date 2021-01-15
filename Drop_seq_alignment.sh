#!/bin/bash
set -o errexit

ref=$1
sample=$2

host_dir=$PWD
work_dir=/home/mydocker/project

sample_dir=$work_dir/data/$sample

ref_dir=$work_dir/ref/$ref

dropseq_dir=$work_dir/tools/Drop-seq_tools-1.13

picard=$dropseq_dir/3rdParty/picard/picard.jar

STAR=$work_dir/tools/STAR-2.5.1b/STAR

# TagBamWithReadSequenceExtended
TagBamWithReadSequenceExtended_bc="$dropseq_dir/TagBamWithReadSequenceExtended \
	INPUT=$sample_dir/${sample}.bam \
	OUTPUT=$sample_dir/${sample}_unaligned_tagged_Cell.bam \
	SUMMARY=$sample_dir/${sample}_unaligned_tagged_Cellular.bam_summary.txt \
	BASE_RANGE=1-­12 \
	BASE_QUALITY=10 \
	BARCODED_READ=1 \
	DISCARD_READ=False \
	TAG_NAME=XC \
	NUM_BASES_BELOW_QUALITY=1"

TagBamWithReadSequenceExtended_umi="$dropseq_dir/TagBamWithReadSequenceExtended \
	INPUT=$sample_dir/${sample}_unaligned_tagged_Cell.bam \
	OUTPUT=$sample_dir/${sample}_unaligned_tagged_CellMolecular.bam \
	SUMMARY=$sample_dir/${sample}_unaligned_tagged_Molecular.bam_summary.txt \
	BASE_RANGE=13-­20 \
	BASE_QUALITY=10 \
	BARCODED_READ=1 \
	DISCARD_READ=True \
	TAG_NAME=XM \
	NUM_BASES_BELOW_QUALITY=1"

# FilterBAM
FilterBAM="$dropseq_dir/FilterBAM \
	TAG_REJECT=XQ \
	INPUT=$sample_dir/${sample}_unaligned_tagged_CellMolecular.bam \
	OUTPUT=$sample_dir/${sample}_unaligned_tagged_filtered.bam"

# TrimStartingSequence
TrimStartingSequence="$dropseq_dir/TrimStartingSequence \
	INPUT=$sample_dir/${sample}_unaligned_tagged_filtered.bam \
	OUTPUT=$sample_dir/${sample}_unaligned_tagged_trimmed_smart.bam \
	OUTPUT_SUMMARY=$sample_dir/${sample}_adapter_trimming_report.txt \
	SEQUENCE=AAGCAGTGGTATCAACGCAGAGTGAATGGG \
	MISMATCHES=0 \
	NUM_BASES=5"

# PolyATrimmer
PolyATrimmer="$dropseq_dir/PolyATrimmer \
	INPUT=$sample_dir/${sample}_unaligned_tagged_trimmed_smart.bam \
	OUTPUT=$sample_dir/${sample}_unaligned_mc_tagged_polyA_filtered.bam \
	OUTPUT_SUMMARY=$sample_dir/${sample}_polyA_trimming_report.txt \
	MISMATCHES=0 \
	NUM_BASES=6"

# SamToFastq
SamToFastq="java -Xmx4g -jar $picard SamToFastq INPUT=$sample_dir/${sample}_unaligned_mc_tagged_polyA_filtered.bam FASTQ=$sample_dir/${sample}_unaligned_mc_tagged_polyA_filtered.fastq"

# STAR
STAR_align="cd $sample_dir && $STAR --runThreadN 4 --genomeDir $ref_dir/star --readFilesIn $sample_dir/${sample}_unaligned_mc_tagged_polyA_filtered.fastq --outFileNamePrefix ${sample}_star"

# SortSam
SortSam="java -Xmx4g -jar $picard SortSam I=$sample_dir/${sample}_starAligned.out.sam O=$sample_dir/${sample}_aligned.sorted.bam SO=queryname"

# MergeBamAlignment
MergeBamAlignment="java -Xmx4g -jar $picard MergeBamAlignment \
	REFERENCE_SEQUENCE=$ref_dir/${ref}.fa \
	UNMAPPED_BAM=$sample_dir/${sample}_unaligned_mc_tagged_polyA_filtered.bam \
	ALIGNED_BAM=$sample_dir/${sample}_aligned.sorted.bam \
	OUTPUT=$sample_dir/${sample}_merged.bam \
	INCLUDE_SECONDARY_ALIGNMENTS=false \
	PAIRED_RUN=false"

# TagReadWithGeneExon
TagReadWithGeneExon="$dropseq_dir/TagReadWithGeneExon \
	I=$sample_dir/${sample}_merged.bam \
	O=$sample_dir/${sample}_star_gene_exon_tagged.bam \
	ANNOTATIONS_FILE=$ref_dir/${ref}.gtf \
	TAG=GE"

# DetectBeadSynthesisErrors
DetectBeadSynthesisErrors="$dropseq_dir/DetectBeadSynthesisErrors \
	I=$sample_dir/${sample}_star_gene_exon_tagged.bam \
	O=$sample_dir/${sample}_star_gene_exon_tagged_clean.bam \
	OUTPUT_STATS=$sample_dir/${sample}.synthesis_stats.txt \
	SUMMARY=$sample_dir/${sample}.synthesis_stats.summary.txt \
	NUM_BARCODES=2000 \
	PRIMER_SEQUENCE=AAGCAGTGGTATCAACGCAGAGTAC"

# DigitalExpression
DigitalExpression="$dropseq_dir/DigitalExpression \
	I=$sample_dir/${sample}_star_gene_exon_tagged_clean.bam \
	O=$sample_dir/${sample}_out_gene_exon_tagged.dge.txt.gz \
	SUMMARY=$sample_dir/${sample}_out_gene_exon_tagged.dge.summary.txt \
	MIN_NUM_GENES_PER_CELL=200"

# Finish
Finish="cp $sample_dir/${sample}_out_gene_exon_tagged.dge.txt.gz $sample_dir/${sample}.dge.txt.gz"

#######################################################################################################################
echo "========== Step1 Tag cell barcode ==========" && \
docker run  -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$TagBamWithReadSequenceExtended_bc" && \
echo "Finished" && \

echo "========== Step2 Tag UMI ==========" && \
docker run  -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$TagBamWithReadSequenceExtended_umi" && \
echo "Finished" && \

echo "========== Step3 Remove low-quality barcodes ==========" && \
docker run  -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$FilterBAM" && \
echo "Finished" && \

echo "========== Step4 Remove the SMART Adapter ==========" && \
docker run  -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$TrimStartingSequence" && \
echo "Finished" && \

echo "========== Step5 Remove poly-A tail ==========" && \
docker run  -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$PolyATrimmer" && \
echo "Finished" && \

echo "========== Step6 Convert to FASTQ ==========" && \
docker run  -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$SamToFastq" && \
echo "Finished" && \

echo "========== Step7 Align reads ==========" && \
docker run  -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$STAR_align" && \
echo "Finished" && \

echo "========== Step8 Sort BAM ==========" && \
docker run -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$SortSam" && \
echo "Finished" && \

echo "========== Step9 Merge the sorted BAM ==========" && \
docker run -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$MergeBamAlignment" && \
echo "Finished" && \

echo "========== Step10 Tag reads with exon ==========" && \
docker run  -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$TagReadWithGeneExon" && \
echo "Finished" && \

echo "========== Step11 Detect bead synthesis errors ==========" && \
docker run  -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$DetectBeadSynthesisErrors" && \
echo "Finished" && \

echo "========== Step12 Generate DGE matrix ==========" && \
docker run  -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$DigitalExpression" && \
echo "Finished" && \

echo "========== Step13 Rename DGE matrix ==========" && \
docker run  -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$Finish" && \
echo "Finished" && \

echo "########## All pipeline complete! ##########"

