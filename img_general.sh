#!/bin/bash

#import variables from config file
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

	selfcal_phase() ${scdata} ${iter}

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


dirty_image $target.${freq}${ifext}.cal i

cgcurs_map i

clean_map $target.${freq}${ifext}.cal i

uvmodel_mfs $target.${freq}${ifext}.cal ${target}.${freq}${ifext}.cal.imodel

selfcal_phase_sequence ${target}.${freq}${ifext}.cal


# invert vis=$target.${freq}${ifext}.cal map=$target.${freq}${ifext}.cal.imap beam=$target.${freq}${ifext}.cal.ibeam  robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam

# invert vis=$target.${freq}${ifext}.cal map=$target.${freq}${ifext}.cal.vmap beam=$target.${freq}${ifext}.cal.vbeam  robust=${robust} stokes=v options=mfs,sdb imsize=1,1,beam

# fits in=$target.${freq}${ifext}.cal.imap op=xyout out=$target.${freq}.idirty.fits
# fits in=$target.${freq}${ifext}.cal.vmap op=xyout out=$target.${freq}.vdirty.fits
# #fits in=$target.${freq}${ifext}.cal.ibeam op=xyout out=$target.${freq}.dirtybeam.fits

# cgdisp in=$target.${freq}${ifext}.cal.imap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge "region=perc(30)"
# imlist in=$target.${freq}${ifext}.cal.imap options=statistics

# cgcurs in=$target.${freq}${ifext}.cal.imap type=p range=0,0,log device=/xs labtyp=hms,dms options=region "region=perc(30)"

# mv cgcurs.region ${target}_inner.region

# cgcurs in=$target.${freq}${ifext}.cal.imap type=p range=0,0,log device=/xs labtyp=hms,dms options=region 

# cat ${target}_inner.region > ${target}_map.region
# cat cgcurs.region >> ${target}_map.region
# #cp cgcurs.region $target.region

# mfclean map=$target.${freq}${ifext}.cal.imap beam=$target.${freq}${ifext}.cal.ibeam out=$target.${freq}${ifext}.cal.imodel cutoff=6e-5 niters=10000 region=@${target}_map.region

# restor model=$target.${freq}${ifext}.cal.imodel beam=$target.${freq}${ifext}.cal.ibeam map=$target.${freq}${ifext}.cal.imap out=$target.${freq}${ifext}.cal.irestor

# fits in=$target.${freq}${ifext}.cal.irestor op=xyout out=$target.i.fits

# restor model=$target.${freq}${ifext}.cal.imodel beam=$target.${freq}${ifext}.cal.ibeam map=$target.${freq}${ifext}.cal.imap mode=residual out=$target.${freq}${ifext}.cal.iresid

# fits in=$target.${freq}${ifext}.cal.iresid op=xyout out=$target.iresid.fits

# cp -r $target.${freq}${ifext}.cal $target.${freq}.selfcal

# selfcal vis=$target.${freq}.selfcal model=$target.${freq}${ifext}.cal.imodel interval=2 clip=0.001 options=phase,mfs

# invert vis=$target.${freq}.selfcal map=$target.${freq}.selfcal1.imap beam=$target.${freq}.selfcal1.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam

# cgdisp in=$target.${freq}.selfcal1.imap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge
# cgdisp in=$target.${freq}.selfcal1.imap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge "region=perc(30)"



# cp -r $target.${freq}.selfcal $target.${freq}.selfcal1

# selfcal vis=$target.${freq}.selfcal model=$target.${freq}.selfcal1.imodel interval=1 clip=0.001 options=phase,mfs

# invert vis=$target.${freq}.selfcal map=$target.${freq}.selfcal2.imap beam=$target.${freq}.selfcal2.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam

# #cgdisp in=$target.${freq}.selfcal2.imap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge

# #cgdisp in=$target.${freq}.selfcal2.v.imap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge "region=perc(30)"

# mfclean map=$target.${freq}.selfcal2.imap beam=$target.${freq}.selfcal2.ibeam out=$target.${freq}.selfcal2.imodel cutoff=5.5e-5 niters=20000 region=@${target}_map.region

# restor model=$target.${freq}.selfcal2.imodel beam=$target.${freq}.selfcal2.ibeam map=$target.${freq}.selfcal2.imap out=$target.${freq}.selfcal2.irestor

# fits in=$target.${freq}.selfcal2.irestor op=xyout out=$target.selfcal2.fits

# cp -r $target.${freq}.selfcal $target.${freq}.selfcal2

# selfcal vis=$target.${freq}.selfcal model=$target.${freq}.selfcal2.imodel interval=1 clip=0.001 options=phase,mfs

# invert vis=$target.${freq}.selfcal map=$target.${freq}.selfcal3.imap beam=$target.${freq}.selfcal3.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam

# #cgdisp in=$target.${freq}.selfcal3.imap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge "region=perc(30)"

# mfclean map=$target.${freq}.selfcal3.imap beam=$target.${freq}.selfcal3.ibeam out=$target.${freq}.selfcal3.imodel cutoff=5.5e-5 niters=100000 region=@${target}_map.region

# restor model=$target.${freq}.selfcal3.imodel beam=$target.${freq}.selfcal3.ibeam map=$target.${freq}.selfcal3.imap out=$target.${freq}.selfcal3.irestor

# fits in=$target.${freq}.selfcal3.irestor op=xyout out=$target.selfcal3.fits

# cp -r $target.${freq}.selfcal $target.${freq}.selfcal3

# selfcal vis=$target.${freq}.selfcal model=$target.${freq}.selfcal3.imodel interval=1 clip=0.02 options=phase,mfs

# invert vis=$target.${freq}.selfcal map=$target.${freq}.selfcal4.imap beam=$target.${freq}.selfcal4.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam


# mfclean map=$target.${freq}.selfcal4.imap beam=$target.${freq}.selfcal4.ibeam out=$target.${freq}.selfcal4.imodel cutoff=5.0e-5 niters=500000 region=@${target}_map.region

# restor model=$target.${freq}.selfcal4.imodel beam=$target.${freq}.selfcal4.ibeam map=$target.${freq}.selfcal4.imap out=$target.${freq}.selfcal4.irestor

# fits in=$target.${freq}.selfcal4.irestor op=xyout out=$target.selfcal4.fits

# cp -r $target.${freq}.selfcal $target.${freq}.selfcal4

# #this is the end of selfcal. amp selfcal only makes worse
# uvaver vis=$target.${freq}.selfcal4 out=$target.${freq}.selfcal4.cal


# uvmodel vis=$target.${freq}.selfcal4.cal model=$target.${freq}.selfcal4.imodel options=subtract,mfs out=$target.${freq}.uvsub

# invert vis=$target.${freq}.uvsub map=$target.${freq}.uvsub.imap beam=$target.${freq}.uvsub.ibeam robust=${robust} stokes=i options=mfs,sdb  imsize=${pb_imsize},${pb_imsize},beam

# fits in=$target.${freq}.uvsub.imap op=xyout out=$target.uvsub.dirty.fits


# # selfcal vis=$target.${freq}.selfcal model=$target.${freq}.selfcal4.imodel interval=4 clip=0.02 options=amplitude,mfs

# # invert vis=$target.${freq}.selfcal map=$target.${freq}.selfcal5.imap beam=$target.${freq}.selfcal5.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam


# # mfclean map=$target.${freq}.selfcal5.imap beam=$target.${freq}.selfcal5.ibeam out=$target.${freq}.selfcal5.imodel cutoff=5.0e-5 niters=500000 region=@${target}_map.region

# # restor model=$target.${freq}.selfcal5.imodel beam=$target.${freq}.selfcal5.ibeam map=$target.${freq}.selfcal5.imap out=$target.${freq}.selfcal5.irestor

# # fits in=$target.${freq}.selfcal5.irestor op=xyout out=$target.selfcal5.fits

# # cp -r $target.${freq}.selfcal $target.${freq}.selfcal5


# # selfcal vis=$target.${freq}.selfcal model=$target.${freq}.selfcal5.imodel interval=1 clip=0.02 options=amplitude,mfs

# # invert vis=$target.${freq}.selfcal map=$target.${freq}.selfcal6.imap beam=$target.${freq}.selfcal6.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam


# # mfclean map=$target.${freq}.selfcal6.imap beam=$target.${freq}.selfcal6.ibeam out=$target.${freq}.selfcal6.imodel cutoff=5.0e-5 niters=500000 region=@${target}_map.region

# # restor model=$target.${freq}.selfcal6.imodel beam=$target.${freq}.selfcal6.ibeam map=$target.${freq}.selfcal6.imap out=$target.${freq}.selfcal6.irestor

# # fits in=$target.${freq}.selfcal6.irestor op=xyout out=$target.selfcal6.fits

# # cp -r $target.${freq}.selfcal $target.${freq}.selfcal6


# # fits in=$target.${freq}${ifext}.cal.iresid op=xyout out=$target.resid.fits

# # fits in=$target.${freq}${ifext}.cal.irestor2 op=xyout out=$target.fits

# #mfclean map=$target.${freq}${ifext}.cal.imap beam=$target.${freq}${ifext}.cal.ibeam niters=500 out=$target.${freq}${ifext}.cal.imodel
# #"region=relcenter,boxes(-1004,-1004,1004,1004)"
