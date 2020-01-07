#!/bin/bash
#SBATCH --job-name=sam44_p_fx
#SBATCH --workdir=.
#SBATCH --output=sam44_p_fx_%j.out
#SBATCH --error=sam44_p_fx_%j.out
#SBATCH --ntasks=16
#SBATCH --ntasks-per-node=16
#SBATCH --time=2:00:00

# NOTE! This version of the script works for nco version 4.4.4 and cdo version 1.6.3
# For the newer versions of tools, outcome of the script might differ
# To use cdo version 1.9.8 and nco version 4.9.1 on Atlatmira:
# export PATH="/home/uc15/uc15004/miniconda3/bin:$PATH"
# source activate cdo #usin2g this,cdo version 1.9.8 and nco version 4.9.1 are loaded

echo "I'm running in ${HOSTNAME}, and today is $(date)"

module load netcdf_tools # loading nco version 4.4.4 and cdo version 1.6.3
source ./dirs

expdir=${BASEDIR}
indir=${OUTPUTPOST1_FX}
outdir=${OUTPUTPOST2}

#Pathts necessary for running the core script
export SWPP_TEMPORARY_STORAGE=$TMPDIR
export SWPP_WRFNCXNJ_TABLE="${SCRIPTDIR}/wrfncxnj.table"
export SWPP_NETCDF_ATTRIBUTES="${SCRIPTDIR}/attributes.cdl"
export SWPP_WRFNCXNJ_GATTR="${SCRIPTDIR}/wrfnc_extract_and_join.gattr_CORWES_fx"
export SWPP_RLAT="${SCRIPTDIR}/rlat_file.nc"
export SWPP_RLON="${SCRIPTDIR}/rlon_file.nc"

cd ${SCRIPTDIR}

cropcmd='-selindexbox,11,156,11,177' # Removing 10 gridpoints of boudnaries.
DFX="-seltimestep,1"
freq="fx"
per1y="2006-2006"
bname="SAM-44_CCCma-CanESM2_rcp85_r0i0p0_UCAN-WRF341I_v2"

call_averager(){
  ivar=lco; ovar=lco; freq=${freq}; per=${per1y}; cmd="${DFX}"; cmd_swpp_averager
  ivar=sftls; ovar=sftls; freq=${freq}; per=${per1y}; cmd="${DFX}"; cmd_swpp_averager
  ivar=sftlf; ovar=sftlf; freq=${freq}; per=${per1y}; cmd="${DFX}"; cmd_swpp_averager
  ivar=orog; ovar=orog; freq=${freq}; per=${per1y}; cmd="${DFX}"; cmd_swpp_averager
  rm swpp_ave_files
}

cmd_swpp_averager() {
  sed -e 's/@var@/'${ivar}'/' swpp_ave_files > swpp_ave_files_${ivar}
  ./swpp_averager \
    -f swpp_ave_files_${ivar} \
    -c "${cmd} ${cropcmd}" \
    -p ${per} $(test ${ivar} != ${ovar} && echo "-r ${ivar},${ovar}") \
    -o ${outdir}/${ovar}_${bname}_${freq}.nc
  rm swpp_ave_files_${ivar}
}

cat << eof > swpp_ave_files
${indir}/*@var@*.nc:0:999
eof
call_averager

######################################################################################################

function modify_them() {
  while read bname expdir; do
    test ${bname:0:1} = "#" && continue
    ./swpp_shifttime_fx -i ${outdir}/lco_${bname}_${freq}.nc -v LU_INDEX  
    ./swpp_shifttime_fx -i ${outdir}/sftlf_${bname}_${freq}.nc -v LANDMASKF   
    ./swpp_shifttime_fx -i ${outdir}/sftls_${bname}_${freq}.nc -v LANDMASK   
    ./swpp_shifttime_fx -i ${outdir}/orog_${bname}_${freq}.nc -v HGT  
  done
}

cat << EOF | modify_them
${bname} ${BASEDIR}
EOF
