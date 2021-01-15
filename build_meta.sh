
ref=$1

host_dir=$PWD
work_dir=/home/mydocker/project

fasta=$work_dir/ref/$ref/${ref}.fa
gtf=$work_dir/ref/$ref/${ref}.gtf

dropseq_dir=$work_dir/tools/Drop-seq_tools-1.13

picard=$dropseq_dir/3rdParty/picard/picard.jar

# CreateSequenceDictionary
dict=$work_dir/ref/$ref/${ref}.dict
CreateSequenceDictionary="java -jar $picard CreateSequenceDictionary R=$fasta O=$dict"

docker run -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$CreateSequenceDictionary"

# ConvertToRefFlat
refFlat=$work_dir/ref/$ref/${ref}.refFlat
ConvertToRefFlat="$dropseq_dir/ConvertToRefFlat ANNOTATIONS_FILE=$gtf SEQUENCE_DICTIONARY=$dict OUTPUT=$refFlat"

docker run -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$ConvertToRefFlat"

# ReduceGTF
reduced_gtf=$work_dir/ref/$ref/${ref}.reduced.gtf
ReduceGTF="$dropseq_dir/ReduceGTF SEQUENCE_DICTIONARY=$dict GTF=$gtf OUTPUT=$reduced_gtf"

docker run -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$ReduceGTF"

# CreateIntervalsFiles
CreateIntervalsFiles="$dropseq_dir/CreateIntervalsFiles SEQUENCE_DICTIONARY=$dict REDUCED_GTF=$reduced_gtf PREFIX=$ref OUTPUT=$work_dir/ref/$ref/"

docker run -v $host_dir:/home/mydocker/project/ --user=$UID --rm lyc1995/bio-base:20.04.1 /bin/sh -c "$CreateIntervalsFiles"
