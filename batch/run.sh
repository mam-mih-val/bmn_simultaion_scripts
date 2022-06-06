#!/bin/bash

file_list=$1
output_dir=$2
generator=$3

time=14:00:00

working_dir=/var/tmp/mmamaev/${output_dir}/$(basename ${file_list})
output_dir=${output_dir}/$(basename ${file_list})
lists_dir=${output_dir}/lists/
log_dir=${output_dir}/log/

mkdir -p $working_dir
mkdir -p $output_dir
mkdir -p $log_dir
mkdir -p $lists_dir

split -l 1 -d -a 5 --additional-suffix=.list "$file_list" $lists_dir

n_runs=$(ls $lists_dir/*.list | wc -l)

job_range=1-$n_runs

echo file list: $file_list
echo working_dir: $working_dir
echo output_dir: $output_dir
echo log_dir: $log_dir
echo lists_dir: $lists_dir
echo n_runs: $n_runs
echo job_range: $job_range

qsub  -wd $PWD -cwd \
      -N BMN-SIM \
      -l h_rt=$time \
      -l s_rt=$time \
      -t $job_range \
      -e ${log_dir}/ \
      -o ${log_dir}/ \
      -v output_dir=$output_dir,file_list=$file_list,lists_dir=$lists_dir,generator=$generator \
      /scratch1/mmamaev/bmn_simultaion_scripts/batch/batch_run.sh

echo JOBS HAVE BEEN SUBMITTED!
