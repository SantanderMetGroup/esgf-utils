#!/bin/bash
##SBATCH --job-name=sam44_p_fx
##SBATCH --workdir=.
##SBATCH --output=sam44_p_fx_%j.out
##SBATCH --error=sam44_p_fx_%j.out
##SBATCH --ntasks=16
##SBATCH --ntasks-per-node=16
##SBATCH --time=2:00:00

#Load necessary libraries
export PATH="/home/uc15/uc15004/miniconda3/bin:$PATH"
module load cdo
source activate wrfncxnj_py2.7
echo $(python --version)

BASEDIR="/home/uc15/uc15004/projects/EXPERIMENTS/josipa/SAM044_CanESM2_rcp8.5/CanESM2_rcp85"
DATEDIR="CanESM2_rcp85-default-20060101T000000"
SCRIPTDIR="${BASEDIR}/scripts"
TMPDIR="${SCRIPTDIR}/tmpdir"
POSTDIR="${BASEDIR}/post_data/post_fullres"
POST2DIR="${BASEDIR}/post_data/post_CORDEX"
FIGSDIR=$(pwd)/figs

expdir="${BASEDIR}/post_data/"
indir=${POSTDIR}
outdir=${POST2DIR}

cd ${SCRIPTDIR}

#Pathts necessary for running the core script
export SWPP_TEMPORARY_STORAGE=$TMPDIR
export SWPP_WRFNCXNJ_TABLE=/gpfs/res_projects/uc15/apps/wrfncxnj/wrfncxnj/wrfncxnj.table #table containg CORDEX naming 
export SWPP_NETCDF_ATTRIBUTES=${SCRIPTDIR}/attributes.cdl

cropcmd='-selindexbox,11,156,11,177' # Removing 10 gridpoints of boudnaries.
DFX="-seltimestep,1"

call_averager(){
  ivar=lco; ovar=lco; freq="fx"; per=${per1y}; cmd="${DFX}"; cmd_swpp_averager
  ivar=sftls; ovar=sftls; freq="fx"; per=${per1y}; cmd="${DFX}"; cmd_swpp_averager
  ivar=sftlf; ovar=sftlf; freq="fx"; per=${per1y}; cmd="${DFX}"; cmd_swpp_averager
  ivar=orog; ovar=orog; freq="fx"; per=${per1y}; cmd="${DFX}"; cmd_swpp_averager
  rm swpp_ave_files
}

cmd_swpp_averager() {
  sed -e 's/@var@/'${ivar}'/' swpp_ave_files > swpp_ave_files_${ivar}
  ./swpp_averager \
    -f swpp_ave_files_${ivar} \
    -c "${cmd} ${cropcmd}" \
    -p ${per} $(test ${ivar} != ${ovar} && echo "-r ${ivar},${ovar}") \
    -o ${outdir}/${ovar}_${bname}_r0i0p0_${rcmname}_${freq}.nc
  rm swpp_ave_files_${ivar}
}

per1y="2006-2006"
######################################################################################################
# Josipa changed 11.12.2019 - file names
bname="SAM-44_CCCma-CanESM2_rcp85"
######################################################################################################
rcmname="UCAN-WRF341I_v2"
expdir=${BASEDIR}
cat << eof > swpp_ave_files
${indir}/${DATEDIR}/2006/*@var@*.nc:0:999
eof
call_averager

function modify_them() {
  while read bname rcmname expdir; do
    test ${bname:0:1} = "#" && continue
    export SWPP_WRFNCXNJ_GATTR=${SCRIPTDIR}/wrfnc_extract_and_join.gattr_CORWES_fx
   ./swpp_shifttime_fx -i ${outdir}/lco_${bname}_r0i0p0_${rcmname}_fx.nc    -v LU_INDEX  
   ./swpp_shifttime_fx -i ${outdir}/sftlf_${bname}_r0i0p0_${rcmname}_fx.nc  -v LANDMASKF   
   ./swpp_shifttime_fx -i ${outdir}/sftls_${bname}_r0i0p0_${rcmname}_fx.nc  -v LANDMASK   
   ./swpp_shifttime_fx -i ${outdir}/orog_${bname}_r0i0p0_${rcmname}_fx.nc   -v HGT  
  done
}


cat << EOF | modify_them
SAM-44_CCCma-CanESM2_rcp85  UCAN-WRF341I_v2  ${BASEDIR}
EOF
