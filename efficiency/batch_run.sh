#!/bin/bash
#$ -l h=!(ncx182.jinr.ru|ncx211.jinr.ru)

format='+%Y/%m/%d-%H:%M:%S'

date $format

job_num=$(($SGE_TASK_ID))
filelist=$lists_dir/$(ls $lists_dir | sed "${job_num}q;d")

cd $output_dir
mkdir -p $job_num
cd $job_num

source /cvmfs/nica.jinr.ru/sw/os/login.sh
module add GCC-Toolchain/

source /scratch1/mmamaev/bmn_environment.sh
echo
date
echo "Running preprocessing ..."

input_list=\"$filelist\"
output_file=\"out.root\"
root -q "/scratch1/mmamaev/bmnroot/analysis/common/macro/run_tracking_qa.C( $input_list, $output_file )"

echo PROCESS FINISHED