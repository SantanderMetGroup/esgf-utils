#!/bin/bash

#Just master Datasets
BASE_URL='https://esgf-data.dkrz.de/esg-search/search?format=application%2Fsolr%2Bjson&latest=true&replica=false&type=Dataset'

# Note that this performs OR for different facet values and AND for different facets
QUERY="project=CMIP5&experiment=historical,rcp26,rcp45,rcp85&time_frequency=fx,day&variable=pr,tas,tasmax,tasmin,sftlf"

FIELDS="fields=master_id,variable,size"
FACETS=""

LIMIT=10000
INDEXFILE=$1;

generate_index() {
	local i=0
	local end=$(curl -s "${BASE_URL}&${QUERY}" | jq '.response.numFound')
	echo "${BASE_URL}&${QUERY}" 
	local pending=$end

	while [ $pending -gt 0 ]; do
    	        local current=$(expr $i \* $LIMIT)
		local url="${BASE_URL}&${FIELDS}&${QUERY}&limit=${LIMIT}&offset=${current}&${FACETS}"

		echo "Pending: ${pending}, i=${i}"
		echo $url >&2
		curl -s "$url" | jq '.response.docs|.[]' >> $INDEXFILE
		
		pending=$(expr $pending - $LIMIT)
		let i=i+1
	done
}

> $INDEXFILE
generate_index

# Generate csv inventory
< index jq --slurp -r 'map({master_id, tasmax: .variable|join(" ")|test("\\btasmax\\b"), tasmin: .variable|join(" ")|test("\\btasmin\\b"), tas: .variable|join(" ")|test("\\btas\\b"), pr: .variable|join(" ")|test("\\bpr\\b"), sftlf: .variable|join(" ")|test("\\bsftlf\\b")})' | jq -r '(map(keys) | add | unique) as $cols   |     map(. as $row | $cols | map($row[.])) as $rows  |   $cols, $rows[]  |@csv' > inventory-esgf.csv
