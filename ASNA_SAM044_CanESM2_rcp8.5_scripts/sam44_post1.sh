#!/bin/bash
##SBATCH --job-name=SAM44_p1
##SBATCH --output=SAM44_p1_%j.out
##SBATCH --error=SAM44_p1_%j.error
##SBATCH --ntasks=1
##SBATCH --ntasks-per-node=16
##SBATCH --time=72:00:00

echo "I'm running in ${HOSTNAME}, and today is $(date)"

export PATH="/home/uc15/uc15004/miniconda3/bin:$PATH"
source activate wrfncxnj_py2.7
export SWPP_WRFNCXNJ_PY=wrfncxnj 
source ./dirs

year_blocks=(2006) #2002 2006 2010 2014 2018 2022 2026 2030 2034 2038 2042 2046 2050) 

for ij in "${year_blocks[@]}"
  do
  echo $ij

REALIZATION="${WRF4G_EXP}-${ij}0101T000000"
INPUTPOST0="${BASEDIR}/data/CanESM2_rcp85/${REALIZATION}/output" #path to the folder with wrfout files, directly from the model
INPUTPOST0_XTRM="${BASEDIR}/data/CanESM2_rcp85/${REALIZATION}/post0/WRFXTRM/XTRM_MONTHLY" #path to the folder with wrfxtrm files, organised
OUTPUTPOST0="${BASEDIR}/data/CanESM2_rcp85/${REALIZATION}/post0" #path to the folder where output files after post0 will be written

#Pathts necessary for running the core script
  export SWPP_TEMPORARY_STORAGE=$TMPDIR
  export SWPP_FULLFILE=${FULLFILE}
  export SWPP_GEOFILE=${GEOFILEDIR}  
  export SWPP_WRFNCXNJ_GLOBALATTR=${WRFNCXNJ_GLOBALATTR}     #attributes defined in a file located in the scripts
  export SWPP_WRFNCXNJ_TABLE=${WRFNCXNJ_TABLE}   	     #table containg CORDEX naming 
  export SWPP_NETCDF_ATTRIBUTES=${NETCDF_ATTRIBUTES}

cd ${SCRIPTDIR}
  indir=${OUTPUTPOST0}   
  outdir=${OUTPUTPOST1}


# Move files with 1 timestep to a side folder called BACKUP
# When running wrf4g, when a chunk is finished, a file with one timestep is created, 
# And when rerunning WRF from wrfrst file, additional the first file in the new chunk has
# the same timestep and the last file in the previous chunk. To avoid repeatinig of the
# timesttpes, moving files to a BACKUP folde is done:
 BACKUP=${BASEDIR}/${REALIZATION}/BACKUP
 mkdir -p ${BACKUP}
 if [ -f ${indir}/"wrfout*T000000Z.nc" ]; then
   mv ${indir}/"wrfout*T000000Z.nc" ${BACKUP}
 fi


#Variables that will be taken out from the original wrf
 filetype="out"  # for wrfout:"out" wrfxtrm:"xtrm"
 vars=T2,RAINF,PSFC,MSLP,Q2,SPDUV10,ACSWDNB,ACLWDNB,ACLHF,ACHFX, \
     ACSWUPB,ACLWUPB,SFROFF,UDROFF,MRSO,MRRO,RAINC,ACLWUPT,ACSWDNT, \
     ACSWUPT,U10ER,V10ER,TSK,PBLH,SNOWH,SNOWNC,SNOW,CLT,ACSNOM,VIM, \
     VIQC,VIQI,QFX,RAINNC,ALBEDO,SST,ACLWDNT,UST,SFCEVP,POTEVP,CLH, \
     CLM,CLL,RH2,XICEM,TSLB,SH2O,SMOIS,UER,VER,TEMP,QVAPOR,GHT,QCLOUD, \
     QICE,RH,CLDFRA,LU_INDEX,LANDMASK,HGT,LANDMASKF
 levels="850,500,200"
 slevels="0.05,0.25,0.70,1.50"
 filter="-v ${vars} -l ${levels} -s ${slevels}"

test "${filetype}" == "xtrm" && filter="${filter} -y ${filetype} --dont-check-nofim"
   mkdir -p ${outdir}
   export SWPP_OUTPUT_PATTERN=${outdir}/'${year}/CDX_CANESM2_3H_${year}${month}_[varcf][level].nc'
   ./swpp_wrfnc2cf.sh ${filter} -i ${indir}
done
