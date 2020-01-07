#!/bin/bash
#SBATCH --job-name=SAM44post2
#SBATCH --output=SAM44post2_%j.out
#SBATCH --error=SAM44post2_%j.error
#SBATCH --ntasks=1
#SBATCH --time=72:00:00


module load netcdf_tools
source ./dirs

echo "I'm running in ${HOSTNAME}, and today is $(date)"

export SWPP_TEMPORARY_STORAGE=$TMPDIR
indir=${OUTPUTPOST1}
outdir=${OUTPUTPOST2}
bname="SAM-44_CCCma-CanESM2_rcp85_r1i1p1_UCAN-WRF341I_v2"

#Scenarios
per1y="2002-2002,2003-2003,2004-2004,2005-2005,2006-2006,2007-2007,2008-2008,2009-2009,2010-2010"
per5y="2091-2095,2096-2100" #"2071-2075,2076-2080,2081-2085,2086-2090"
per10y="2002-2010,2011-2020,2021-2030,2031-2040,2041-2050" 


#Options for the data
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
DMONTHX="-settime,12:00 -monmax -setday,1"
DSEAS="-settime,12:00 -seasmean -shifttime,-45 -setday,15"
DSEASX="-settime,12:00 -seasmax -shifttime,-45 -setday,15"

cd ${SCRIPTDIR}

call_averager(){
  ivar=mrsosd0.05; ovar=mrsos005; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=mrsosd0.25; ovar=mrsos025; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=tsos0.05; ovar=tsos005; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=tsos0.25; ovar=tsos025; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=tsos0.7; ovar=tsos07; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=tsos1.5; ovar=tsos15; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=slw0.05; ovar=slw005; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=slw0.25; ovar=slw025; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=slw0.7; ovar=slw07; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=slw1.5; ovar=slw15; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=mrsosd0.7; ovar=mrsos07; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=mrsosd1.5; ovar=mrsos15; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=ua850; ovar=ua850; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=ua200; ovar=ua200; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=ua500; ovar=ua500; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=va850; ovar=va850; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=va200; ovar=va200; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=va500; ovar=va500; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=ta850; ovar=ta850; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=ta200; ovar=ta200; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=ta500; ovar=ta500; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=zg850; ovar=zg850; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=zg200; ovar=zg200; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=zg500; ovar=zg500; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=hus850; ovar=hus850; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=hus200; ovar=hus200; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=hus500; ovar=hus500; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=hur850; ovar=hur850; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=hur200; ovar=hur200; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=hur500; ovar=hur500; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=clice850; ovar=clice850; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=clice200; ovar=clice200; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=clice500; ovar=clice500; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=clfr850; ovar=clfr850; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=clfr200; ovar=clfr200; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=clfr500; ovar=clfr500; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=clwmr850; ovar=clwmr850; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=clwmr200; ovar=clwmr200; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=clwmr500; ovar=clwmr500; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=uas; ovar=uas; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=vas; ovar=vas; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=huss; ovar=huss; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=tas; ovar=tas;    freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=tas; ovar=tasmax; freq="day"; per=${per5y}; cmd="${DX}"; cmd_swpp_averager
  ivar=tas; ovar=tasmin; freq="day"; per=${per5y}; cmd="${DN}"; cmd_swpp_averager
  ivar=ts;  ovar=tsmax;  freq="day"; per=${per5y}; cmd="${DX}"; cmd_swpp_averager
  ivar=ts;  ovar=tsmin;  freq="day"; per=${per5y}; cmd="${DN}"; cmd_swpp_averager
  ivar=tasmax; ovar=tasmaxts; freq="day"; per=${per5y}; cmd="${DX}"; cmd_swpp_averager  
  ivar=tasmin; ovar=tasmints; freq="day"; per=${per5y}; cmd="${DN}"; cmd_swpp_averager
  ivar=clt; ovar=clt; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=sic; ovar=sic; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=rsus; ovar=rsus; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=rlus; ovar=rlus; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=evspsbl; ovar=evspsbl; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=evspsblpot; ovar=evspsblpot; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=pr;  ovar=pr;  freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=prc; ovar=prc; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=ps;  ovar=ps;  freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=psl; ovar=psl; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=hfls; ovar=hfls; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=hfss; ovar=hfss; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=rlds; ovar=rlds; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=rsds; ovar=rsds; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=sfcWind; ovar=sfcWind;    freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=sfcWind; ovar=sfcWindmax; freq="day"; per=${per5y}; cmd="${DX}"; cmd_swpp_averager
  ivar=mrros; ovar=mrros; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=mrro;  ovar=mrro;  freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=mrso;  ovar=mrso;  freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=snm; ovar=snm; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=snw; ovar=snw; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=rsdt; ovar=rsdt; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=rsut; ovar=rsut; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=rlut; ovar=rlut; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=ts; ovar=ts; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=zmla; ovar=zmla; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=prw; ovar=prw; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=clivi;  ovar=clivi; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=clwvi; ovar=clwvi; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=cll; ovar=cll; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=clh; ovar=clh; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=clm; ovar=clm; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=snd; ovar=snd; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=snownc; ovar=snownc; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=mross; ovar=mross; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=aclwdnt; ovar=aclwdnt; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=alb; ovar=alb; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=hurs; ovar=hurs; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=prls; ovar=prls; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=hufs; ovar=hufs; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=ustar; ovar=ustar; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  ivar=sst; ovar=sst; freq="day"; per=${per5y}; cmd="${DM}"; cmd_swpp_averager
  rm swpp_ave_files
}

cmd_swpp_averager() {
  sed -e 's/@var@/'${ivar}'/' swpp_ave_files > swpp_ave_files_${ivar}
  ./swpp_averager \
    -f swpp_ave_files_${ivar} \
    -c "${cmd} ${cropcmd}" \
    -p ${per} $(test ${ivar} != ${ovar} && echo "-r ${ivar},${ovar}") \
    -o ${out_path}/${ovar}_${bname}_${freq}_'${iyear}0101-${fyear}1231'.nc
  rm swpp_ave_files_${ivar}
}

cat << EOF > swpp_ave_files
${in_path}/CanESM2_rcp85-default-20020101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20060101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20100101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20140101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20180101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20220101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20260101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20300101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20340101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20380101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20420101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20460101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20500101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20540101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20580101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20620101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20660101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20700101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20740101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20780101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20820101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20860101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20900101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20940101T000000/*/*_@var@.nc:12:60
${in_path}/CanESM2_rcp85-default-20980101T000000/*/*_@var@.nc:12:60
EOF
call_averager
echo "post2 completed succesfully"

