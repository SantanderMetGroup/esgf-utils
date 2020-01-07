#!/usr/bin/env python
# coding: utf-8

import os
import sys
import subprocess

root='/oceano/gmeteo/DATA/ESGF/UNICAN-NODE/DATASETS/SAM-44_CCCma-CanESM2_rcp85_r1i1p1_UCAN-WRF341I_v2_20191223/'

def subprocess_errors(nco_str):
    try:
        subprocess.call([nco_str], shell=True)
    except Exception as e:
        print(e)
        sys.exit()

# Get the list of all files in directory tree at given path after split
listOfFiles = list()
for (dirpath, dirnames, filenames) in os.walk(root):
    listOfFiles += [os.path.join(dirpath, file) for file in filenames]

for file in listOfFiles:
    subprocess_errors('ncks -A -h -v lat,lon good_rlon_rlat.nc ' + file)
    subprocess_errors("ncatted -O -h -a " + 'Conventions' + ",global,m,c," + 'CF-1.7' +  " " + file)
    if 'mrso' in file:
        subprocess_errors("ncatted -O -h -a " + 'cell_methods' + ",mrso,o,c," + 'time: mean' +  " " + file)

