#!/usr/bin/env python

"""This script has been generated to make the following changes on the data located in:
 /home/javi/oceano/gmeteo/DATA/ESGF/UNICAN-NODE/DATASETS/SAM-44_CCCma-CanESM2_rcp8.5_r1i1p1_UCAN-WRF341I_v2_20191125/
#1) Change rcp8.5 for rcp85 in global attributes
#2) Add tracking_id  ("uuid -v 4")
#3) Fix unlimited time.""" 

import os
import sys
from netCDF4 import Dataset

path = '/home/javi/oceano/gmeteo/DATA/ESGF/UNICAN-NODE/DATASETS/\
#SAM-44_CCCma-CanESM2_rcp8.5_r1i1p1_UCAN-WRF341I_v2_20191125/'

files = []
# r=root, d=directories, f = files
for r, d, f in os.walk(path):
    for file in f:
        if '.nc' in file:
            files.append(os.path.join(r, file))


for file in files:
    root_grp = Dataset(file)
    frequency=root_grp.frequency
    
    #Define new global attributes
    global_att={}
    global_att['SWPP_SHIFTTIME'] = root_grp.SWPP_SHIFTTIME ;
    global_att['creation_date'] = root_grp.creation_date ;
    global_att['Conventions'] = root_grp.Conventions ;
    global_att['title'] = root_grp.title ;
    global_att['contact'] = root_grp.contact ;
    global_att['experiment'] = root_grp.experiment ;
    global_att['experiment_id'] = "rcp85" ;
    global_att['driving_experiment'] = "CCCma-CanESM2,rcp85,r1i1p1" ;
    global_att['driving_experiment_name'] = "rcp85" ;
    global_att['driving_model_id'] = root_grp.driving_model_id ;
    global_att['driving_model_ensemble_member'] = root_grp.driving_model_ensemble_member ;
    global_att['frequency'] = root_grp.frequency ;
    global_att['institution'] = root_grp.institution ;
    global_att['institute_id'] = root_grp.institute_id ;
    global_att['model_id'] = root_grp.model_id ;
    global_att['rcm_version_id'] = root_grp.rcm_version_id ;
    global_att['project_id'] = root_grp.project_id ;
    global_att['CORDEX_domain'] = root_grp.CORDEX_domain ;
    global_att['product'] = root_grp.product ;
    global_att['references'] = root_grp.references ;
    global_att['ucan_run_id'] = root_grp.ucan_run_id ;
    global_att['ucan_run_performance'] = root_grp.ucan_run_performance;
    
    #Create tracking_id
    tracking_id_=os.popen("uuid -v 4").read()
    global_att['tracking_id'] = tracking_id_[0:-1];
  
    root_grp.close()
    
    #Overwrite global attributes
    for key in global_att.keys():
        os.system("ncatted -O -h -a " + key + ",global,o,c," + global_att[key] +  " " + file)

    #Fix time dimension (Fixing unlimited time dimension)
    if frequency=='fx':
        a=1
    else:
        os.system("ncks -O -h --fix_rec_dmn time " + file + " " + file)

