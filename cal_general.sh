#!/bin/bash

#import variables from config file
source ./config.sh
source ./cal_tools.sh

restart_proc

load_data

flag_mfcal_sequence

#for manual flagging
blflag_data $pcal chan amp
blflag_data $pcal time phase

flag_mfcal_sequence

flag_gpcal_primary

gpcopy vis=$pcal.${freq}${ifext} out=$scal.${freq}${ifext}

flag_gpcal_secondary
flag_gpcal_secondary

#assuming all OK, apply flux scale from primary cal onto secondary:
gpboot vis=$scal.${freq}${ifext} cal=$pcal.${freq}${ifext};

#now copy calibration solutions to target data
gpcopy vis=$scal.${freq}${ifext} out=$target.${freq}${ifext};

#now average gain solutions over the 2-minute interval when on the secondary-cal
gpaver vis=$target.${freq}${ifext} interval=2


auto_flag $target

#now apply calibrations to target using uvaver
uvaver vis=$target.${freq}${ifext} out=$target.${freq}${ifext}.cal

#and also to the secondary cal
uvaver vis=$scal.${freq}${ifext} out=$scal.${freq}${ifext}.cal

#this concludes the calibration


