#!/bin/bash

###set some useful variable names###

#parameter to indicate you want to start from scratch
export start_fresh=1

#project code
export pcode=C1726

#primary calibrator source name - should be 1934-638 in most cases
export pcal=1934-638

#secondary calibrator source name
#change this to whatever your phase cal is
export scal=mycal

#target name
#change this
export target=mysrc

#frequency: usually 2100 (16cm receiver, L/S-band), 5500 or 9000 (4cm receiver, C/X band), etc
export freq=2100

#phase reference antenna. Usually 3 works okay
export refant=3

#no. frequency bins for gpcal. Default = 4
export gpcal_nfbins=8

#File IF extension. When observing in L-band, both IFs are centred at 2100 MHz, so ".1" or ".2" etc. are added to the file extension
#Only required if freq = 2100 or if using zoom bands
#Otherwise, leave blank i.e. ifext=""
export ifext=".1"

#CLEAN iterations
export clean_niters=100000

#CLEAN threshold, in Jy
export clean_thresh=6e-5 

#imaging robustness parameter for briggs weighting
export robust=1.0

#image size in primary beam widths for inversion and imaging. Note - source deconvolution should only happen in inner 50% of image
export pb_imsize=5


