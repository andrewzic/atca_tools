#!/bin/bash

#set some useful variable names
export pcode=C3XYZ #project code
export pcal=1934-638 #primary calibrator source name. Should be either 1934-638 or 0823-500
export scal=ABC #secondary calibrator source name
export target=XYZ #target name
export freq=5500 #frequency band (e.g. 2100, 5500, 9000)
export refant=1 #reference antenna for phase calibration
export ifext="" #IF extension for L-band or zoom bands (e.g. cuvir.2100.1, cuvir.2100.2)

export robust=1.0 #briggs weighting robustness parameter. 2.0 = Natural, -2.0 = uniform weighting
export pb_imsize=5 #image size in primary beam widths for inversion and imaging. Note deconvolution should only happen in inner 50% of image

invert vis=$target.${freq}.cal map=$target.${freq}.cal.imap beam=$target.${freq}.cal.ibeam  robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam

cgdisp in=$target.${freq}.cal.imap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge

cgdisp in=$target.${freq}.cal.imap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge "region=perc(30)"

invert vis=$target.${freq}.cal map=$target.${freq}.cal.vmap beam=$target.${freq}.cal.vbeam  robust=${robust} stokes=v options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam

cgdisp in=$target.${freq}.cal.vmap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge "region=perc(30)"

fits in=$target.${freq}.cal.imap op=xyout out=$target.${freq}.idirty.fits
fits in=$target.${freq}.cal.vmap op=xyout out=$target.${freq}.vdirty.fits
#fits in=$target.${freq}.cal.ibeam op=xyout out=$target.${freq}.dirtybeam.fits

cgdisp in=$target.${freq}.cal.imap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge "region=perc(30)"
imlist in=$target.${freq}.cal.imap options=statistics

cgcurs in=$target.${freq}.cal.imap type=p range=0,0,log device=/xs labtyp=hms,dms options=region "region=perc(30)"

mv cgcurs.region ${target}_inner.region

cgcurs in=$target.${freq}.cal.imap type=p range=0,0,log device=/xs labtyp=hms,dms options=region 

cat ${target}_inner.region > ${target}_map.region
cat cgcurs.region >> ${target}_map.region
#cp cgcurs.region $target.region

mfclean map=$target.${freq}.cal.imap beam=$target.${freq}.cal.ibeam out=$target.${freq}.cal.imodel cutoff=6e-5 niters=10000 region=@${target}_map.region

restor model=$target.${freq}.cal.imodel beam=$target.${freq}.cal.ibeam map=$target.${freq}.cal.imap out=$target.${freq}.cal.irestor

fits in=$target.${freq}.cal.irestor op=xyout out=$target.i.fits

restor model=$target.${freq}.cal.imodel beam=$target.${freq}.cal.ibeam map=$target.${freq}.cal.imap mode=residual out=$target.${freq}.cal.iresid

fits in=$target.${freq}.cal.iresid op=xyout out=$target.iresid.fits

cp -r $target.${freq}.cal $target.${freq}.selfcal.6

selfcal vis=$target.${freq}.selfcal.6 model=$target.${freq}.cal.imodel interval=2 clip=0.001 options=phase,mfs

invert vis=$target.${freq}.selfcal.6 map=$target.${freq}.selfcal1.imap beam=$target.${freq}.selfcal1.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam

cgdisp in=$target.${freq}.selfcal1.imap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge
cgdisp in=$target.${freq}.selfcal1.imap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge "region=perc(30)"

mfclean map=$target.${freq}.selfcal1.imap beam=$target.${freq}.selfcal1.ibeam out=$target.${freq}.selfcal1.imodel cutoff=6e-5 niters=100000 region=@${target}_map.region

restor model=$target.${freq}.selfcal1.imodel beam=$target.${freq}.selfcal1.ibeam map=$target.${freq}.selfcal1.imap out=$target.${freq}.selfcal1.irestor

fits in=$target.${freq}.selfcal1.irestor op=xyout out=$target.selfcal1.fits

cp -r $target.${freq}.selfcal.6 $target.${freq}.selfcal1.6

selfcal vis=$target.${freq}.selfcal.6 model=$target.${freq}.selfcal1.imodel interval=1 clip=0.001 options=phase,mfs

invert vis=$target.${freq}.selfcal.6 map=$target.${freq}.selfcal2.imap beam=$target.${freq}.selfcal2.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam

#cgdisp in=$target.${freq}.selfcal2.imap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge

#cgdisp in=$target.${freq}.selfcal2.v.imap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge "region=perc(30)"

mfclean map=$target.${freq}.selfcal2.imap beam=$target.${freq}.selfcal2.ibeam out=$target.${freq}.selfcal2.imodel cutoff=5.5e-5 niters=20000 region=@${target}_map.region

restor model=$target.${freq}.selfcal2.imodel beam=$target.${freq}.selfcal2.ibeam map=$target.${freq}.selfcal2.imap out=$target.${freq}.selfcal2.irestor

fits in=$target.${freq}.selfcal2.irestor op=xyout out=$target.selfcal2.fits

cp -r $target.${freq}.selfcal.6 $target.${freq}.selfcal2.6

selfcal vis=$target.${freq}.selfcal.6 model=$target.${freq}.selfcal2.imodel interval=1 clip=0.001 options=phase,mfs

invert vis=$target.${freq}.selfcal.6 map=$target.${freq}.selfcal3.imap beam=$target.${freq}.selfcal3.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam

#cgdisp in=$target.${freq}.selfcal3.imap/ type=p device=/xs labtyp=hms,dms range=0,0,log options=wedge "region=perc(30)"

mfclean map=$target.${freq}.selfcal3.imap beam=$target.${freq}.selfcal3.ibeam out=$target.${freq}.selfcal3.imodel cutoff=5.5e-5 niters=100000 region=@${target}_map.region

restor model=$target.${freq}.selfcal3.imodel beam=$target.${freq}.selfcal3.ibeam map=$target.${freq}.selfcal3.imap out=$target.${freq}.selfcal3.irestor

fits in=$target.${freq}.selfcal3.irestor op=xyout out=$target.selfcal3.fits

cp -r $target.${freq}.selfcal.6 $target.${freq}.selfcal3.6

selfcal vis=$target.${freq}.selfcal.6 model=$target.${freq}.selfcal3.imodel interval=1 clip=0.02 options=phase,mfs

invert vis=$target.${freq}.selfcal.6 map=$target.${freq}.selfcal4.imap beam=$target.${freq}.selfcal4.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam


mfclean map=$target.${freq}.selfcal4.imap beam=$target.${freq}.selfcal4.ibeam out=$target.${freq}.selfcal4.imodel cutoff=5.0e-5 niters=500000 region=@${target}_map.region

restor model=$target.${freq}.selfcal4.imodel beam=$target.${freq}.selfcal4.ibeam map=$target.${freq}.selfcal4.imap out=$target.${freq}.selfcal4.irestor

fits in=$target.${freq}.selfcal4.irestor op=xyout out=$target.selfcal4.fits

cp -r $target.${freq}.selfcal.6 $target.${freq}.selfcal4.6

#this is the end of selfcal. amp selfcal only makes worse
uvaver vis=$target.${freq}.selfcal4.6 out=$target.${freq}.selfcal4.cal.6


uvmodel vis=$target.${freq}.selfcal4.cal.6 model=$target.${freq}.selfcal4.imodel options=subtract,mfs out=$target.${freq}.uvsub.6

invert vis=$target.${freq}.uvsub.6 map=$target.${freq}.uvsub.imap beam=$target.${freq}.uvsub.ibeam robust=${robust} stokes=i options=mfs,sdb  imsize=${pb_imsize},${pb_imsize},beam

fits in=$target.${freq}.uvsub.imap op=xyout out=$target.uvsub.dirty.fits


# selfcal vis=$target.${freq}.selfcal.6 model=$target.${freq}.selfcal4.imodel interval=4 clip=0.02 options=amplitude,mfs

# invert vis=$target.${freq}.selfcal.6 map=$target.${freq}.selfcal5.imap beam=$target.${freq}.selfcal5.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam


# mfclean map=$target.${freq}.selfcal5.imap beam=$target.${freq}.selfcal5.ibeam out=$target.${freq}.selfcal5.imodel cutoff=5.0e-5 niters=500000 region=@${target}_map.region

# restor model=$target.${freq}.selfcal5.imodel beam=$target.${freq}.selfcal5.ibeam map=$target.${freq}.selfcal5.imap out=$target.${freq}.selfcal5.irestor

# fits in=$target.${freq}.selfcal5.irestor op=xyout out=$target.selfcal5.fits

# cp -r $target.${freq}.selfcal.6 $target.${freq}.selfcal5.6


# selfcal vis=$target.${freq}.selfcal.6 model=$target.${freq}.selfcal5.imodel interval=1 clip=0.02 options=amplitude,mfs

# invert vis=$target.${freq}.selfcal.6 map=$target.${freq}.selfcal6.imap beam=$target.${freq}.selfcal6.ibeam robust=${robust} stokes=i options=mfs,sdb imsize=${pb_imsize},${pb_imsize},beam


# mfclean map=$target.${freq}.selfcal6.imap beam=$target.${freq}.selfcal6.ibeam out=$target.${freq}.selfcal6.imodel cutoff=5.0e-5 niters=500000 region=@${target}_map.region

# restor model=$target.${freq}.selfcal6.imodel beam=$target.${freq}.selfcal6.ibeam map=$target.${freq}.selfcal6.imap out=$target.${freq}.selfcal6.irestor

# fits in=$target.${freq}.selfcal6.irestor op=xyout out=$target.selfcal6.fits

# cp -r $target.${freq}.selfcal.6 $target.${freq}.selfcal6.6


# fits in=$target.${freq}.cal.iresid op=xyout out=$target.resid.fits

# fits in=$target.${freq}.cal.irestor2 op=xyout out=$target.fits

#mfclean map=$target.${freq}.cal.imap beam=$target.${freq}.cal.ibeam niters=500 out=$target.${freq}.cal.imodel
#"region=relcenter,boxes(-1004,-1004,1004,1004)"
