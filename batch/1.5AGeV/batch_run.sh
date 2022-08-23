#!/bin/bash

format='+%Y/%m/%d-%H:%M:%S'

date $format

job_num=$(($SLURM_ARRAY_TASK_ID))
filelist=$lists_dir/$(ls $lists_dir | sed "${job_num}q;d")

cd $output_dir
mkdir -p $job_num
cd $job_num

n_events=500
input_file=$(head -n 1 $filelist)
output_file=geant_output.root
sim_file_name=sim.root
rec_file_name=rec.root
atree_file_name=atree.root
common_qa_file_name=common.root
tracking_qa_file_name=tracking.root

module add GVR/v1.0-1
module add gcc/v11.2.0
module add FairSoft/apr21patches_gcc1120
export FAIRROOTPATH=/lustre/stor1/parfenov/fairroot/install
source /lustre/stor1/parfenov/bmnroot/build-centos7/config.sh

echo $SIMPATH
echo $FAIRROOTPATH

export G4PARTICLEXSDATA=$SIMPATH/share/Geant4-10.7.1/data/G4PARTICLEXS3.1.1/
export G4ENSDFSTATEDATA=$SIMPATH/share/Geant4-10.7.1/data/G4ENSDFSTATE2.3/
export G4ABLADATA=$SIMPATH/share/Geant4-10.7.1/data/G4ABLA3.1/
export G4LEDATA=$SIMPATH/share/Geant4-10.7.1/data/G4EMLOW7.13/
export G4LEVELGAMMADATA=$SIMPATH/share/Geant4-10.7.1/data/PhotonEvaporation5.7/
export G4NEUTRONHPDATA=$SIMPATH/share/Geant4-10.7.1/data/G4NDL4.6/
export G4PIIDATA=$SIMPATH/share/Geant4-10.7.1/data/G4PII1.3/
export G4RADIOACTIVEDATA=$SIMPATH/share/Geant4-10.7.1/data/RadioactiveDecay5.6/
export G4REALSURFACEDATA=$SIMPATH/share/Geant4-10.7.1/data/RealSurface2.2/

for start in 0 500
do
  str_input_file=\"$input_file\"
  str_sim_file_name=\"$((start))_$((sim_file_name))\"
  str_rec_file_name=\"$((start))_$((rec_file_name))\"
  str_atree_file_name=\"$((start))_$((atree_file_name))\"
  str_common_file_name=\"$((start))_$((common_qa_file_name))\"
  str_tracking_file_name=\"$((start))_$((tracking_qa_file_name))\"
  str_geometry_file=\"full_geometry.root\"

  root -q "/lustre/stor1/parfenov/bmnroot/macro/run/run_sim_bmn.C( $str_input_file, $str_sim_file_name, $start, $((start+n_events)), UNIGEN, true, 2.25/4.85 )"

  root -q "/lustre/stor1/parfenov/bmnroot/macro/run/run_reco_bmn.C( $str_sim_file_name, $str_rec_file_name, 0, $n_events )"

  root -q "/lustre/stor1/parfenov/bmnroot/analysis/common/macro/run_analysis_tree_maker.C( $str_rec_file_name, $str_sim_file_name, $str_geometry_file, $str_atree_file_name, 2.517 )"

  root -q "/lustre/stor1/parfenov/bmnroot/analysis/common/macro/run_analysistree_qa.C( $str_atree_file_name, $str_common_file_name, true )"

  root -q "/lustre/stor1/parfenov/bmnroot/analysis/common/macro/run_tracking_qa.C( $str_atree_file_name, $str_tracking_file_name, true )"
done
echo PROCESS FINISHED