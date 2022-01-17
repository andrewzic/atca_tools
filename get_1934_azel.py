import astropy.units as u
from astropy.time import Time
from astropy.coordinates import SkyCoord, EarthLocation, Angle, AltAz
import numpy as np
import sys

print("usage: python get_1934_azel.py \"2022-01-19 08:30:00\"")

t_str = sys.argv[1]


atca_loc = EarthLocation.from_geodetic(149.5501388*u.deg, -30.3128846*u.deg, height = 236.87*u.m)

coords_1934 = SkyCoord('19h39m25.026s -63d42m45.63s')#, location = atca_loc)

t = Time(t_str, format = 'iso')

def src_to_azel(coord = coords_1934, location = atca_loc, time = t):

    altaz = coord.transform_to(AltAz(location = location, obstime = time))

    
    return(altaz)

src_to_azel()

dts = np.arange(-3.0, 3.0, 0.01)*u.minute
times = t + dts



all_altazs = src_to_azel(time = times)
central_altaz = src_to_azel(time = t)
print(central_altaz.to_string('dms', sep = ':'))
all_altazs_ = AltAz(az = all_altazs.az, alt = all_altazs.alt, location = atca_loc, obstime = t)
central_altaz_ = AltAz(az = central_altaz.az, alt = central_altaz.alt, location = atca_loc, obstime = t)

seps = all_altazs_.separation(central_altaz_).to(u.arcminute)

#print(seps)
#import matplotlib.pyplot as plt
#plt.plot(dts.to(u.minute), seps)

#plt.show()
