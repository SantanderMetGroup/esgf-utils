#!/bin/bash
##SBATCH --job-name=SAM44_p1
##SBATCH --output=SAM44_p1_%j.out
##SBATCH --error=SAM44_p1_%j.error
##SBATCH --ntasks=1
##SBATCH --ntasks-per-node=16
##SBATCH --time=72:00:00

set -e
echo "I'm running in ${HOSTNAME}, and today is $(date)"
export PATH="/home/uc15/uc15004/miniconda3/bin:$PATH"
module load netcdf_tools
source activate wrfncxnj_py2.7
echo $(python --version)

year_block=(2006) #2002 2006 2010 2014 2018 2022 2026 2030 2034 2038 2042 2046 2050) 

for ij in "${year_block[@]}"
  do
  echo $ij

  BASEDIR="/home/uc15/uc15004/projects/EXPERIMENTS/josipa/SAM044_CanESM2_rcp8.5/CanESM2_rcp85"
  DATEDIR="CanESM2_rcp85-default-${ij}0101T000000"
  GEOFILEDIR="/gpfs/res_projects/uc15/DOMAINS/CORDEX_SouthAm044_WRF3.4.1"
  SCRIPTDIR="${BASEDIR}/scripts"
  FULLFILE="${BASEDIR}/scripts"
  DOMAIN=1
  TMPDIR="${SCRIPTDIR}/tmpdir"
  NPUTPOST0="${BASEDIR}/data/CanESM2_rcp85/${DATEDIR}/output"
  OUTPUTPOST0="${BASEDIR}/data/CanESM2_rcp85/${DATEDIR}/post0/"
  INPUTPOST1="${OUTPUTPOST0}"
  ONESTEPPOST1="${OUTPUTPOST0}/outputs_one_step/"
  OUTPUTPOST1="${BASEDIR}/post_data/post_fullres/${DATEDIR}/"
  SINGLERECPOST1="${OUTPUTPOST1}/single_records/"
  INPUTPOST2="${OUTPUTPOST1}"
  OUTPUTPOST2="${BASEDIR}/post_data/post_CORDEX"

cd ${SCRIPTDIR}

  dir_scripts=${SCRIPTDIR}
  in_path=${INPUTPOST0}   
  out_path=${OUTPUTPOST1}
  realisation=${DATEDIR}

#move files with 1 timestep to a side folde called REZERVA
 REZERVA=${BASEDIR}/data/CanESM2_rcp85/${DATEDIR}/REZERVA
 mkdir -p ${REZERVA}
 if [ -f ${in_path}/"wrfout*T000000Z.nc" ]; then
   mv ${in_path}/"wrfout*T000000Z.nc" ${REZERVA}
 fi


#Variables that will be taken out from the original wrf
filetype="out"  # Modificar segun las variables a posprocesar, extremas:xtrm, normales:out
#vars=T2,RAINF,PSFC,MSLP,Q2,SPDUV10,ACSWDNB,ACLWDNB,ACLHF,ACHFX,ACSWUPB,ACLWUPB,SFROFF,UDROFF,MRSO,MRRO,RAINC,ACLWUPT,ACSWDNT,ACSWUPT,U10ER,V10ER,TSK,PBLH,SNOWH,SNOWNC,SNOW,CLT,ACSNOM,VIM,VIQC,VIQI,QFX,RAINNC,ALBEDO,SST,ACLWDNT,UST,SFCEVP,POTEVP,CLH,CLM,CLL,RH2,XICEM,TSLB,SH2O,SMOIS,UER,VER,TEMP,QVAPOR,GHT,QCLOUD,QICE,RH,CLDFRA,LU_INDEX,LANDMASK,HGT
vars=LANDMASKF
levels="850,500,200"
slevels="0.05,0.25,0.70,1.50"
filter="-v ${vars} -l ${levels} -s ${slevels}"

#Pathts necessary for running the core script
export SWPP_TEMPORARY_STORAGE=$TMPDIR
export SWPP_FULLFILE=${SCRIPTDIR}/wrffull_corwes.nc
export SWPP_GEOFILE=${SCRIPTDIR}/geo_em.d01.nc  
export SWPP_WRFNCXNJ_PY=wrfncxnj 
export SWPP_WRFNCXNJ_GLOBALATTR=${SCRIPTDIR}/wrfnc_extract_and_join.gattr_CORWES #attributes defined in a file located in the scripts
export SWPP_WRFNCXNJ_TABLE=/gpfs/res_projects/uc15/apps/wrfncxnj/wrfncxnj/wrfncxnj.table #table containg CORDEX naming 

test "${filetype}" == "xtrm" && filter="${filter} -y ${filetype} --dont-check-nofim"

expdir="${BASEDIR}" #define an experimental directory where the data will be written out
   mkdir -p ${OUTPUTPOST1}
   export SWPP_OUTPUT_PATTERN=${OUTPUTPOST1}/'${year}/CDX_CANESM2_3H_${year}${month}_[varcf][level].nc'
   bash ./swpp_wrfnc2cf.sh ${filter} -i ${INPUTPOST1}

done
