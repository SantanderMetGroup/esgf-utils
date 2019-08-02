#!/bin/bash

function ProgressBar {
# Author : Teddy Skarin
# https://github.com/fearside/ProgressBar/
# 1. Create ProgressBar function
# 1.1 Input is currentState($1) and totalState($2)	
# Process data
	let _progress=(${1}*100/${2}*100)/100
	let _done=(${_progress}*4)/10
	let _left=40-$_done
# Build progressbar string lengths
	_done=$(printf "%${_done}s")
	_left=$(printf "%${_left}s")

# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:
# 1.2.1.1 Progress : [########################################] 100%
    printf "\rProgress : [${_done// /#}${_left// /-}] ${_progress}%%"
}


#Just master Datasets
BASE_URL='https://esgf-data.dkrz.de/esg-search/search?format=application%2Fsolr%2Bjson&latest=true&replica=false&type=Dataset'
#Master files and its replicas
#BASE_URL='https://esgf-data.dkrz.de/esg-search/search?format=application%2Fsolr%2Bjson&latest=true&type=File'

# Note that this performs OR for different facet values and AND for different facets
QUERIES="project=CMIP6&activity_id=CMIP,ScenarioMIP&experiment_id=historical,ssp585&table_id=Amon,fx&frequency=fx,mon&variable_id=sftlf,pr,tas"

FIELDS="fields=master_id,size,number_of_files,variable_id,experiment_id,variant_label,source_id,institution_id,experiment_id"
FACETS="facets=activity_id,source_id,institution_id,source_type,nominal_resolution,experiment_id,variant_label,grid_label,table_id,frequency,realm,variable_id"

LIMIT=10000
INDEXFILE=$1;

generate_index() {
	_start=0
	_query=$1
	_end=$(curl -s "${BASE_URL}&${_query}&limit=0" | jq '.response.numFound')
	
	i=$_start
	pending=$_end

	while [ $pending -gt 0 ]; do
    	_current=$(expr $i \* $LIMIT)
		ProgressBar ${_current} ${_end}
		url="${BASE_URL}&${FIELDS}&${_query}&limit=${LIMIT}&offset=${_current}"
		echo $url >&2
		curl -s "$url" | jq '.response.docs|.[]' >> $INDEXFILE
		
		pending=$(expr $pending - $LIMIT)
		let i=i+1
	done
    ProgressBar ${_end} ${_end}

}

> $INDEXFILE
for q in $QUERIES
do
	generate_index ${q}
done