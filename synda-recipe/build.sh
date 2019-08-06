SDT_LIB="${PREFIX}/lib/sd"
SDT_CONF_FILE="$PREFIX/conf/sdt.conf"
SDT_CRED_FILE="$PREFIX/conf/credentials.conf"

cd synda/sdt
python setup.py install --install-scripts=${SDT_LIB}
chmod go+r "$SDT_CONF_FILE"
chmod u=rw,g=,o= "$SDT_CRED_FILE"

# allow daemon to log into discovery.log
sed -i '206ilog_stdout=open("{}/{}".format(sdconfig.log_folder,sdconst.LOGFILE_FEEDER), "a+")' ${SDT_LIB}/sddaemon.py
sed -i '207ilog_stderr=open("{}/{}".format(sdconfig.log_folder,sdconst.LOGFILE_FEEDER), "a+")' ${SDT_LIB}/sddaemon.py
sed -i '/context=daemon.DaemonContext(working_directory=sdconfig.tmp_folder, pidfile=pidfile,)/ c\
context=daemon.DaemonContext(working_directory=sdconfig.tmp_folder, pidfile=pidfile,stdout=log_stdout,stderr=log_stderr)' ${SDT_LIB}/sddaemon.py
sed -i '41iimport sdconst' ${SDT_LIB}/sddaemon.py

cd $PREFIX/bin
ln -fs ${SDT_LIB}/sdcleanup_tree.sh sdcleanup_tree.sh
ln -fs ${SDT_LIB}/sdget.sh sdget.sh
ln -fs ${SDT_LIB}/sdgetg.sh sdgetg.sh
ln -fs ${SDT_LIB}/sdparsewgetoutput.sh sdparsewgetoutput.sh
ln -fs ${SDT_LIB}/synda.py synda
ln -fs ${SDT_LIB}/sdtc.py sdtc
ln -fs ${SDT_LIB}/sdconfig.py sdconfig
ln -fs ${SDT_LIB}/sdget.py sdget
ln -fs ${SDT_LIB}/sdmerge.py sdmerge
#ln -fs ${PREFIX}/bin/sdlogon.sh sdlogon.sh
#ln -fs ${PREFIX}/bin/sddownloadtest.py sddownloadtest

cd ${PREFIX}
mkdir "${PREFIX}/{data,db}"
touch data/.data db/sdt.db

# activate ST_HOME when environment is activated
mkdir -p ${PREFIX}/etc/conda/{activate.d,deactivate.d}
echo "export ST_HOME=${PREFIX}" > ${PREFIX}/etc/conda/activate.d/synda-transfer.sh
echo "unset ST_HOME" > ${PREFIX}/etc/conda/deactivate.d/synda-transfer.sh

