#!/bin/bash

#set some useful variable names
export pcode=C1726 #project code
export pcal=1934-638 #primary calibrator source name
#change this
export scal=mycal #secondary calibrator source name
#change this
export target=mysrc #target name
export freq=5500 #frequency band (e.g. 2100, 5500, 9000)
export refant=3 #reference antenna for phase calibration (sets the phase zero point)
export ifext="" #IF extension for L-band or zoom bands (e.g. 1934-638.2100.1, 1934-638.2100.2. Should be blank except if freq=2100


#select a primary calibrator filename prefix from the list below, according to nearest time and appropriate frequency:
#2022-01-17_2210.C1726 : 16700 MHz, 21200 MHz, 5500 MHz, 9000 MHz. Note: 1934-638_f is the focus scan and should be discarded.
#2022-01-17_2250.C1726 : 2100 MHz

export pcal_fname_pre=2022-01-17_2210.C1726 #primary calibration filename prefix


#delete all files before a new run - uncomment this if you want to start fresh
# rm -fr ${pcode}*.uv *.2100* *.5500 *.9000 

#load in all the files for this project code

#note - make sure you discard all files used for array setup before you load data in (e.g. `rm 2021-01-11*.C1726`)

atlod in=*.$pcode out=$pcode".uv" options=birdie,noauto,xycorr,rfiflag #CX = C/X band
#split into 1934-638.<blah blah>
uvsplit vis=$pcode".uv"

echo "loaded and split primary cal data"

#load in target data
#the "ls -p 2021-01 etc" subcommand lists all the files for the PSR observation and replaces newlines "\n" with commas ","

#inspect data before bandpass calibration
uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=99999 yrange=1,50 nxy=5,3 #plot baselines in  a 5x3 subplot grid, average over 99999 minutes (i.e. the whole 1934 observation)

#stop and wait to continue
read -p "Press enter to continue"

#initial bandpass calibration using 1934
mfcal vis=$pcal.${freq}${ifext} interval=3.0 refant=$refant

#inspect bandpass xx,yy pols per-baseline
uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 yrange=0.5, 5 nxy=5,3 #plot baselines in  a 5x3 subplot grid
read -p "Press enter to continue"


#inspect bandpass just for xx, yy pols with all baselines overlaid
uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 0.5, 5.5 options=nobase #all baselines overlaid
read -p "Press enter to continue"


#now do some auto-flagging
pgflag vis=$pcal.${freq}${ifext} "command=<b" device=/xs stokes=xx,yy,xy,yx options=nodisp

for stokes in "xx" "yy" "yx" "xy";
do pgflag vis=$pcal.${freq}${ifext} "command=<b" device=/xs stokes=$stokes options=nodisp
done

#inspect bandpass just for xx, yy pols:
uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 yrange=0.5, 10.5 options=nobase #all baselines overlaid
read -p "Press enter to continue"

uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 yrange=0.5, 10.5 nxy=5,3 #plot baselines in  a 5x3 subplot grid
read -p "Press enter to continue"

#some more flagging
for stokes in "xx" "yy" "yx" "xy";
do pgflag vis=$pcal.${freq}${ifext} "command=<b" device=/xs stokes=$stokes options=nodisp
done

#redo bandpass calibration after some auto flagging
mfcal vis=$pcal.${freq}${ifext} interval=1.0 refant=$refant

#inspect bandpass just for xx, yy pols:
uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 yrange=0.5, 10.5 options=nobase #all baselines overlaid
read -p "Press enter to continue"

#some more flagging
pgflag vis=$pcal.${freq}${ifext} "command=<b" device=/xs stokes=xx,yy,xy,yx options=nodisp

for stokes in "xx" "yy" "yx" "xy";
do pgflag vis=$pcal.${freq}${ifext} "command=<b" device=/xs stokes=$stokes options=nodisp
done

#redo bandpass calibration after some auto flagging
mfcal vis=$pcal.${freq}${ifext} interval=1.0 refant=$refant

#inspect bandpass just for xx, yy pols:
uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 yrange=0.5, 10.5 options=nobase #all baselines overlaid
read -p "Press enter to continue"


#some more flagging
pgflag vis=$pcal.${freq}${ifext} "command=<b" device=/xs stokes=xx,yy,xy,yx options=nodisp
for stokes in "xx" "yy" "yx" "xy";
do pgflag vis=$pcal.${freq}${ifext} "command=<b" device=/xs stokes=$stokes options=nodisp
done


#redo bandpass calibration after some auto flagging
mfcal vis=$pcal.${freq}${ifext} interval=1.0 refant=$refant

# #inspect bandpass just for xx, yy pols:
# uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 yrange=0.5, 10.5 options=nobase #all baselines overlaid
# read -p "Press enter to continue"

# #some more flagging
# pgflag vis=$pcal.${freq}${ifext} "command=<b" device=/xs stokes=xx,yy,xy,yx
# for stokes in "xx" "yy" "yx" "xy";
# do pgflag vis=$pcal.${freq}${ifext} "command=<b" device=/xs stokes=$stokes options=nodisp
# done


# #redo bandpass calibration after some auto flagging
# mfcal vis=$pcal.${freq}${ifext} interval=2.0 refant=$refant

# #inspect bandpass just for xx, yy pols:
# uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 yrange=0.5, 10.5 options=nobase #all baselines overlaid
# read -p "Press enter to continue"

# #inspect specific channel range
# uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 yrange=0.5, 10.5 options=nobase line=channel,80,420,1,1 #80 chans starting from chan 420
# read -p "Press enter to continue"

# #inspect specific channel range
# uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999  options=nobase line=channel,50,610,1,1 #50 chans starting from chan 610
# read -p "Press enter to continue"

# #flag known bad channel ranges for all data
# for i in *.${freq}${ifext};
# 	 #flag 60 chans starting at chan 435
# do  uvflag vis=$i line=channel,62,433,1,1 flagval=flag;
# uvflag vis=$i line=channel,39,620,1,1 flagval=flag;
# done

# #inspect bandpass per baseline
# uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 nxy=5,3 yrange=0.5, 10.5
# read -p "Press enter to continue"

#read -p "Press enter to continue"
#for i in *.${freq}${ifext};
#do uvflag vis=$i line=channel,3,1054,1,1 "select=antenna(1)(2)" flagval=flag; #flag 3 chans around the bad one
#done

#will run pgflag on the other bad baselines to remove some more crud
#pgflag vis=$pcal.${freq}${ifext} "command=<b" device=/xs stokes=xx,yy,xy,yx "select=antenna(1)(4)"
#pgflag vis=$pcal.${freq}${ifext} "command=<b" device=/xs stokes=xx,yy,xy,yx "select=antenna(2)(4)"
#pgflag vis=$pcal.${freq}${ifext} "command=<b" device=/xs stokes=xx,yy,xy,yx "select=antenna(3)(4)"
#pgflag vis=$pcal.${freq}${ifext} "command=<b" device=/xs stokes=xx,yy,xy,yx "select=antenna(4)(5)"

# #now redo mfcal again
# mfcal vis=$pcal.${freq}${ifext} interval=2.0 refant=$refant

# #and inspect bandpass
# uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 0.5, 5.5 options=nobase #all baselines overlaid
# read -p "Press enter to continue"

# #inspect per baseline
# uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 yrange=0.5, 10.5 nxy=5,3 #plot baselines in  a 5x3 subplot grid
# read -p "Press enter to continue"



# for i in `echo *.5500 *.9000`;
# do uvflag vis=$i  flagval=flag "select=antenna(6)";
# done
#for i in *.5500;
#	 do uvflag vis=$i flagval=flag line=channel,30,1808,1,1
#done;

#finally after some extensive flagging, run some manual flagging of primary cal data

#blflag vis=$pcal.5500 device=/xs stokes=xx,yy axis=chan,amp options=nofqav,nobase
#read -p "Press enter to continue"
#check out amp vs uv-distance (i.e. baseline length in units of wavelengths)
#blflag vis=$pcal.5500 device=/xs stokes=xx,yy axis=uvdistance,amp options=nofqav,nobase

#assuming all OK, proceed to gain calibration and copy to secondary cal
#otherwise, flag more and re-calibrate.
#redo bandpass
#mfcal vis=$pcal.5500 interval=2.0 refant=$refant


#and inspect bandpass
uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 0.5, 5.5 options=nobase #all baselines overlaid
read -p "Press enter to continue"

#inspect per baseline
uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 yrange=0.5, 10.5 nxy=5,3 #plot baselines in  a 5x3 subplot grid
read -p "Press enter to continue"


#flag out low end of band manually for these baselines
#for antpair in "(2)(4)" "(3)(4)" "(4)(5)" "(4)(6)";#
#	       for i in *.${freq}${ifext};#
#	       do uvflag vis=$i line=channel,300,1,1,1 select=antenna$antpair flgval=flag;
#	       done
#	    done
#do blflag vis=$pcal.${freq}${ifext} device=/xs stokes=xx,yy axis=chan,amp options=nofqav,nobase select=antenna$antpair


#mfcal vis=$pcal.${freq}${ifext} interval=2.0 refant=$refant


#and inspect bandpass
uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 0.5, 5.5 options=nobase #all baselines overlaid
read -p "Press enter to continue"

#inspect per baseline
uvspec vis=$pcal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 yrange=0.5, 10.5 nxy=5,3 #plot baselines in  a 5x3 subplot grid
read -p "Press enter to continue"

#now gain calibrate primary cal data
gpcal vis=$pcal.${freq}${ifext} interval=1 options=xyvary minants=3 nfbin=8 spec=2.1 refant=$refant

#check out primary cal data in real vs imag. This should look like a fat line that extends horizontally on the real axis, and is centered around 0 on the imaginary axis
uvplt vis=$pcal.${freq}${ifext} axis=real,imag stokes=xx,yy options=nofqav,nobase,equal device=/xs

uvplt vis=$pcal.${freq}${ifext} axis=real,imag stokes=xx,yy options=nofqav nxy=5,3  device=/xs

#if all looks okay, then:
#copy solutions to secondary
gpcopy vis=$pcal.${freq}${ifext} out=$scal.${freq}${ifext}


#now inspect secondary cal data
#amp vs chan
uvspec vis=$scal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 nxy=5,3
read -p "Press enter to continue"

#do some auto-flagging and manual flagging on secondary cal
pgflag vis=$scal.${freq}${ifext} "command=<b" device=/xs stokes=xx,yy,xy,yx options=nocal
for stokes in "xx" "yy" "yx" "xy";
do pgflag vis=$scal.${freq}${ifext} "command=<b" device=/xs stokes=$stokes options=nodisp,nocal
done

# pgflag vis=$scal.${freq}${ifext} "command=<b" device=/xs stokes=xx,yy,xy,yx options=nocal
# for stokes in "xx" "yy" "yx" "xy";
# do pgflag vis=$scal.${freq}${ifext} "command=<b" device=/xs stokes=$stokes options=nodisp,nocal
# done

#check data across bandpass
#blflag vis=$scal.${freq}${ifext} device=/xs stokes=xx,yy axis=chan,amp options=nofqav,nobase
#blflag vis=$scal.${freq}${ifext} device=/xs stokes=xx,yy axis=time,amp options=nofqav,nobase
#read -p "Press enter to continue"
#check data using amp vs uv-distance (i.e. baseline length in units of wavelengths)
#blflag vis=$scal.${freq}${ifext} device=/xs stokes=xx,yy axis=uvdistance,amp options=nofqav,nobase

#phase vs chan
uvspec vis=$scal.${freq}${ifext} axis=chan,phase stokes=xx,yy device=/xs interval=9999 options=nobase,nocal
read -p "Press enter to continue"
#amp vs time
uvplt vis=$scal.${freq}${ifext} axis=time,amp stokes=xx,yy device=/xs interval=1 options=nobase,nocal
read -p "Press enter to continue"
#phase vs time
uvplt vis=$scal.${freq}${ifext} axis=phase,amp stokes=xx,yy device=/xs interval=9999 options=nobase,nocal
read -p "Press enter to continue"

gpcal vis=$scal.${freq}${ifext} interval=2 options="xyvary,qusolve,reset" minants=3 nfbin=4 refant=$refant

#now inspect secondary cal data again
#amp vs chan
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

gpcal vis=$scal.${freq}${ifext} interval=0.5 options="xyvary,qusolve,reset" minants=3 nfbin=4 refant=$refant

#amp vs chan
uvspec vis=$scal.${freq}${ifext} axis=chan,amp stokes=xx,yy device=/xs interval=9999 nxy=5,3
read -p "Press enter to continue"
#amp vs time
uvplt vis=$scal.${freq}${ifext} axis=time,amp stokes=xx,yy device=/xs interval=9999 nxy=5,3
read -p "Press enter to continue"
#phase vs time
uvplt vis=$scal.${freq}${ifext} axis=time,phase stokes=xx,yy device=/xs interval=9999 nxy=5,3
read -p "Press enter to continue"

#assuming all OK, apply flux scale from primary cal onto secondary:
gpboot vis=$scal.${freq}${ifext} cal=$pcal.${freq}${ifext};

#now copy calibration solutions to target data
gpcopy vis=$scal.${freq}${ifext} out=$target.${freq}${ifext};

#now average gain solutions over the 2-minute interval when on the secondary-cal
gpaver vis=$target.${freq}${ifext} interval=2

#now flag the target data using pgflag and blflag
pgflag vis=$target.${freq}${ifext} "command=<b" device=/xs stokes=xx,yy,xy,yx
for stokes in "xx" "yy" "yx" "xy";
do pgflag vis=$target.${freq}${ifext} "command=<b" device=/xs stokes=$stokes options=nodisp
done

pgflag vis=$target.${freq}${ifext} "command=<b" device=/xs stokes=xx,yy,xy,yx
for stokes in "xx" "yy" "yx" "xy";
do pgflag vis=$target.${freq}${ifext} "command=<b" device=/xs stokes=$stokes options=nodisp
done
#check data across bandpass
#blflag vis=$target.${freq}${ifext} device=/xs stokes=xx,yy axis=chan,amp options=nofqav,nobase
#read -p "Press enter to continue"

#check data using amp vs uv-distance (i.e. baseline length in units of wavelengths)
#blflag vis=$target.${freq}${ifext} device=/xs stokes=xx,yy axis=uvdistance,amp options=nofqav,nobase

#check data over time - but be careful - don't accidentally flag out anything real!
#blflag vis=$target.${freq}${ifext} device=/xs stokes=xx,yy axis=chan,amp options=nofqav,nobase

#now apply calibrations to target using uvaver
uvaver vis=$target.${freq}${ifext} out=$target.${freq}${ifext}.cal

#and also to the secondary cal
uvaver vis=$scal.${freq}${ifext} out=$scal.${freq}${ifext}.cal

#this concludes the calibration


