#!/bin/bash

format='+%Y/%m/%d-%H:%M:%S'

date $format

job_num=$(($SGE_TASK_ID))
filelist=$lists_dir/$(ls $lists_dir | sed "${job_num}q;d")

cd $output_dir
mkdir -p $job_num
cd $job_num

n_events=1000
input_file=$(head -n 1 $filelist)
output_file=geat_output.root

source /cvmfs/nica.jinr.ru/sw/os/login.sh
module add GCC-Toolchain/

source /scratch1/mmamaev/bmn_environment.sh

str_input_file=\"$input_file\"
str_output_file=\"$output_file\"

root -q "/scratch1/mmamaev/bmn_simultaion_scripts/macro/run_sim_bmn.C( $str_input_file, $str_output_file, 0, $n_events, $generator, $field )"

str_input_file=\"$output_file\"
str_output_file=\"dst_$output_file\"

root -q "/scratch1/mmamaev/bmnroot/macro/run/run_reco_bmn.C( $str_input_file, $str_output_file, 0, $n_events, $field )"

str_atree_file=\"atree_$output_file\"
str_geometry_file=\"full_geometry.root\"

root -q "/scratch1/mmamaev/bmnroot/analysis/common/macro/run_analysis_tree_maker.C( $str_output_file, $str_input_file, $str_geometry_file, $str_atree_file )"

str_common_qa=\"common_qa.root\"
root -q "/scratch1/mmamaev/bmnroot/analysis/common/macro/run_analysistree_qa.C( $str_atree_file, $str_common_qa, true )"
str_tracking_qa=\"tracking_qa.root\"
root -q "/scratch1/mmamaev/bmnroot/analysis/common/macro/run_tracking_qa.C( $str_atree_file, $str_tracking_qa, true )"

echo PROCESS FINISHED