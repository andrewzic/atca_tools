#!/usr/bin/env python

import numpy as np
from casacore.tables import *
import sys
#import matplotlib.pyplot as plt

XX=0
XY=1
YX=2
YY=3

src_name = "my_src"
pols = ["XX", "XY", "YX", "YY"]
for freq in ["2100"]:
    for pol in [XX, XY, YX, YY]:
        #ms = "%s.%s.ms" %(src_name, freq)
        msname='my_src.ms'
        outfile = "%s.%s_dynamic_spectra_%s.npy" %(src_name, freq, pols[pol])
    
        t = table(msname)
        tf =("%s/SPECTRAL_WINDOW" %(msname))
        ta = table("%s/ANTENNA" %(msname))


        nant = len(ta)
        
        print(nant)
        
        waterfall = []
        for ant1 in range(nant-1):
            for ant2 in range(ant1+1,nant):
                print(ant1,ant2)
                #if ant1 == 0 and ant2 == 2:
                #    continue
                #if ant1 == 2 and ant2 == 3:
                #    continue
                #if ant1 == 3 and ant2 == 4:
                #    continue
                t1 = taql("select * from $t where ANTENNA1 == $ant1 and ANTENNA2 == $ant2")
                # print(t1.getcol("DATA"))
                # print(t1.getcol("FLAG"))
                #if ant1 == 0 and ant2 == 1:
                #    pass
                #if ant1 == 3 and ant2 == 4:
                #    pass
                try:
                    vis_flag = t1.getcol("FLAG")[:,:2048,pol]
                    vis_data = t1.getcol("DATA")[:,:2048,pol]
                    print("Processing baseline %d-%d" %(ant1, ant2), vis_data.shape)
                    waterfall.append(np.ma.masked_where(vis_flag==True, vis_data))
                    #if ant1 == 1 and ant2 == 5:
                    #    d_ = np.ma.masked_where(vis_flag == True, vis_data)
                    #    d_outfile = "%s.%s_dynamic_spectra_%s_%s%s.npy" %(src_name, freq, pols[pol], ant1, ant2)
                    #    d_.dump(d_outfile)
                except IndexError:
                    continue
                #t1.close()

        waterfall = np.ma.mean(waterfall, axis=0)
        waterfall.dump(outfile)
        t.close()
        #tf.close()
        #ta.close()
