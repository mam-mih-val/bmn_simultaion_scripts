#!/bin/bash

n_events=$1
generator=$2
input_file=$3
output_file=$4

export SIMPATH=/cvmfs/fairsoft.gsi.de/debian10/fairsoft/apr21p2/
export FAIRROOTPATH=/cvmfs/fairsoft.gsi.de/debian10/fairroot/v18.6.7_fs_apr21p2/

source /lustre/hades/user/mmamaev/bmnroot/build/config.sh

export G4PARTICLEXSDATA=$SIMPATH/share/Geant4-10.7.1/data/G4PARTICLEXS3.1.1/
export G4ENSDFSTATEDATA=$SIMPATH/share/Geant4-10.7.1/data/G4ENSDFSTATE2.3/
export G4ABLADATA=$SIMPATH/share/Geant4-10.7.1/data/G4ABLA3.1/
export G4LEDATA=$SIMPATH/share/Geant4-10.7.1/data/G4EMLOW7.13/
export G4LEVELGAMMADATA=$SIMPATH/share/Geant4-10.7.1/data/PhotonEvaporation5.7/
export G4NEUTRONHPDATA=$SIMPATH/share/Geant4-10.7.1/data/G4NDL4.6/
export G4PIIDATA=$SIMPATH/share/Geant4-10.7.1/data/G4PII1.3/
export G4RADIOACTIVEDATA=$SIMPATH/share/Geant4-10.7.1/data/RadioactiveDecay5.6/
export G4REALSURFACEDATA=$SIMPATH/share/Geant4-10.7.1/data/RealSurface2.2/

str_input_file=\"$input_file\"
str_output_file=\"$output_file\"

root -q "/lustre/nyx/hades/user/mmamaev/bmn_simultaion_scripts/src/run_sim_bmn.C( $str_input_file, $str_output_file, 0, $n_events, $generator )"

str_input_file=\"$output_file\"
str_output_file=\"dst_$output_file\"

root -q "/lustre/nyx/hades/user/mmamaev/bmn_simultaion_scripts/src/run_reco_bmn.C( $str_input_file, $str_output_file, 0, $n_events )"

echo PROCESS FINISHED