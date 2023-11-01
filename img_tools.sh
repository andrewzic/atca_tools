#!/bin/bash

#import variables from config
source ./config.sh

dirty_image() {

    data=$1
    stokes=$2
    
    invert vis=${PROJ_DATA}/${data} map=${data}.${stokes}map beam=${data}.${stokes}beam  robust=${robust} stokes=${stokes} options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam

    fits in=${data}.${stokes}map op=xyout out=${data}.${stokes}dirty.fits

    return 0
}

cgcurs_map() {

    data=$1
    stokes=$2
    
    cgcurs in=${data}.${stokes}map type=p range=0,0,log device=/xs labtyp=hms,dms options=region "region=perc(30)"
    mv cgcurs.region ${target}_inner.${freq}.region
    cgcurs in=${data}.${stokes}map type=p range=0,0,log device=/xs labtyp=hms,dms options=region

    cat ${target}_inner.${freq}.region > ${target}_map.${freq}.region
    cat cgcurs.region >> ${target}_map.${freq}.region
    return 0

}

clean_map() {

    data=$1
    stokes=$2
    
    mfclean map=${data}.${stokes}map beam=${data}.${stokes}beam out=${data}.${stokes}model cutoff=${clean_thresh} niters=${clean_niters} region=@${target}_map.${freq}.region

    restor model=${data}.${stokes}model beam=${data}.${stokes}beam map=${data}.${stokes}map out=${data}.${stokes}restor
    
    fits in=${data}.${stokes}restor op=xyout out=$target.${freq}.${stokes}.fits
    
    restor model=${data}.${stokes}model beam=${data}.${stokes}beam map=${data}.${stokes}map mode=residual out=${data}.${stokes}resid

    fits in=${data}.${stokes}resid op=xyout out=$target.${freq}.${stokes}resid.fits

    return 0
}

selfcal_phase_initial() {

    scdata=$1
    data=$2
    stokes=i
    
    cd ${PROJ_ROOT}
    datadir="./data/"
    imgdir="./img/"
    
    selfcal vis=${datadir}/${scdata} model=${imgdir}${data}.${stokes}model interval=2 clip=0.001 options=phase,mfs

    invert vis=${datadir}/${scdata} map=${imgdir}${scdata}.imap beam=${imgdir}${scdata}.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam

    mfclean map=${imgdir}${scdata}.imap beam=${imgdir}${scdata}.ibeam out=${imgdir}${scdata}.imodel cutoff=${clean_thresh} niters=${clean_niters} region=@${imgdir}/${target}_map.${freq}.region

    restor model=${imgdir}${scdata}.imodel beam=${imgdir}${scdata}.ibeam map=${imgdir}${scdata}.imap out=${imgdir}${scdata}.irestor
    
    fits in=${imgdir}${scdata}.irestor op=xyout out=${imgdir}${scdata}.i.fits
    cd ${PROJ_IMG}
    return 0
}



selfcal_phase() {

    data=$1
    model=$2

    cd ${PROJ_ROOT}
    datadir="./data/"
    imgdir="./img/"
    
    selfcal vis=${datadir}/${data} model=${model} interval=2 clip=0.001 options=phase,mfs

    invert vis=${datadir}/${data} map=${imgdir}${data}.imap beam=${imgdir}${data}.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam

    mfclean map=${imgdir}${data}.imap beam=${imgdir}${data}.ibeam out=${imgdir}${data}.imodel cutoff=${clean_thresh} niters=${clean_niters} region=@${imgdir}/${target}_map.${freq}.region

    restor model=${imgdir}${data}.imodel beam=${imgdir}${data}.ibeam map=${imgdir}${data}.imap out=${imgdir}${data}.irestor
    
    fits in=${imgdir}${data}.irestor op=xyout out=${imgdir}${data}.i.fits
    cd ${PROJ_IMG}
    return 0
}


selfcal_phase_sequence() {

    data=$1
    old_data=${data}
    iter=0
    scdata=${data}.selfcal${iter}
    echo ${scdata}
    cp -r ${PROJ_DATA}/${data} ${PROJ_DATA}/${scdata}
    echo "successfully copied ${PROJ_DATA}/${data} ${PROJ_DATA}/${scdata}"

    selfcal_phase_initial ${scdata} ${data}

    #iter=1
    scdata_old=${data}.selfcal0
    while read continue_flag; do
	echo "Type any key and hit enter to continue; enter a blank to stop"
	#if input is blank, then exit loop
	
	if [ ! -z ${continue_flag} ]; then
	    break
	fi
	echo ${iter}
	model=${imgdir}${scdata_old}.imodel
	echo ${model}
	selfcal_phase ${scdata} ${model}

	kvis ${scdata}.i.fits

	scdata_old=${old_data}.selfcal${iter}
	((iter++))
	echo ${iter}
	cp -r ${PROJ_DATA}/${scdata} ${PROJ_DATA}/${old_data}.selfcal${iter}
	scdata=${old_data}.selfcal${iter}
	
    done
    read -s -p "hit enter to continue; type any key and hit enter stop" continue_flag

    return 0
}

uvmodel_mfs() {

    data=$1
    model=$2
    uvmodel vis=${PROJ_DATA}/${data} model=${model} out=${PROJ_DATA}/${data}.uvsub options="subtract,mfs"

    return 0
    
}
