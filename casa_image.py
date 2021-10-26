import os


mirfiles = ['j1107-5907.2100.uvsub.6']#, '0130-171.2100.1']
msnames = ['j1107-5907.ms']#, '0130-171.ms']

for mirfile, msname in zip(mirfiles, msnames):
#    mirfile = 'j1107-5907.2100.cal.2'
#    msname = 'j1107-5907.ms'
   print(mirfile, msname)
   if os.path.exists(msname):
      os.system('rm -rf {}'.format(msname))

   importmiriad(mirfile=mirfile, vis = msname)

msname = msnames[0]


# os.system('rm -r j1107-5907_im*.*')

# plotms(vis = msname, field = '0', spw = '0', xaxis = 'chan', yaxis = 'amp', avgbaseline = True, coloraxis = 'corr')

# raw_input("press enter to continue: ")

#msname = msnames[0]


#flagdata(vis = msname, field = '0', mode = 'tfcrop')
#flagdata(vis = msname, field = '0', uvrange = '0~1klambda')


#tclean(vis = msname, field = '0', cell = '1.1arcsec', imsize = 4096, savemodel = 'modelcolumn', threshold = 8E-5, niter = 100000, imagename = 'j1107-5907_im_I', interactive = True, nterms = 2, deconvolver = 'mtmfs', pblimit=-1, reffreq = '2099.999MHz', mask = 'j1107-5907field.mask', weighting = 'briggs', robust = 2.0, stokes='I')

# tclean(vis = msname, field = '0', cell = '1.3arcsec', imsize = 2048, threshold = 8E-4, niter = 0, imagename = 'j1107-5907_im_Q', interactive = False, nterms = 2, deconvolver = 'mtmfs', pblimit=0.0, reffreq = '2099.999MHz', weighting = 'briggs', robust = 2.0, stokes='Q')

# tclean(vis = msname, field = '0', cell = '1.3arcsec', imsize = 2048, threshold = 8E-4, niter = 0, imagename = 'j1107-5907_im_U', interactive = False, nterms = 2, deconvolver = 'mtmfs', pblimit=0.0, reffreq = '2099.999MHz', weighting = 'briggs', robust = 2.0, stokes='U')

# tclean(vis = msname, field = '0', cell = '1.3arcsec', imsize = 2048, threshold = 8E-4, niter = 0, imagename = 'j1107-5907_im_V', interactive = False, nterms = 2, deconvolver = 'mtmfs', pblimit=0.0, reffreq = '2099.999MHz', weighting = 'briggs', robust = 2.0, stokes='V')



# exportfits(imagename = 'j1107-5907_im_I.image.tt0', fitsimage = 'j1107-5907_im_I.tt0.fits')



#uvsub_msname = msname.replace('.ms', '_uvsub.ms')

#os.system('rm -rf {}'.format(uvsub_msname))
#os.system('cp -r {} {}'.format(msname, uvsub_msname))

#uvsub(vis = uvsub_msname)



#tclean(vis = uvsub_msname, field = '0', cell = '1.3arcsec', imsize = 2048, threshold = 5E-4, niter = 0, imagename = 'j1107-5907_im_I_uvsub', interactive = True, nterms = 2, deconvolver = 'mtmfs', pblimit=0.0, reffreq = '2099.999MHz', mask = 'j1107-5907field.mask')
#exportfits(imagename = 'j1107-5907_im_I_uvsub.image.tt0', fitsimage = 'j1107-5907_im_I_uvsub.tt0.fits') 

#tclean(vis = uvsub_msname, field = '0', cell = '1.3arcsec', imsize = 2048, threshold = 5E-4, niter = 0, imagename = 'j1107-5907_im_V_uvsub', interactive = True, nterms = 2, deconvolver = 'mtmfs', pblimit=0.0, reffreq = '2099.999MHz', mask = 'j1107-5907field.mask', stokes = 'V')
#exportfits(imagename = 'j1107-5907_im_V_uvsub.image.tt0', fitsimage = 'j1107-5907_im_V_uvsub.tt0.fits')

