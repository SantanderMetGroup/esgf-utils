#!/bin/bash
##SBATCH --job-name=2002xp1
##SBATCH --output=2002xp1_%j.out
##SBATCH --error=2002xp1_%j.error
##SBATCH --ntasks=1
##SBATCH --ntasks-per-node=16
##SBATCH --time=72:00:00
##Enter the folder where the postporcessing scripts and files are located - need to adapt!!!

module load netcdf_tools
echo "I'm running in ${HOSTNAME}, and today is $(date)"

sortxtrm="0"
post1="0"
post2="0"
post3="1"

year_block=(2098)
BASEDIR="/home/uc15/uc15004/projects/EXPERIMENTS/josipa/SAM044_CanESM2_rcp8.5/CanESM2_rcp85"
SCRIPTDIR="${BASEDIR}/scripts"
GEOFILEDIR="/gpfs/res_projects/uc15/DOMAINS/CORDEX_SouthAm044_WRF3.4.1"
FULLFILE="${BASEDIR}/scripts"
DOMAIN=1
TMPDIR="${BASEDIR}/scripts/tmpdir"
POSTDIR="${BASEDIR}/post_data/post_fullres"
POST2DIR="${BASEDIR}/post_data/post_CORDEX"
FIGSDIR=$(pwd)/figs

if test ${sortxtrm} -eq 1; then

for ij in "${year_block[@]}"
  do
  echo $ij

  DATEDIR="CanESM2_rcp85-default-${ij}0101T000000"
  INPUTPOST0="${BASEDIR}/data/CanESM2_rcp85/${DATEDIR}/output"
  OUTPUTPOST0="${BASEDIR}/data/CanESM2_rcp85/${DATEDIR}/post0/"
  INPUTPOST1="${BASEDIR}/data/CanESM2_rcp85/${DATEDIR}/post0/WRFXTRM/XTRM_MONTHLY"
  OUTPUTPOST1="${BASEDIR}/post_data/post_fullres/${DATEDIR}/" 
  INPUTPOST2="${OUTPUTPOST1}"
  OUTPUTPOST2="${BASEDIR}/data/CanESM2_rcp85/${DATEDIR}/post2/"  

  wdir="${OUTPUTPOST0}/WRFXTRM/"
  ydir="${wdir}/XTRM_YEARLY"
  mdir="${wdir}/XTRM_MONTHLY"

  months=(1 2 3 4 5 6 7 8 9 10 11 12)
  ndays=(31 28 31 30 31 30 31 31 30 31 30 31)
  ns=(0 31 59 90 120 151 181 212 243 273 304 334) 
  ne=(30 58 89 119 150 180 211 242 272 303 333 364)

  ny=(  0   1    2    3    4)
  sd=(  1 366  731 1096 1461)
  ed=(365 730 1095 1460 1825)

  sdorig=(  0 365  730 1095 1460)
  edorig=(364 729 1094 1459 1824)

  rm $wdir/*
  rm $ydir/*
  rm $mdir/*

  year1=$ij
  year2=`expr ${ij} + 1`
  year3=`expr ${ij} + 2`
  year4=`expr ${ij} + 3`
  year5=`expr ${ij} + 4`
  years=(${year1} ${year2} ${year3} ${year4} ${year5}) 

#######################################################################################################################################
#create working directories
  if [[ ! -e $wdir ]]; then
    mkdir $wdir
  elif [[ ! -d $wdir ]]; then
    echo "$wdir already exists" 1>&2
  fi

  if [[ ! -e $ydir ]]; then
    mkdir $ydir
  elif [[ ! -d $ydir ]]; then
    echo "$ydir already exists" 1>&2
  fi

  if [[ ! -e $mdir ]]; then
    mkdir $mdir
  elif [[ ! -d $mdir ]]; then
    echo "$mdir already exists" 1>&2
  fi

  cp ${OUTPUTPOST0}/wrfxtrm* ${wdir}/

#######################################################################################################################################
#check double timesteps
  cd ${wdir}
  for file in wrfxtrm*.nc
  do
   n=${file%T000000Z*}          
   nfiles=`ls -al ${n}*.nc | wc -l`
   if [ $nfiles -ne 1 ]; then   
    x=1
    y=$(( $nfiles - 1 ))
     while [ $x -le $y ]
     do
      fdouble_1=`ls ${n}*.nc | sort -V | tail -n $x`
      rm $fdouble_1
      x=$(( $x + 1 ))
     done
   fi
  done


  cd ${wdir}
  last_wrfxtrm=`ls -t wrfxtrm_d01_${year5}12* | head -n1`
  echo $last_wrfxtrm
  for file in wrfxtrm*.nc
    do
    timesteps=`cdo -ntime $file` > /dev/null 2>&1
    #echo "timesteps="$timesteps
    if [ $timesteps -le "6" ]; then
     if [[ "$file" == "$last_wrfxtrm" ]];then
      echo $file " is the last file in the chunk, not touching"
     else
      echo $file " is a small file, cut the timestep"
      ncks -d Time,0,4 $file "cat_"$file   #hardcoded, possible need to adapt this
      mv "cat_"$file $file
     fi
    fi
  done

#######################################################################################################################################
#merge files
cd ${wdir}
   ncrcat -h wrfxtrm_d01_*.nc wrfxtrm_d01_5years_raw.nc
   ntimesteps=`cdo -ntime wrfxtrm_d01_5years_raw.nc` > /dev/null 2>&1
for i in "${ny[@]}"
  do 
  year=${years[i]}
  echo "working on the year $year"
   next_year=`expr ${year} + 1`  
        soday=${sdorig[i]} 
        eoday=${edorig[i]} 
        sday=${sd[i]} 
        eday=${ed[i]} 
     ncks -d Time,${soday},${eoday} wrfxtrm_d01_5years_raw.nc tstep_wrfxtrm_d01_$year.nc
     ncks -d Time,${sday},${eday} wrfxtrm_d01_5years_raw.nc wrfxtrm_d01_$year.nc
     ncks -A -v Times tstep_wrfxtrm_d01_$year.nc wrfxtrm_d01_$year.nc
     mv wrfxtrm_d01_$year.nc $ydir/
  done

  rm $wdir/wrfxtrm_d01_*
  rm $wdir/tstep_wrfxtrm*

#######################################################################################################################################
#split per months
mv $ydir/* .
for i in "${years[@]}"
  do
  echo $i
   for j in "${months[@]}"
    do
       k=`expr ${j} - 1`
       ndays=${ndays[k]} 
       start=${ns[k]} 
       end=${ne[k]} 
       
       if [ $j -lt 10 ]; then
        month=0${j}
       else
        month=${j}
       fi
       ncks -d Time,${start},${end} wrfxtrm_d01_${i}.nc wrfxtrm_d01_${i}${month}01T000000Z_${i}${month}${ndays}T210000Z.nc  
       mv wrfxtrm_d01_${i}${month}01T000000Z_${i}${month}${ndays}T210000Z.nc $mdir/  
    done
       echo "Separations per month per year ${i} completed succesfully"
       mv wrfxtrm_d01_${i}.nc $ydir/
   done
done
echo "work on the block ${years} completed succesfully"
fi

#######################################################################################################################################
#processing post1


if test ${post1} -eq 1; then

#Load necessary libraries
export PATH="/home/uc15/uc15004/miniconda3/bin:$PATH"
module load netcdf_tools
source activate wrfncxnj_py2.7
echo $(python --version)

#Variables that will be taken out from the original wrf
filetype="xtrm"
vars=T2MAX,T2MIN
levels="850,500,200"
slevels="0.05,0.25,0.70,1.50"
filter="-v ${vars} -l ${levels} -s ${slevels}"

for ij in "${year_block[@]}"
  do
  echo $ij

DATEDIR="CanESM2_rcp85-default-${ij}0101T000000"
INPUTPOST0="${BASEDIR}/data/CanESM2_rcp85/${DATEDIR}/output"
OUTPUTPOST0="${BASEDIR}/data/CanESM2_rcp85/${DATEDIR}/post0/WRFXTRM/XTRM_MONTHLY/"
INPUTPOST1="${OUTPUTPOST0}"
OUTPUTPOST1="${BASEDIR}/post_data/post_fullres/${DATEDIR}/" 
INPUTPOST2="${OUTPUTPOST1}"
OUTPUTPOST2="${BASEDIR}/data/CanESM2_rcp85/${DATEDIR}/post2/"

dir_scripts=${SCRIPTDIR}
in_path=${INPUTPOST1}   
out_path=${OUTPUTPOST1}
realisation=${DATEDIR}

export SWPP_TEMPORARY_STORAGE=$TMPDIR
export SWPP_FULLFILE=${SCRIPTDIR}/wrffull_corwes.nc
export SWPP_GEOFILE=${SCRIPTDIR}/geo_em.d01.nc  
export SWPP_WRFNCXNJ_PY=wrfncxnj 
export SWPP_WRFNCXNJ_GLOBALATTR=${SCRIPTDIR}/wrfnc_extract_and_join.gattr_CORWES           #attributes defined in a file located in the scripts
export SWPP_WRFNCXNJ_TABLE=/gpfs/res_projects/uc15/apps/wrfncxnj/wrfncxnj/wrfncxnj.table   #table containg CORDEX naming 

test "${filetype}" == "xtrm" && filter="${filter} -y ${filetype} --dont-check-nofim"

cd ${SCRIPTDIR}
expdir="${OUTPUTPOST1}"
   mkdir -p ${OUTPUTPOST1}
   export SWPP_OUTPUT_PATTERN=${expdir}/'${year}/CDX_CANESM2_DAM_${year}${month}_[varcf][level].nc'
   bash ./swpp_wrfnc2cf_SAM_xtrm.sh ${filter} -i ${INPUTPOST1}
done
echo "post1 completed succesfully"
fi
#######################################################################################################################################
#processing post2
if test ${post2} -eq 1; then

set -e
export PATH="/home/uc15/uc15004/miniconda3/bin:$PATH"
source activate wrfncxnj_py2.7
module load netcdf_tools

BASEDIR="/home/uc15/uc15004/projects/EXPERIMENTS/josipa/SAM044_CanESM2_rcp8.5/CanESM2_rcp85"
SCRIPTDIR="${BASEDIR}/scripts"
TMPDIR="${SCRIPTDIR}/tmpdir"
POSTDIR="${BASEDIR}/post_data/post_fullres"
POST2DIR="${BASEDIR}/post_data/post_CORDEX"
FIGSDIR=$(pwd)/figs

dir_scripts=${SCRIPTDIR}
in_path=${POSTDIR}
out_path=${POST2DIR}
export SWPP_TEMPORARY_STORAGE=$TMPDIR

cropcmd='-selindexbox,11,156,11,177' # Removing 10 gridpoints of boudnaries.
DYS="-settime,12:00 -shifttime,-1" # Se utiliza para las variables extremas
DX="-settime,12:00 -daymax"
DN="-settime,12:00 -daymin"
DM="-settime,12:00 -daymean"
DMS="-settime,12:00 -daymean -shifttime,-1"
DS="-settime,12:00 -daysum"
D24="-seltime,00:00"
D12="-seltime,00:00,12:00"
D06="-seltime,00:00,06:00,12:00,18:00"
DMONTH="-settime,00:00 -monmean -setday,1"
#DMONTHX="-settime,12:00 -monmax -setday,1"
DSEAS="-settime,12:00 -seasmean -shifttime,-45 -setday,15"
DSEASX="-settime,12:00 -seasmax -shifttime,-45 -setday,15"

cd ${dir_scripts}


call_averager(){
  ivar=tasmax; ovar=tasmaxts; freq="day"; per=${per5y}; cmd="${DX}"; cmd_swpp_averager  
  ivar=tasmin; ovar=tasmints; freq="day"; per=${per5y}; cmd="${DN}"; cmd_swpp_averager
<<comm
  ivar=clwmr200; ovar=clwmr200; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=clwmr500; ovar=clwmr500; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
comm
  rm swpp_ave_files
}

cmd_swpp_averager() {
  sed -e 's/@var@/'${ivar}'/' swpp_ave_files > swpp_ave_files_${ivar}
  ./swpp_averager \
    -f swpp_ave_files_${ivar} \
    -c "${cmd} ${cropcmd}" \
    -p ${per} $(test ${ivar} != ${ovar} && echo "-r ${ivar},${ovar}") \
    -o ${out_path}/${ovar}_${bname}_${freq}_'${iyear}0101-${fyear}1231'.nc

BASEDIR="/home/uc15/uc15004/projects/EXPERIMENTS/josipa/SAM044_CanESM2_rcp8.5/CanESM2_rcp85"
SCRIPTDIR=${BASEDIR}/scripts
POSTDIR="${BASEDIR}/post_data/post_fullres"
POST2DIR="${BASEDIR}/post_data/post_CORDEX"
FIGSDIR=$(pwd)/figs


  rm swpp_ave_files_${ivar}
#--cdo-flags -z zip_4 -f nc4c \
}

###########################################################################
########################  Scenarios  ######################################
###########################################################################

per1y="2002-2002,2003-2003,2004-2004,2005-2005,2006-2006,2007-2007,2008-2008,2009-2009,2010-2010"
per5y="2071-2075,2076-2080,2081-2085,2086-2090" #"2006-2010,2011-2015,2016-2020,2021-2025,2026-2030,2031-2035,2036-2040,2041-2045,2046-2050" 
per10y="2002-2010,2011-2020,2021-2030,2031-2040,2041-2050" 
#2051-2055,2056-2060,2061-2065,2066-2070,2071-2075,2076-2080,2081-2085,2086-2090,2091-2095,2096-2100"
#2051-2060,2061-2070,2071-2080,2081-2090,2091-2100"

bname="SAM-44_CCCma-CanESM2_rcp8.5_r1i1p1_UCAN-WRF341I_v2"

cat << eof > swpp_ave_files
  #${in_path}/CanESM2_rcp85-default-20020101T000000/*/*_@var@.nc:12:60
  #${in_path}/CanESM2_rcp85-default-20060101T000000/*/*_@var@.nc:12:60
  #${in_path}/CanESM2_rcp85-default-20100101T000000/*/*_@var@.nc:12:60
  #${in_path}/CanESM2_rcp85-default-20140101T000000/*/*_@var@.nc:12:60
  #${in_path}/CanESM2_rcp85-default-20180101T000000/*/*_@var@.nc:12:60
  #${in_path}/CanESM2_rcp85-default-20220101T000000/*/*_@var@.nc:12:60
  #${in_path}/CanESM2_rcp85-default-20260101T000000/*/*_@var@.nc:12:60
  #${in_path}/CanESM2_rcp85-default-20300101T000000/*/*_@var@.nc:12:60
  #${in_path}/CanESM2_rcp85-default-20340101T000000/*/*_@var@.nc:12:60
  #${in_path}/CanESM2_rcp85-default-20380101T000000/*/*_@var@.nc:12:60
  #${in_path}/CanESM2_rcp85-default-20420101T000000/*/*_@var@.nc:12:60
  #${in_path}/CanESM2_rcp85-default-20460101T000000/*/*_@var@.nc:12:60
  ${in_path}/CanESM2_rcp85-default-20700101T000000/*/*_@var@.nc:12:60
  ${in_path}/CanESM2_rcp85-default-20740101T000000/*/*_@var@.nc:12:60
  ${in_path}/CanESM2_rcp85-default-20780101T000000/*/*_@var@.nc:12:60
  ${in_path}/CanESM2_rcp85-default-20820101T000000/*/*_@var@.nc:12:60
  ${in_path}/CanESM2_rcp85-default-20860101T000000/*/*_@var@.nc:12:60
  ${in_path}/CanESM2_rcp85-default-20900101T000000/*/*_@var@.nc:12:60
eof
call_averager
fi


#######################################################################################################################################
#processing post3
if test ${post3} -eq 1; then
set -e
export PATH="/home/uc15/uc15004/miniconda3/bin:$PATH"
source activate wrfncxnj_py2.7
module load netcdf_tools

BASEDIR="/home/uc15/uc15004/projects/EXPERIMENTS/josipa/SAM044_CanESM2_rcp8.5/CanESM2_rcp85"
SCRIPTDIR="${BASEDIR}/scripts"
TMPDIR="${BASEDIR}/scripts/tmpdir"
POSTDIR="${BASEDIR}/post_data/post_fullres"
POST2DIR="${BASEDIR}/post_data/post_CORDEX"

expdir=${BASEDIR}
dir_scripts=${SCRIPTDIR}
in_path=${POSTDIR}
out_path=${POST2DIR}
export SWPP_TEMPORARY_STORAGE=$TMPDIR

cd ${dir_scripts}
export SWPP_TEMPORARY_STORAGE=$TMPDIR
export SWPP_WRFNCXNJ_TABLE=/gpfs/res_projects/uc15/apps/wrfncxnj/wrfncxnj/wrfncxnj.table
export SWPP_NETCDF_ATTRIBUTES=${dir_scripts}/attributes.cdl

######################################################################################################
# Josipa changed 11.12.2019 - file names
bname="SAM-44_CCCma-CanESM2_rcp85_r1i1p1_UCAN-WRF341I_v2"
######################################################################################################

function modify_them() {
  while read bname expdir; do
  test ${bname:0:1} = "#" && continue
  export SWPP_WRFNCXNJ_GATTR=${SCRIPTDIR}/wrfnc_extract_and_join.gattr_CORWES
   ./swpp_shifttime_new -i ${out_path}/tasmaxts_${bname}_day_'????????-????????'.nc -l 0.5 -r 0.5 -v T2MAX -c 'time: maximum'
   ./swpp_shifttime_new -i ${out_path}/tasmints_${bname}_day_'????????-????????'.nc -l 0.5 -r 0.5 -v T2MIN -c 'time: minimum'
  done
}

cat << EOF | modify_them
${bname} ${BASEDIR}
EOF
fi


















































