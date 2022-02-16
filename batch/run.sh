#!/bin/bash

n_files=$1
file_list=$2
output_dir=$3
generator=$4

partition=debug
time=0:20:00

lists_dir=${output_dir}/lists/
log_dir=${output_dir}/log/

mkdir -p $output_dir
mkdir -p $log_dir
mkdir -p $lists_dir

split -l $n_files -d -a 3 --additional-suffix=.list "$file_list" $lists_dir

n_runs=$(ls $lists_dir/*.list | wc -l)

job_range=1-$n_runs

echo file list: $file_list
echo output_dir: $output_dir
echo log_dir: $log_dir
echo lists_dir: $lists_dir
echo n_runs: $n_runs
echo job_range: $job_range

sbatch --wait \
      -J Files \
      -p $partition \
      -t $time \
      -a $job_range \
      -e ${log_dir}/%A_%a.e \
      -o ${log_dir}/%A_%a.o \
      --export=output_dir=$output_dir,file_list=$file_list,lists_dir=$lists_dir,generator=$generator \
      -- /lustre/nyx/hades/user/mmamaev/hades_yield/batch/yield/batch_run.sh

echo JOBS HAVE BEEN COMPLETED!
