#!/bin/bash

n_events=$1
generator=$2
input_file=$3
output_file=$4

source /mnt/pool/nica/7/mam2mih/soft/basov/bmn_environment.sh

str_input_file=\"$input_file\"
str_output_file=\"$output_file\"

root -q "/lustre/nyx/hades/user/mmamaev/bmn_simultaion_scripts/src/run_sim_bmn.C( $str_input_file, $str_output_file, 0, $n_events, $generator )"

str_input_file=\"$output_file\"
str_output_file=\"dst_$output_file\"

root -q "/lustre/nyx/hades/user/mmamaev/bmn_simultaion_scripts/src/run_reco_bmn.C( $str_input_file, $str_output_file, 0, $n_events )"

echo PROCESS FINISHED