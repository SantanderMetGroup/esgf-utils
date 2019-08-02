#!/bin/bash

groups='ScenarioMIP_ssp126
ScenarioMIP_ssp245
ScenarioMIP_ssp370
ScenarioMIP_ssp460
ScenarioMIP_ssp585
CMIP_historical
CMIP_esm-hist
HighResMIP_Coupled'

limit=10000
index=$1;

base_url='https://esgf-data.dkrz.de/esg-search/search?project=CMIP6&format=application%2Fsolr%2Bjson&latest=true&replica=false'

generate_index() {
	activity=$1
	experiment=$2
	i=0
	
	pending=$(curl -s "${base_url}&activity_id=${activity}&experiment_id=${experiment}" | jq '.response.numFound')
	# >&2 echo $pending

	while [ $pending -gt 0 ]; do
		url="${base_url}&offset=$(expr $i \* $limit)&activity_id=${activity}&experiment_id=${experiment}&limit=${limit}"
		curl -s "$url" | jq '.response.docs|.[]' >> $index
		
		pending=$(expr $pending - $limit)
		let i=i+1
	done
}

> $index
for g in $groups
do
	values=(${g//_/ })
	generate_index ${values[0]} ${values[1]}
done
