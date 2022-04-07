#!/bin/bash

format='+%Y/%m/%d-%H:%M:%S'

date $format

job_num=$(($SLURM_ARRAY_TASK_ID))
filelist=$lists_dir/$(ls $lists_dir | sed "${job_num}q;d")

cd $output_dir
mkdir -p $job_num
cd $job_num

n_events=1000
input_file=$(head -n 1 $filelist)
output_file=geat_output.root

source /mnt/pool/nica/7/mam2mih/soft/basov/bmn_environment.sh

str_input_file=\"$input_file\"
str_output_file=\"$output_file\"

#root -q "/mnt/pool/nica/7/mam2mih/soft/basov/bmnroot-mamaev/macro/run8/run_sim_bmn.C( $str_input_file, $str_output_file, 0, $n_events, $generator )"

str_input_file=\"$output_file\"
str_output_file=\"dst_$output_file\"

#root -q "/mnt/pool/nica/7/mam2mih/soft/basov/bmnroot-mamaev/macro/run8/run_reco_bmn.C( $str_input_file, $str_output_file, 0, $n_events )"

str_atree_file=\"atree_$output_file\"

root -q "/mnt/pool/nica/7/mam2mih/soft/basov/bmnroot-mamaev/analysis/common/macro/run_analysis_tree_maker.C( $str_output_file, $str_input_file, '"full_geometry.root"', $str_atree_file )"

root -q "/mnt/pool/nica/7/mam2mih/soft/basov/bmnroot-mamaev/analysis/common/macro/run_analysistree_qa.C( $str_atree_file, true )"

echo PROCESS FINISHED