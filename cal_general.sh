#!/bin/bash

#import variables from config file
source ./config.sh

load_data() {

    #load in all the files for this project code
    #note - make sure you discard all files used for array setup before you load data
    atlod in=*.$pcode out=$pcode".uv" options=birdie,noauto,xycorr,rfiflag
    
    #split into 1934-638.<blah blah>
    uvsplit vis=$pcode".uv"

    echo "loaded and split primary cal data"
    return 0
}

auto_flag() {

    src=$1
    
    #do some auto-flagging
    #first do on Stokes V
    pgflag vis=${src}.${freq}${ifext} "command=<b" device=/xs stokes=i,q,u,v flagpar=7,5,5,3,6,3,20 options=nodisp
    #then Q, U
    pgflag vis=${src}.${freq}${ifext} "command=<b" device=/xs stokes=i,v,q,u flagpar=7,5,5,3,6,3,20 options=nodisp
    pgflag vis=${src}.${freq}${ifext} "command=<b" device=/xs stokes=i,v,u,q flagpar=7,5,5,3,6,3,20 options=nodisp
    return 0
}

auto_flag_target() {

    src=$1
    
    #do some auto-flagging
    #on Q, U
    pgflag vis=${src}.${freq}${ifext} "command=<b" device=/xs stokes=i,v,q,u flagpar=7,5,5,3,6,3,20 options=nodisp
    pgflag vis=${src}.${freq}${ifext} "command=<b" device=/xs stokes=i,v,u,q flagpar=7,5,5,3,6,3,20 options=nodisp
    #on I
    pgflag vis=${src}.${freq}${ifext} "command=<b" device=/xs stokes=v,q,u,i flagpar=7,5,5,3,6,3,20 options=nodisp
    #on xx,yy
    pgflag vis=${src}.${freq}${ifext} "command=<b" device=/xs stokes=xy,yx,xx,yy flagpar=7,5,5,3,6,3,20 options=nodisp
    pgflag vis=${src}.${freq}${ifext} "command=<b" device=/xs stokes=xy,yx,yy,xx flagpar=7,5,5,3,6,3,20 options=nodisp

    return 0
}

flag_mfcal() {

    ### unit block for one round of flagging and bandpass calibration
    
    #set the interval
    interval=$1

    #auto-flag
    auto_flag ${pcal}

    #now calibrate
    mfcal vis=${pcal}.${freq}$ifext interval=${interval} refant=${refant}

    #plot spectrum
    uvspec vis=${pcal}.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 options=nobase #all baselines overlaid

    #stop and wait to continue
    read -p "Press enter to continue"

    return 0
}

flag_mfcal_sequence() {

    ###loops through flagging and bandpass calibration until user gives non-blank input
    
    #initial bandpass calibration using 1934
    mfcal vis=${pcal}.${freq}${ifext} interval=15.0 refant=$refant

    echo "doing flag-bandpass cal with interval=1.0"
    
    while read continue_flag; do
	echo "Type any key and hit enter to continue; enter a blank to stop"
	#if input is blank, then exit loop
	if [ ! -z ${continue_flag} ]; then
	    break
	fi
	
	flag_cal 1.0
	
    done

    echo "doing flag-bandpass cal with interval = 0.1"
    while read continue_flag; do
	echo "Type any key and hit enter to continue; enter a blank to stop"
	#if input is blank, then exit loop
	if [ ! -z ${continue_flag} ]; then
	    break
	fi
	
	flag_cal 0.1
	
    done    

    return 0
}


flag_gpcal_primary() {

    #set reference frequency in GHz for gpcal
    spec_freq=$(printf %.1f "$((  10**3 * $( echo ${freq} ) / 1000 ))e-3")
    
    gpcal vis=$pcal.${freq}${ifext} interval=1 options=xyvary minants=3 nfbin=${gpcal_nfbins} spec=${spec_freq} refant=$refant

    #check out primary cal data in real vs imag. This should look like a fat line that extends horizontally on the real axis, and is centered around 0 on the imaginary axis
    uvplt vis=$pcal.${freq}${ifext} axis=real,imag stokes=xx,yy options=nofqav,nobase,equal device=/xs
    #stop and wait to continue
    read -p "Press enter to continue"

    #inspect per baseline
    uvplt vis=$pcal.${freq}${ifext} axis=real,imag stokes=xx,yy options=nofqav nxy=5,3  device=/xs
    #stop and wait to continue
    read -p "Press enter to continue"

    #auto-flag
    auto_flag ${pcal}

    gpcal vis=$pcal.${freq}${ifext} interval=1 options=xyvary minants=3 nfbin=${nfbin} spec=${spec_freq} refant=$refant

    #check out primary cal data in real vs imag. This should look like a fat line that extends horizontally on the real axis, and is centered around 0 on the imaginary axis
    uvplt vis=$pcal.${freq}${ifext} axis=real,imag stokes=xx,yy options=nofqav,nobase,equal device=/xs
    #stop and wait to continue
    read -p "Press enter to continue"

    #inspect per baseline
    uvplt vis=$pcal.${freq}${ifext} axis=real,imag stokes=xx,yy options=nofqav nxy=5,3  device=/xs
    #stop and wait to continue
    read -p "Press enter to continue"

    return 0
}

flag_gpcal_secondary() {

    auto_flag $scal
    
    #set reference frequency in GHz for gpcal
    spec_freq=$(printf %.1f "$((  10**3 * $( echo ${freq} ) / 1000 ))e-3")
    
    gpcal vis=$scal.${freq}${ifext} interval=2 options="xyvary,qusolve,reset" minants=3 nfbin=${gpcal_nfbins} spec=${spec_freq} refant=$refant

    auto_flag $scal
    
    gpcal vis=$scal.${freq}${ifext} interval=0.1 options="xyvary,qusolve,reset" minants=3 nfbin=${gpcal_nfbins} spec=${spec_freq} refant=$refant

    uvspec vis=$scal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 nxy=5,3
    read -p "Press enter to continue"
    #phase vs chan
    uvspec vis=$scal.${freq}${ifext} axis=chan,phase stokes=xx,yy device=/xs interval=9999 nxy=5,3
    read -p "Press enter to continue"
    #amp vs time
    uvplt vis=$scal.${freq}${ifext} axis=time,amp stokes=xx,yy device=/xs interval=9999 nxy=5,3
    read -p "Press enter to continue"
    #phase vs time
    uvplt vis=$scal.${freq}${ifext} axis=time,phase stokes=xx,yy device=/xs interval=9999 nxy=5,3
    read -p "Press enter to continue"

    #check out secondary cal data in real vs imag. This should look like a fat line that extends horizontally on the real axis, and is centered around 0 on the imaginary axis
    uvplt vis=$scal.${freq}${ifext} axis=real,imag stokes=xx,yy options=nofqav,nobase,equal device=/xs
    #stop and wait to continue
    read -p "Press enter to continue"

    #inspect per baseline
    uvplt vis=$scal.${freq}${ifext} axis=real,imag stokes=xx,yy options=nofqav nxy=5,3  device=/xs
    #stop and wait to continue
    read -p "Press enter to continue"

    return 0
}





if [[ $start_fresh == 1 ]]; then

    #delete all files before a new run
    rm -fr ${pcode}*.uv *.2100* *.5500 *.9000

fi

load_data

flag_mfcal_sequence

flag_gpcal_primary

gpcopy vis=$pcal.${freq}${ifext} out=$scal.${freq}${ifext}

flag_gpcal_secondary

#assuming all OK, apply flux scale from primary cal onto secondary:
gpboot vis=$scal.${freq}${ifext} cal=$pcal.${freq}${ifext};

#now copy calibration solutions to target data
gpcopy vis=$scal.${freq}${ifext} out=$target.${freq}${ifext};

#now average gain solutions over the 2-minute interval when on the secondary-cal
gpaver vis=$target.${freq}${ifext} interval=2


flag_target

#now apply calibrations to target using uvaver
uvaver vis=$target.${freq}${ifext} out=$target.${freq}${ifext}.cal

#and also to the secondary cal
uvaver vis=$scal.${freq}${ifext} out=$scal.${freq}${ifext}.cal

#this concludes the calibration


