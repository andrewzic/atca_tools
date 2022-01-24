import astropy.units as u
from astropy.time import Time
from astropy.coordinates import SkyCoord, EarthLocation, Angle, AltAz, FK5, ICRS
import numpy as np
import sys

print("usage: python get_1934_azel.py \"2022-01-19 08:30:00\"")

#atca_loc = EarthLocation.from_geodetic(149.5501388*u.deg, -30.3128846*u.deg, height = 236.87*u.m)
atca_loc = EarthLocation.from_geocentric(-4750915.837*u.m, 2792906.182*u.m, -3200483.747*u.m)

t_str = sys.argv[1]
t = Time(t_str, format = 'iso', location = atca_loc)




coords_1934_ = SkyCoord('19h39m25.026s -63d42m45.63s', frame = FK5, location = atca_loc, equinox = 'J2000')

coords_1934 = coords_1934_.transform_to(FK5(equinox = t))
#coords_1934 = coords_1934_
print(coords_1934_.to_string('hmsdms'))
print(coords_1934.to_string('hmsdms'))
coords_1934_apparent = SkyCoord('19h50m30.31s -63d24m52.1s') #"apparent" coordinates from Parkes COORD tool

coords_1934_chris = SkyCoord('19h41m22.48414328s -63d39m46.04165779s')

#src_to_azel()
def src_to_azel(coord = coords_1934, location = atca_loc, time = t):

    altaz = coord.transform_to(AltAz(location = location, obstime = time))
    
    return(altaz)


central_altaz = SkyCoord(src_to_azel(time = t))
print("""

Az-El according to astropy/me:
""")

print(central_altaz.to_string(decimal = True))
print(central_altaz.to_string('dms', sep = ':'))


central_altaz_ = SkyCoord(src_to_azel(coord = coords_1934_, time = t))
print("""

Az-El according to astropy/me without equinox correction:
""")

print(central_altaz_.to_string(decimal = True))
print(central_altaz_.to_string('dms', sep = ':'))

print(central_altaz_.separation(central_altaz).to(u.arcsecond))
# central_altaz_app = SkyCoord(src_to_azel(coord = coords_1934_apparent, time = t))
# print("""

# Az-El according to astropy w/ "Apparent" coord from Parkes COORD tool:
# """)

# print(central_altaz_app.to_string(decimal = True))
# print(central_altaz_app.to_string('dms', sep = ':'))


# central_altaz_chris = SkyCoord(src_to_azel(coord = coords_1934_chris, time = t))
# print("""

# Az-El according to astropy w/ "Apparent" coord from Chris Phillips:
# """)


# print(central_altaz_chris.to_string(decimal = True))
# print(central_altaz_chris.to_string('dms', sep = ':'))



# #from Parkes COORD tool for 2022-01-17 22:46:00 UTC
# test_altaz = SkyCoord(AltAz(az = 151.74 * u.deg, alt = 45.10*u.deg, location = atca_loc, obstime = t))#151.51*u.deg, alt = 44.71*u.deg, location = atca_loc, obstime = t))
# print("""

# Az-El according to Parkes COORD webtool for 2022-01-17 22:46:00 UTC:
# """)

# print(test_altaz.to_string(decimal = True))
# print(test_altaz.to_string('dms'))

# cabb_altaz = SkyCoord(AltAz(az = Angle('152d25m23.6s', unit = u.deg), alt = Angle('45d32m24.0s', unit = u.deg), location = atca_loc, obstime = t))
# print("""

# Az-El according to CABBScheduler webtool for 2022-01-17 22:46:00 UTC:
# """)

# print(cabb_altaz.to_string(decimal = True))
# print(cabb_altaz.to_string('dms'))


# t_actual = Time('2022-01-17 22:49:44.9297', location = atca_loc)
# actual_altaz = SkyCoord(AltAz(az = 152.765*u.deg, alt = 45.7636*u.deg, location = atca_loc, obstime = t_actual))

# print("""

# Actual Az-El at {} UTC
# """.format(t_actual.iso))

# print(actual_altaz.to_string(decimal = True))
# print(actual_altaz.to_string('dms'))


#dts = np.arange(-3.0, 3.0, 0.01)*u.minute
#times = t + dts

# all_altazs = SkyCoord(src_to_azel(time = times))

# seps = all_altazs.separation(central_altaz).to(u.arcminute)

#print(seps)
#import matplotlib.pyplot as plt
#plt.plot(dts.to(u.minute), seps)

#plt.show()
