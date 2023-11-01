#!/bin/bash

###set some useful variable names###
#project root directory
export PROJ_ROOT=/PATH/TO/PROJ_DIR/C999/
export PROJ_SCRIPTS=${PROJ_ROOT}/scripts/
export PROJ_DATA=${PROJ_ROOT}/data/
export PROJ_PROC=${PROJ_ROOT}/proc/
export PROJ_IMG=${PROJ_ROOT}/img/
#parameter to indicate you want to start from scratch
export start_fresh=1
export AUTO_PROC=0

#project code
export pcode=C999

#primary calibrator source name - should be 1934-638 in most cases
export pcal=1934-638

#secondary calibrator source name
#change this to whatever your phase cal is
export scal=scal_name

#target name
#change this
export target=target

#frequency: usually 2100 (16cm receiver, L/S-band), 5500 or 9000 (4cm receiver, C/X band), etc
export freq=5500

#phase reference antenna. Usually 3/4 works okay
export refant=4

#no. frequency bins for gpcal. Default = 4
export gpcal_nfbins=4

#File IF extension. When observing in L-band, both IFs are centred at 2100 MHz, so ".1" or ".2" etc. are added to the file extension
#Only required if freq = 2100 or if using zoom bands
#Otherwise, leave blank i.e. ifext=""
export ifext=""

#CLEAN iterations
export clean_niters=100000

#CLEAN threshold, in Jy
export clean_thresh=1e-4 

#imaging robustness parameter for briggs weighting
export robust=1.5

#image size in primary beam widths for inversion and imaging. Note - source deconvolution should only happen in inner 50% of image
export pb_imsize=4

export nmfcal_auto=5

export ngpcal_auto=5
