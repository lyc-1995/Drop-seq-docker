
ref=$1

host_dir=$PWD
work_dir=/home/mydocker/project

fasta=$work_dir/ref/$ref/${ref}.fa
gtf=$work_dir/ref/$ref/${ref}.gtf

STAR=$work_dir/tools/STAR-2.5.1b/STAR
genomeDir=$work_dir/ref/$ref/star
build_index="mkdir -p $genomeDir && cd $genomeDir && $STAR --runMode genomeGenerate --runThreadN 8 --genomeDir $genomeDir --genomeFastaFiles $fasta --sjdbGTFfile $gtf"

docker run -it -v $host_dir:$work_dir --user=$UID --rm --name=Build_index lyc1995/bio-base:20.04.1 /bin/sh -c "$build_index"
