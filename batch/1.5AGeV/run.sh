#!/bin/bash

file_list=$1
output_dir=$2
generator=$3

partition=mpd
time=14:00:00

output_dir=${output_dir}/$(basename ${file_list})
lists_dir=${output_dir}/lists/
log_dir=${output_dir}/log/

mkdir -p $output_dir
mkdir -p $log_dir
mkdir -p $lists_dir

split -l 1 -d -a 3 --additional-suffix=.list "$file_list" $lists_dir

n_runs=$(ls $lists_dir/*.list | wc -l)

job_range=1-$n_runs

echo file list: $file_list
echo output_dir: $output_dir
echo log_dir: $log_dir
echo lists_dir: $lists_dir
echo n_runs: $n_runs
echo job_range: $job_range

sbatch -J Files \
      -p $partition \
      -q dirac \
      -t $time \
      -a $job_range \
      -e ${log_dir}/%A_%a.e \
      -o ${log_dir}/%A_%a.o \
      --export=output_dir=$output_dir,file_list=$file_list,lists_dir=$lists_dir,generator=$generator \
      -- /lustre/stor1/parfenov/bmn_simultaion_scripts/batch/1.5AGeV/batch_run.sh

echo JOBS HAVE BEEN COMPLETED!