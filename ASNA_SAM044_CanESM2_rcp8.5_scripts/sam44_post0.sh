#!/bin/bash
#SBATCH --job-name=SAM44p0
#SBATCH --output=p0_post_%j.out
#SBATCH --error=p0_post_%j.error
#SBATCH --ntasks=16
#SBATCH --ntasks-per-node=16
#SBATCH --time=72:00:00

#Para filtrar las variables a mano:

set -e
export PATH="/home/uc15/uc15004/miniconda3/bin:$PATH"
source activate py_interp_2.7
module load netcdf_tools

year_block=(2098) 

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
INPUTPOST0="${BASEDIR}/data/CanESM2_rcp85/${DATEDIR}/output"
OUTPUTPOST0="${BASEDIR}/data/CanESM2_rcp85/${DATEDIR}/post0/"
INPUTPOST1="${OUTPUTPOST0}"
ONESTEPPOST1="${OUTPUTPOST0}/outputs_one_step/"
OUTPUTPOST1="${BASEDIR}/post_data/post_fullres/${DATEDIR}/"
SINGLERECPOST1="${OUTPUTPOST1}/single_records/"
INPUTPOST2="${OUTPUTPOST1}"
OUTPUTPOST2="${BASEDIR}/post_data/post_CORDEX"

dir_scripts=${SCRIPTDIR}
in_path=${INPUTPOST0}
out_path=${OUTPUTPOST0}

echo "Input is $in_path"
echo "Output is $out_path"
mkdir -p ${out_path}

cd ${INPUTPOST0}
files=$(ls wrfout* -1)
for wrfnc_file in ${files}
do
  ${dir_scripts}/postprocessor.CORDEX_ALL $wrfnc_file
  mv $wrfnc_file ${out_path}
  echo "Moving file to post0"
  echo $(free -m | grep Mem)
done

mv ${in_path}/wrfxtrm* ${out_path}
echo "Moving wrfxtrm files to post0"

done

source deactivate
