#!/usr/bin/env python

import numpy as np
from casacore.tables import *
#import astropy.io.fits as pf
#from astropy.time import Time

ms = "j1107-5907_selfcal_uvsub.ms"

t = table(ms)
tf = table("%s/SPECTRAL_WINDOW" %(ms))
ta = table("%s/ANTENNA" %(ms))
vis_time = t.getcol('TIME')
vis_feed = t.getcol('FEED1')
vis_scan = t.getcol('SCAN_NUMBER')
times = []
prev_time = -1.0
for t_index in range(len(vis_time)):
    if vis_time[t_index] != prev_time:
        times.append(vis_time[t_index])
        prev_time = times[-1]
    
np.array(times).dump("time.npy")
#np.save(np.array(vis_time)/60.0/60.0/24.0, "uvceti_time")
tf[0]["CHAN_FREQ"].dump("freq.npy")
    
