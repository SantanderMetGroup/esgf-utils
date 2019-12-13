#!/usr/bin/env python
# coding: utf-8
"""
Script to preprocess nc files before creating the DRS CORDEX structure using esgprep.
The script performs the following actions:
1)Esgprep doesnt work when nc files global attributes are empty (e.g. :history = "" ;).
  The script detects empty global attributes and delete them
2).....
3).....
  """

import os
import sys
from netCDF4 import Dataset
import subprocess
import argparse

def get_gb_attributes(root_grp):
    "Get global attributes from a nc file"
    gb_attr_est={}
    nc_attrs = root_grp.ncattrs()
    for nc_attr in nc_attrs:
        gb_att = root_grp.getncattr(nc_attr)
        gb_attr_est[nc_attr]=gb_att
        
    return gb_attr_est

def delete_empty_gb_attributes(file):

    #Get NetCDF global attributes
    root_grp = Dataset(file)#open nc
    gb_attr_est=get_gb_attributes(root_grp)
    root_grp.close()#close nc, if it is not done could give some errors

    #Eliminate those global attibutes that are empty
    for nc_attr in gb_attr_est.keys():
        gb_att=gb_attr_est[nc_attr]

        if not gb_att:
            print('###Output###')
            print("File: " + file)
            print('Empty global attribute:')
            print ('\t%s:' % nc_attr, repr(gb_att))


            try:
                subprocess.call(["ncatted -O -h -a " + nc_attr +",global,d,, " + file], shell=True)
                #os.system("ncatted -O -h -a " + nc_attr +",global,d,, " + file)

            except Exception as e:
                print (e)


def main(args):
    # Get the list of all files in directory tree at given path
    listOfFiles = list()
    for (dirpath, dirnames, filenames) in os.walk(args.root):
        listOfFiles += [os.path.join(dirpath, file) for file in filenames]
     
    for file in listOfFiles:

        #Get NetCDF global attributes
        root_grp = Dataset(file)#open nc
        gb_attr_est=get_gb_attributes(root_grp)
        root_grp.close()#close nc, if it is not done could give some errors
        
        #Eliminate those global attibutes that are empty
        delete_empty_gb_attributes(file)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Script to preprocess nc files before creating the DRS CORDEX structure using esgprep')
    parser.add_argument('--root', dest='root', type=str, help='Directory substring before DRS')
    args = parser.parse_args()
    main(args)