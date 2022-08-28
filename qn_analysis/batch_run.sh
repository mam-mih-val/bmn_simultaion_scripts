#!/bin/bash
#$ -l h=!(ncx182.jinr.ru|ncx211.jinr.ru)

format='+%Y/%m/%d-%H:%M:%S'

date $format

job_num=$(($SLURM_ARRAY_TASK_ID))
filelist=$lists_dir/$(ls $lists_dir | sed "${job_num}q;d")

cd $output_dir
mkdir -p $job_num
cd $job_num

source /cvmfs/nica.jinr.ru/sw/os/login.sh
module add GCC-Toolchain/

source /lustre/stor1/parfenov/bmn_environment.sh
echo
date
echo "Running preprocessing ..."
/lustre/stor1/parfenov/bmn_preprocessing/build/src/pre_process \
                                                        -i $filelist \
                                                        -t rTree \
                                                        --output-tree-name eTree \
                                                        -e /lustre/stor1/parfenov/bmn_preprocessing/efficiency/efficiency.root \
                                                        -o extra.root
ls $(pwd)/extra.root > extra.list
echo
date
echo "Running correction 1st step ..."
/lustre/stor1/parfenov/QnAnalysis/build/src/QnAnalysisCorrect/QnAnalysisCorrect \
                                                                          -i $filelist extra.list \
                                                                          -t rTree eTree \
                                                                          -o correction_out.root \
                                                                          --yaml-config-file /lustre/stor1/parfenov/QnAnalysis/setups/bmatn/xecs_corrections.yml \
                                                                          --yaml-config-name BMN
mv correction_out.root correction_in.root
echo
date
echo "Running correction 2nd step ..."
/lustre/stor1/parfenov/QnAnalysis/build/src/QnAnalysisCorrect/QnAnalysisCorrect \
                                                                          -i $filelist extra.list \
                                                                          -t rTree eTree \
                                                                          -o correction_out.root \
                                                                          --yaml-config-file /lustre/stor1/parfenov/QnAnalysis/setups/bmatn/xecs_corrections.yml \
                                                                          --yaml-config-name BMN
mv correction_out.root correction_in.root
echo
date
echo "Running correction 3d step ..."
/lustre/stor1/parfenov/QnAnalysis/build/src/QnAnalysisCorrect/QnAnalysisCorrect \
                                                                          -i $filelist extra.list \
                                                                          -t rTree eTree \
                                                                          -o correction_out.root \
                                                                          --yaml-config-file /lustre/stor1/parfenov/QnAnalysis/setups/bmatn/xecs_corrections.yml \
                                                                          --yaml-config-name BMN

echo
date
echo "Running correlation ..."
/lustre/stor1/parfenov/QnAnalysis/build/src/QnAnalysisCorrelate/QnAnalysisCorrelate \
                                                                              --input-file correction_out.root \
                                                                              --configuration-file /lustre/stor1/parfenov/QnAnalysis/setups/bmatn/xecs_correlations.yml \
                                                                              --configuration-name _tasks \
                                                                              -o correlation_out.root

echo PROCESS FINISHED