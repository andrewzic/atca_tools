import os


mirfiles = ['my_src.2100.1.cal']
msnames = ['my_src.ms']

for mirfile, msname in zip(mirfiles, msnames):
#    mirfile = 'my_src.2100.cal.2'
#    msname = 'my_src.ms'
   print(mirfile, msname)
   if os.path.exists(msname):
      os.system('rm -rf {}'.format(msname))

   importmiriad(mirfile=mirfile, vis = msname)

msname = msnames[0]

#flagdata(vis = msname, field = '0', mode = 'tfcrop')
#flagdata(vis = msname, field = '0', uvrange = '0~1klambda')


#tclean(vis = msname, field = '0', cell = '1.1arcsec', imsize = 4096, savemodel = 'modelcolumn', threshold = 8E-5, niter = 100000, imagename = 'my_src_im_I', interactive = True, nterms = 2, deconvolver = 'mtmfs', pblimit=-1, reffreq = '2099.999MHz', mask = 'my_srcfield.mask', weighting = 'briggs', robust = 2.0, stokes='I')
