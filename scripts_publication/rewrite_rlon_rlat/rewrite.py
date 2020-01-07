#!/usr/bin/env python
# coding: utf-8
"""Redefine some attributes and coordinates from CORDEX data on SAM-44 domain.

Usage:
  rewrite.py DATAROOT...
  rewrite.py (-h | --help)
  rewrite.py --version

Arguments:
  DATAROOT      Data directory root to be traverse. All existing .nc files will be processed

Options:
  -h --help     Show this help.
  --version     Show version.
"""
__version__ = '0.0.1'
__authors__ = "JavierDiezSierra, cofinoa"
__date__    = "2019-12-27"

from docopt import docopt
import logging
from tqdm import tqdm
from netCDF4 import Dataset
import os
import sys

logging.basicConfig(format="[%(asctime)s] [%(levelname)-8s] --- %(message)s", datefmt="%Y%m%dT%H%M%S", level=logging.DEBUG)

FromFileName = 'rlon_rlat.nc'
ToFileName = 'dataroot/zg850_SAM-44_CCCma-CanESM2_rcp85_r1i1p1_UCAN-WRF341I_v2_day_20060101-20101231.nc'
varsToRemoveCellMethod = ['lco','orog','sftlf','sftls'];
#varsToRemoveCellMethod = ['zg'];

def traverseDir(root):
  for (dirpath, dirnames, filenames) in os.walk(root):
    for file in filenames:
      if file.endswith(('.nc')):
        yield os.path.join(dirpath, file)

def main(args):
  DATAROOT = args['DATAROOT'][0]
  try:
    dsFrom = Dataset(FromFileName)
  except Exception as e:
    logging.critical('Exception occurred opening the origin file "%s":\n\n%s\n',FromFileName,e)
    logging.critical('Bye Bye',)
    sys.exit(1)
  logging.info('Traversing dir: %s',DATAROOT)
  filecounter = 0
  for filepath in traverseDir(DATAROOT):
    filecounter += 1
  logging.info('Number of files to be processed: %d\n',filecounter)
  for i, ToFileName in enumerate(tqdm(traverseDir(DATAROOT), total=filecounter, unit="files"),1):
    dsTo = Dataset(ToFileName,'r+')
    dsTo.Conventions='CF-1.7'
    if 'rlon' in dsTo.variables:
      dsTo['rlon'][:] = dsFrom['rlon'][:]
    if 'rlat' in dsTo.variables:
      dsTo['rlat'][:] = dsFrom['rlat'][:]
    if 'mrso' in dsTo.variables:
      dsTo['mrso'].cell_methods = 'time: mean'
    for var in varsToRemoveCellMethod:
      if var in dsTo.variables and 'cell_methods' in dsTo[var].ncattrs():
        del dsTo[var].cell_methods
    dsTo.close()
  dsFrom.close()
  logging.info('Total files processed: %d',i)
  
if __name__ == '__main__':
  arguments = docopt(__doc__, version = __version__)
  logging.info("Arguments passed to main:\n\n%s\n", arguments)
  main(arguments)