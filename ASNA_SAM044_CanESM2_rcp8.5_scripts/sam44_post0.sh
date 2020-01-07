#!/bin/bash
#SBATCH --job-name=SAM44p0
#SBATCH --output=p0_post_%j.out
#SBATCH --error=p0_post_%j.error
#SBATCH --ntasks=16
#SBATCH --ntasks-per-node=16
#SBATCH --time=72:00:00

echo "I'm running in ${HOSTNAME}, and today is $(date)"

export PATH="/home/uc15/uc15004/miniconda3/bin:$PATH"
source activate wrfncxnj_py2.7
source ./dirs


year_blocks=(2006) #2002 2006 2010 2014 2018 2022 2026 2030 2034 2038 2042 2046 2050) 

for ij in "${year_block[@]}"
  do
  echo $ij

REALIZATION="${WRF4G_EXP}-${ij}0101T000000"
GEOFILEDIR=${GEOFILEDIR}
INPUTPOST0="${BASEDIR}/data/CanESM2_rcp85/${REALIZATION}/output" #path to the folder with wrfout files, directly from the model
INPUTPOST0_XTRM="${BASEDIR}/data/CanESM2_rcp85/${REALIZATION}/post0/WRFXTRM/XTRM_MONTHLY" #path to the folder with wrfxtrm files, organised
OUTPUTPOST0="${BASEDIR}/data/CanESM2_rcp85/${REALIZATION}/post0" #path to the folder where output files after post0 will be written

indir=${INPUTPOST0}
outdir=${OUTPUTPOST0}

echo "Input is $indir"
echo "Output is $outdir"
mkdir -p ${outdir}

cd ${indir}
files=$(ls wrfout* -1)
for wrfnc_file in ${files}
do
  ${SCRIPTDIR}/postprocessor.CORDEX_ALL $wrfnc_file
  mv $wrfnc_file ${outdir}
  echo "Moving file to post0"
  echo $(free -m | grep Mem)
done

mv ${indir}/wrfxtrm* ${outdir}
echo "Moving wrfxtrm files to post0"

done

source deactivate
