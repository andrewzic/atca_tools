import astropy.units as u
from astropy.time import Time
from astropy.coordinates import SkyCoord, EarthLocation, Angle, AltAz
import numpy as np
import sys

print("usage: python get_1934_azel.py \"2022-01-19 08:30:00\"")

t_str = sys.argv[1]
t = Time(t_str, format = 'iso')

#atca_loc = EarthLocation.from_geodetic(149.5501388*u.deg, -30.3128846*u.deg, height = 236.87*u.m)
atca_loc = EarthLocation.from_geocentric(-4750915.837*u.m, 2792906.182*u.m, -3200483.747*u.m)

#coords_1934 = SkyCoord('19h50m30.31s -63d24m52.1s') #"apparent" coordinates from Parkes COORD tool
coords_1934 = SkyCoord('19h39m25.026s -63d42m45.63s', frame = 'icrs', location = atca_loc)

#src_to_azel()
def src_to_azel(coord = coords_1934, location = atca_loc, time = t):

    altaz = coord.transform_to(AltAz(location = location, obstime = time))
    
    return(altaz)


central_altaz = SkyCoord(src_to_azel(time = t))
print(central_altaz.to_string(decimal = True))
print(central_altaz.to_string('dms', sep = ':'))

#from Parkes COORD tool for 2022-01-17 22:46:00 UTC
test_altaz = SkyCoord(AltAz(az = 151.51*u.deg, alt = 44.71*u.deg, location = atca_loc, obstime = t))


print(test_altaz.to_string(decimal = True))
print(test_altaz.to_string('dms'))


#dts = np.arange(-3.0, 3.0, 0.01)*u.minute
#times = t + dts

# all_altazs = SkyCoord(src_to_azel(time = times))

# seps = all_altazs.separation(central_altaz).to(u.arcminute)

#print(seps)
#import matplotlib.pyplot as plt
#plt.plot(dts.to(u.minute), seps)

#plt.show()
