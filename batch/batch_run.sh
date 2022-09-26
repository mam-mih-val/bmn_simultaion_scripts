#!/bin/bash
#$ -l h=!(ncx182.jinr.ru|ncx211.jinr.ru|ncx112.jinr.ru|ncx114.jinr.ru|ncx115.jinr.ru|ncx116.jinr.ru|ncx117.jinr.ru)

format='+%Y/%m/%d-%H:%M:%S'

date $format

job_num=$(($SGE_TASK_ID))
filelist=$lists_dir/$(ls $lists_dir | sed "${job_num}q;d")

cd $output_dir
mkdir -p $job_num
cd $job_num

n_events=1000
input_file=\"$(head -n 1 $filelist)\"

source /cvmfs/nica.jinr.ru/sw/os/login.sh
module add GCC-Toolchain/
source /scratch1/mmamaev/bmn_environment.sh

sim_file_name=\"sim.root\"
rec_file_name=\"rec.root\"
geometry_file=\"full_geometry.root\"
atree_file_name=\"atree.root\"
common_qa_file_name=\"common.root\"
tracking_qa_file_name=\"tracking.root\"

root -q "/scratch1/mmamaev/bmnroot-gitlab/macro/run/run_sim_bmn.C( $input_file, $sim_file_name, 0, $n_events, UNIGEN, true, 2.25/4.85 )"

root -q "/scratch1/mmamaev/bmnroot-gitlab/macro/run/run_reco_bmn.C( $sim_file_name, $rec_file_name, 0, $n_events )"

root -q "/scratch1/mmamaev/bmnroot-gitlab/analysis/common/macro/run_analysis_tree_maker.C( $rec_file_name, $sim_file_name, $geometry_file, $atree_file_name, 2.517 )"

root -q "/scratch1/mmamaev/bmnroot-gitlab/analysis/common/macro/run_analysistree_qa.C( $atree_file_name, $common_qa_file_name, true )"

root -q "/scratch1/mmamaev/bmnroot-gitlab/analysis/common/macro/run_tracking_qa.C( $atree_file_name, $tracking_qa_file_name, true )"

echo PROCESS FINISHED