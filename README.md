# Drop-seq-docker
Pipeline of Drop-seq tools with docker

## Updates

* 2021.01.15 Build the pipeline with following softwares:
  * [Drop-seq-tools-1.13](https://github.com/broadinstitute/Drop-seq/releases/download/v1.13/Drop-seq_tools-1.13.zip)
  * [STAR-2.5.1b](https://github.com/alexdobin/STAR/tree/5dda596)

## Usage

### Preparation

* Install [docker](https://www.docker.com/)

* Put your genome reference files in `ref/<reference_name>` ,  including `<reference_name>.fa` , `<reference_name>.gtf` and STAR-building index files in `star/` . Then, execute this command to build meta data that Drop-seq pipeline needs:

  ```shell
  ./build_meta.sh <reference_name>
  ```

* Put your raw data (formatted as `<sample_name>_[1-2].fastq.gz` or `<sample_name>.bam` ) in `data/<sample_name>/` . If you start with FASTQ, you need to first convert the two .fastq files into .bam:

  ```shell
  ./FastqToBam.sh <sample_name>
  ```

### Run Drop-seq alignment

```shell
./Drop_seq_alignment.sh <reference_name> <sample_name>
```