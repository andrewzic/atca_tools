#!/bin/bash

#import variables from config
source ./config.sh

dirty_image() {

    data=$1
    stokes=$2
    
    invert vis=${data} map=${data}.${stokes}map beam=${data}.${stokes}beam  robust=${robust} stokes=${stokes} options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam

    fits in=${data}.${stokes}map op=xyout out=${data}.${stokes}dirty.fits

    return 0
}

cgcurs_map() {

    data=$1
    
    cgcurs in=${data}.${stokes}map type=p range=0,0,log device=/xs labtyp=hms,dms options=region "region=perc(30)"
    mv cgcurs.region ${target}_inner.region
    cgcurs in=${data}.${stokes}map type=p range=0,0,log device=/xs labtyp=hms,dms options=region

    cat ${target}_inner.region > ${target}_map.region
    cat cgcurs.region >> ${target}_map.region
    return 0

}

clean_map() {

    data=$1
    stokes=$2
    
    mfclean map=${data}.${stokes}map beam=${data}.${stokes}beam out=${data}.${stokes}model cutoff=${clean_thresh} niters=${clean_niters} region=@${target}_map.region

    restor model=${data}.${stokes}model beam=${data}.${stokes}beam map=${data}.${stokes}map out=${data}.${stokes}restor
    
    fits in=${data}.${stokes}restor op=xyout out=$target.${stokes}.fits
    
    restor model=${data}.${stokes}model beam=${data}.${stokes}beam map=${data}.${stokes}map mode=residual out=${data}.${stokes}resid

    fits in=${data}.${stokes}resid op=xyout out=$target.${stokes}resid.fits

    return 0
}

selfcal_phase() {

    data=$1
    iter=$2
    
    selfcal vis=${data} model=${data}.imodel interval=2 clip=0.001 options=phase,mfs

    invert vis=${data} map=${data}.sc${iter}.imap beam=${data}.sc${iter}.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam

    mfclean map=${data}.sc${iter}.imap beam=${data}.sc${iter}.ibeam out=${data}.sc${iter}.imodel cutoff=${clean_thresh} niters=${clean_niters} region=@${target}_map.region

    restor model=${data}.sc${iter}.imodel beam=${data}.sc${iter}.ibeam map=${data}.sc${iter}.imap out=${data}.sc${iter}.irestor
    
    fits in=${data}.sc${iter}.irestor op=xyout out=${data}.sc${iter}.i.fits

    return 0
}


selfcal_phase_sequence() {

    data=$1
    iter=0
    scdata = ${data}.selfcal${iter}
    cp -r ${data} ${scdata}
    
    while read continue_flag; do
	echo "Type any key and hit enter to continue; enter a blank to stop"
	#if input is blank, then exit loop
	if [ ! -z ${continue_flag} ]; then
	    break
	fi

	selfcal_phase ${scdata} ${iter}

	kvis ${scdata}.sc${iter}.i.fits
	
	((iter++))

	cp -r ${scdata} ${data}.selfcal${iter}
	scdata=${data}.selfcal${iter}
	
    done

    return 0
}

uvmodel_mfs() {

    data=$1
    model=$2
    uvmodel vis=${data} model=${model} options="subtract,mfs"

    return 0
    
}
