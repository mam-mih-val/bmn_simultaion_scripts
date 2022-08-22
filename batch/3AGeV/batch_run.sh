#!/bin/bash
#$ -l h=!(ncx182.jinr.ru|ncx211.jinr.ru|ncx112.jinr.ru|ncx114.jinr.ru|ncx115.jinr.ru|ncx116.jinr.ru|ncx117.jinr.ru)

format='+%Y/%m/%d-%H:%M:%S'

date $format

job_num=$(($SLURM_ARRAY_TASK_ID))
filelist=$lists_dir/$(ls $lists_dir | sed "${job_num}q;d")

cd $output_dir
mkdir -p $job_num
cd $job_num

n_events=1000
input_file=$(head -n 1 $filelist)
output_file=geant_output.root

module add gcc/v11.2.0
module add FairSoft/apr21patches_gcc1120
export FAIRROOTPATH=/lustre/stor1/parfenov/fairroot/install

str_input_file=\"$input_file\"
str_output_file=\"$output_file\"

root -q "/lustre/stor1/parfenov/bmnroot/macro/run/run_sim_bmn.C( $str_input_file, $str_output_file, 0, $n_events, UNIGEN, true, 3.8/4.85 )"

str_input_file=\"$output_file\"
str_output_file=\"dst_$output_file\"

root -q "/lustre/stor1/parfenov/bmnroot/macro/run/run_reco_bmn.C( $str_input_file, $str_output_file, 0, $n_events )"

str_atree_file=\"atree_$output_file\"
str_geometry_file=\"full_geometry.root\"

root -q "/lustre/stor1/parfenov/bmnroot/analysis/common/macro/run_analysis_tree_maker.C( $str_output_file, $str_input_file, $str_geometry_file, $str_atree_file )"

str_common_qa=\"common_qa.root\"
root -q "/lustre/stor1/parfenov/bmnroot/analysis/common/macro/run_analysistree_qa.C( $str_atree_file, $str_common_qa, true )"
str_tracking_qa=\"tracking_qa.root\"
root -q "/lustre/stor1/parfenov/bmnroot/analysis/common/macro/run_tracking_qa.C( $str_atree_file, $str_tracking_qa, true )"

echo PROCESS FINISHED