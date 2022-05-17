import numpy as np
import numpy.ma as ma
import matplotlib.pyplot as plt
from astropy.time import Time
import astropy.units as u

import sys
#sys.path.append('/import/extreme2/azic/phd/code/')

from atca_ds_tools import *

# def get_time_freq_atca(tfile, ffile, band = 'L'):
#     """load in and format the time and frequency arrays output by getcols.py
#     inputs:
#     tfile=filename of time data file
#     ffile=filename of frequency data file
#     band=which ATCA observing band - required to know whether to flip frequency array or not
#     outputs:
#     t0:start time of observation, as an astropy.time.Time object
#     t_data:time from observation start (t0) in hours
#     f_data:frequencies of observation in MHz
#     dts:time gaps between each integration and the previous one. required to know where calibrator scan breaks start
#     dts2:similar to dt2, but for time gaps between each integation and the subsequent one. required to know where calibrator scan breaks end
#     scan_start_indices: indices of t_data where an on-source scan starts
#     scan_end_indices: indices of t_data where an on-source calibrator scan ends
#     """
    
#     t_data = np.load(tfile, allow_pickle = True)
#     t_data /= 3600.0 #convert to hours

#     f_data = np.load(ffile, allow_pickle = True)
#     f_data /= 1.0e6 #convert to MHz
#     f_data = f_data[1:] #cut off first element because f_data is 2049 elements long, should check if this is right...
#     if band == 'L' or band == '16cm' or band == 16:
#         f_data = np.flip(f_data) #reverse order of freqeuncy data
    
#     t0 = Time(t_data[0]/24.0, format='mjd', scale='utc')
#     tN = Time(t_data[-1]/24.0, format='mjd', scale='utc')
#     print(t0)
#     t0.format='iso'
#     tN.format='iso'

#     print("Time range: %s - %s (%.1f s or %.1f h)" %(t0, tN, t_data[-1]-t_data[0], (t_data[-1]-t_data[0])/3600.0))

    
#     t_data -= t_data[0] #relative time
    
#     dts = [0]
#     dts.extend([t_data[i] - t_data[i-1] for i in range(1, len(t_data))])
#     dts = np.array(dts)
#     scan_start_indices = np.where(np.abs(dts) > 0.0028)[0]
#     s = [0]
#     s.extend(list(scan_start_indices))
#     scan_start_indices = np.array(s)
#     dts2 = [t_data[i] - t_data[i+1] for i in range(0, len(t_data)-1)]
#     scan_end_indices = list(np.where(np.abs(dts2) > 0.0028)[0])
#     scan_end_indices.append(len(t_data)-1)
#     scan_end_indices = np.array(scan_end_indices)
    
    
    
#     return t0, t_data, f_data, dts, dts2, scan_start_indices, scan_end_indices

# def get_ipol_data(XXfile, XYfile, YXfile, YYfile, times, dts, scan_start_indices = [0], scan_end_indices = [-1]):
#     """
#     get instrumental polarisation data for ATCA and reformat to include cal-scan breaks (how annoying...)
#     inputs:
#     XXfile (str): filename for XX instrumental pol.
#     XYfile (str): filename for XY instrumental pol.
#     YXfile (str): filename for YX instrumental pol.
#     YYfile (str): filename for YY instrumental pol.
#     times (numpy array): array of times returned by get_time_freq_atca
#     freqs (numpy array): array of frequencies returned by get_time_freq_atca
#     scan_start_indices (list or np array): time indices where target scans begin
#     scan_end_indices (list or np array): time indices where target scans end
#     dts (np array): time gap between successive integrations returned by get_time_freq_atca
#     """
#     XX = np.load('uvceti.2100_dynamic_spectra_XX.npy', allow_pickle = True)
#     XY = np.load('uvceti.2100_dynamic_spectra_XY.npy', allow_pickle = True)
#     YX = np.load('uvceti.2100_dynamic_spectra_YX.npy', allow_pickle = True)
#     YY = np.load('uvceti.2100_dynamic_spectra_YY.npy', allow_pickle = True)

#     ts_phasecal = (times[scan_start_indices[1:]] - times[scan_end_indices[:-1]])/np.median(dts[0:scan_end_indices[0]])

#     nints_phasecal = (times[scan_start_indices[1:]] - times[scan_end_indices[:-1]])/np.median(dts[:scan_end_indices[0]])
    
#     new_data_XX = np.zeros((1, XX.shape[1]))
#     new_data_XY = np.zeros((1, XY.shape[1]))
#     new_data_YX = np.zeros((1, YX.shape[1]))
#     new_data_YY = np.zeros((1, YY.shape[1]))
    
#     for start_index, end_index, nint in zip(scan_start_indices[:-1], scan_end_indices[:-1], nints_phasecal):
#         XX_chunk = XX[start_index:end_index, :]
#         XY_chunk = XY[start_index:end_index, :]
#         YX_chunk = YX[start_index:end_index, :]
#         YY_chunk = YY[start_index:end_index, :]
#         nan_chunk = np.full((int(nint), XX.shape[1]), np.nan)
#         print(XX.shape, nan_chunk.shape, XX_chunk.shape)
#         new_chunk_XX = np.vstack([XX_chunk, nan_chunk])
#         new_chunk_XY = np.vstack([XY_chunk, nan_chunk])
#         new_chunk_YX = np.vstack([YX_chunk, nan_chunk])
#         new_chunk_YY = np.vstack([YY_chunk, nan_chunk])
#         new_data_XX = np.vstack([new_data_XX, new_chunk_XX])
#         new_data_XY = np.vstack([new_data_XY, new_chunk_XY])
#         new_data_YX = np.vstack([new_data_YX, new_chunk_YX])
#         new_data_YY = np.vstack([new_data_YY, new_chunk_YY])

        
#     XX = ma.masked_invalid(new_data_XX[1:])
#     XY = ma.masked_invalid(new_data_XY[1:])
#     YX = ma.masked_invalid(new_data_YX[1:])
#     YY = ma.masked_invalid(new_data_YY[1:])

#     XX = ma.masked_where(XX == 0, XX)
#     XY = ma.masked_where(XY == 0,  XY)
#     YX = ma.masked_where(YX == 0, YX)
#     YY = ma.masked_where(YY == 0, YY)

#     return(XX, XY, YX, YY)

# def form_stokes(XX, XY, YX, YY, band = 'L'):
#     """
#     form stokes parameters from supplied instrumental polarisations
#     input:
#     XX: array of complex XX instrumental polarisation data
#     XY: array of complex XY instrumental polarisation data
#     YX: array of complex YX instrumental polarisation data
#     YY: array of complex YY instrumental polarisation data
#     band (str or int, default = 'L'): specify if in L-band by entering 'L', '16cm', or 16. This will flip the direction of the frequency axis
#     """
    
#     if band == 'L' or band == '16cm' or band == 16:
#         flip = True
#     else:
#         flip = False

#     I = (XX + YY)/2.0
#     Q = (XX - YY)/2.0
#     U = (XY  + YX)/2.0
#     V = np.complex(0, 1) * ( XY - YX)/2.0
    
#     if flip == True:
#         I = np.flip(I[:, :], axis = 1)
#         Q = np.flip(Q, axis = 1)
#         U = np.flip(U, axis = 1)
#         V = np.flip(V[:, :], axis = 1)
        
#     return I, Q, U, V

# def average_stokes_ds(arr, aT, aF):
#     nT = arr.shape[0]
#     nF = arr.shape[1]
#     arr = np.mean(arr.reshape(nT//aT, aT, nF), axis = 1)
#     arr = np.mean(arr.reshape(nT//aT, nF//aF, aF), axis = 2)

#     return arr

# def average_time_freq(arr, avg_factor):
#     nX = arr.shape[0]
#     return np.mean(arr.reshape(nX//avg_factor, avg_factor), axis = 1)

# def plot_stokes_ds(I, Q, U, V, times, freqs, clim_I = None, clim_Q = None, clim_U = None, clim_V = None):
    
#     if clim_I == None:
#         mI = np.real(np.nanmean(I))
#         sI = np.real(np.std(I))
#         clim_I = (mI - 1.0*sI, mI + 2.0*sI)
        
#     if clim_Q == None:
#         mQ = np.real(np.nanmean(Q))
#         sQ = np.real(np.std(Q))
#         clim_Q = (mQ - 2*sQ, mQ + 2*sQ)
        
#     if clim_U == None:
#         mU = np.real(np.nanmean(U))
#         sU = np.real(np.std(U))
#         clim_U = (mU - 2*sU, mU + 2*sU)
        
#     if clim_V == None:
#         mV = np.real(np.nanmean(V))
#         sV = np.real(np.std(V))
#         clim_V = (mV - 2*sV, mV + 2*sV)

#     fig, axes  = plt.subplots(4,1, figsize = (14, 14), sharex = True)
    
#     im_list = []

#     for ax, stoke_ds, clim in zip(axes, [I, Q, U, V], [clim_I, clim_Q, clim_U, clim_V]):   
#         im_ = ax.imshow(np.real(stoke_ds).T,
#                         aspect = 'auto',
#                         origin = 'lower',
#                         cmap = 'inferno',
#                         clim = clim,
#                         extent = [times[0], times[-1], freqs[0], freqs[-1]]
#                         )
#         plt.sca(ax)
#         plt.colorbar(im_).set_label('Flux Density (Jy)', fontsize = 14)
#         im_list.append(im_)
#         ax.set_ylabel('Frequency (MHz)', fontsize = 14)
            
#     axes[-1].set_xlabel('Time (h)', fontsize = 14)

#     return(fig, axes, im_list)


period = 5.4432 * u.hour
f0 = (1.0/period).to(u.Hz)
print(f0)

tfile = 'time.npy'
ffile = 'freq.npy'

XXfile = 'my_src.2100_dynamic_spectra_XX.npy'
XYfile = 'my_src.2100_dynamic_spectra_XY.npy'
YXfile = 'my_src.2100_dynamic_spectra_YX.npy'
YYfile = 'my_src.2100_dynamic_spectra_YY.npy'

t0, times, freqs, dts, dt2, scan_start_indices, scan_end_indices = get_time_freq_atca(tfile, ffile)

times = times#[:3616]


#XX, XY, YX, YY = 
XX = np.load(XXfile, allow_pickle = True)
YX = np.load(YXfile, allow_pickle = True)
XY = np.load(XYfile, allow_pickle = True)
YY = np.load(YYfile, allow_pickle = True)

print(XX.shape)
print(len(times))
#XX, XY, YX, YY = get_ipol_data(XXfile, XYfile, YXfile, YYfile, times, dts, scan_start_indices, scan_end_indices)
I, Q, U, V = form_stokes(XX, XY, YX, YY, band = 'L')

aT = 25
aF = 1

I = average_stokes_ds(I, aT, aF)
Q = average_stokes_ds(Q, aT, aF)
U = average_stokes_ds(U, aT, aF)
V = average_stokes_ds(V, aT, aF)

#I = np.ma.masked_where(np.abs(I) > 0.2, I)
#I = np.ma.masked_where(np.abs(Q) > 0.05, I)
#V = np.ma.masked_where(np.abs(Q) > 0.05, V)
#Q = np.ma.masked_where(np.abs(Q) > 0.2, Q)
#U = np.ma.masked_where(np.abs(U) > 0.2, U)
#V = np.ma.masked_where(np.abs(V) > 0.2, V)

#print(np.nanmean(I))

times = average_time_freq(times, aT)
freqs = average_time_freq(freqs, aF)
times_fake = np.linspace(times[0], times[-1], I.shape[0])

#print(times[500 + np.argmax(np.ma.mean(I, axis = 1)[500:600])])

#print((t0 + times[500 + np.argmax(np.ma.mean(I, axis = 1)[500:600])]*u.hour).mjd)

#fig = plt.figure(figsize = (12,5))
#plt.plot((t0 + times*u.hour).mjd, average_time_freq(np.ma.mean(I, axis = 1), 1), label = 'I')

#plt.plot((t0 + times*u.hour).mjd, np.arctan(np.imag(np.ma.mean(I, axis = 1), 1)/np.real(np.ma.mean(I, axis = 1))), label = 'I')
#plt.axvline((t0 + times[500 + np.argmax(np.ma.mean(I, axis = 1)[500:600])]*u.hour).mjd, c = 'k', linestyle = '--')
#plt.legend()
#plt.show()

#fig = plt.figure(figsize = (12,5))
#plt.plot((t0 + times*u.hour), np.imag(average_time_freq(np.ma.mean(I[:,:], axis = 1), 1)), label = 'I')
#plt.plot((t0 + times*u.hour), np.imag(average_time_freq(np.ma.mean(Q[:,:], axis = 1), 1)), label = 'Q')
#plt.plot((t0 + times*u.hour).mjd, np.imag(average_time_freq(np.ma.mean(U[:,:], axis = 1), 1)), label = 'U')
#plt.plot((t0 + times*u.hour).mjd, np.imag(average_time_freq(np.ma.mean(V[:,:], axis = 1), 1)), label = 'V')
#plt.axvline((t0 + times[500 + np.argmax(np.ma.mean(I, axis = 1)[500:600])]*u.hour).mjd, c = 'k', linestyle = '--')
#plt.legend()
#plt.show()


rms = np.std(np.imag(average_time_freq(np.ma.mean(I[:,:], axis = 1), 1)))
fig = plt.figure(figsize = (12,5))
plt.errorbar((times), 1000.0*average_time_freq(np.ma.mean(I[:,:], axis = 1), 1), yerr= 1000.0*rms, label = 'I')
plt.errorbar((times), 1000.0*average_time_freq(np.ma.mean(Q[:,:], axis = 1), 1), yerr= 1000.0*rms, label = 'Q')
plt.errorbar((times), 1000.0*average_time_freq(np.ma.mean(U[:,:], axis = 1), 1), yerr= 1000.0*rms, label = 'U')
plt.errorbar((times), 1000.0*average_time_freq(np.ma.mean(V[:,:], axis = 1), 1), yerr= 1000.0*rms, label = 'V')
#plt.axvline((t0 + times[500 + np.argmax(np.ma.mean(I, axis = 1)[500:600])]*u.hour).mjd, c = 'k', linestyle = '--')
plt.xlabel('Time from obs. start (hours)', fontsize = 14)
plt.ylabel('Flux density (mJy)', fontsize = 14)
plt.xlim(0, times[-1])
plt.legend()
plt.savefig('psr_lc.png', bbox_inches = 'tight', dpi = 300)
plt.show()

XX, XY, YX, YY = get_ipol_data(XXfile, XYfile, YXfile, YYfile, times, dts, scan_start_indices, scan_end_indices)
I, Q, U, V = form_stokes(XX, XY, YX, YY, band = 'L')

aT = 1
aF = 1

I = average_stokes_ds(I, aT, aF)
Q = average_stokes_ds(Q, aT, aF)
U = average_stokes_ds(U, aT, aF)
V = average_stokes_ds(V, aT, aF)



fig, axes, im_list = plot_stokes_ds(I, Q, U, V, times, freqs)

fig.savefig('stokes_ds.png', bbox_inches = 'tight', dpi = 300)
plt.show()


aT = 1
aF = 64

I = average_stokes_ds(I, aT, aF)
Q = average_stokes_ds(Q, aT, aF)
U = average_stokes_ds(U, aT, aF)
V = average_stokes_ds(V, aT, aF)

fig, axes, im_list = plot_stokes_ds(I, Q, U, V, times, freqs)
fig.savefig('stokes_avg_ds.png', bbox_inches = 'tight', dpi = 300)
plt.show()

# fig, (ax1, ax4) = plt.subplots(2,1, figsize = (14, 7), sharex = True)

# im1 = ax1.imshow(np.real(I).T,
#                  aspect = 'auto',
#                  origin = 'lower',
#                  cmap = 'inferno',
#                  clim = (-0.01, 0.1),
#                  #clim = (-2E-2, 5E-2),
#                  #extent = [times[0], times[-1], freqs[0], freqs[-1]]
# )
# plt.sca(ax1)
# plt.colorbar(im1)



# im4 = ax4.imshow(np.real(V).T,
#                  aspect = 'auto',
#                  origin = 'lower',
#                  cmap = 'inferno',
#                  clim = (-30E-3, 30E-3),
#                  #extent = [times[0], times[-1], freqs[0], freqs[-1]]
        
# )
# plt.sca(ax4)
# plt.colorbar(im4)
# plt.savefig('IV_ds_202010.png', dpi = 300, bbox_inches = 'tight')
# plt.show()



# fig, ax1 = plt.subplots(1,1, figsize = (12,5), sharex = True)

# im1 = ax1.imshow(np.real(I).T,
#                  aspect = 'auto',
#                  origin = 'lower',
#                  cmap = 'inferno',
#                  clim = (-0.05, 0.2),
#                  #clim = (-2E-2, 5E-2),
#                  extent = [times[0], times[-1], freqs[0], freqs[-1]]
# )
# plt.sca(ax1)
# plt.colorbar(im1)

# #plt.show()

# ax1.set(xlabel = 'Time (h)',
#         ylabel = 'Frequency (MHz)')
# plt.savefig('uvsub_ds_I_modelcolumn.png', dpi = 300)
# plt.show()

# plt.plot(np.mean(np.real(V), axis = 1))
# plt.show()
