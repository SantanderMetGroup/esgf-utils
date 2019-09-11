#!/bin/bash

limit=10000
index=${1:-index};
inventory=inventory.csv

query='https://esgf-data.dkrz.de/esg-search/search?project=CMIP6&format=application%2Fsolr%2Bjson&latest=true&replica=false&activity_id=ScenarioMIP,CMIP,HighResMIP&experiment_id=ssp126,ssp245,ssp370,ssp460,ssp585,historical,esm-hist,Coupled&fields=instance_id,number_of_files,size,pid'

generate_index() {
	i=0
	pending=$(curl -s "${query}&limit=0" | jq '.response.numFound')

	while [ $pending -gt 0 ]; do
		curl -s "${query}&offset=$(expr $i \* $limit)&limit=${limit}" | jq '.response.docs|.[]' >> $index

		pending=$(expr $pending - $limit)
		let i=i+1
	done
}

# generate index
> ${index}
generate_index

# generate inventory
echo 'instance_id,number_of_files,size,pid' > ${inventory}
jq -r '[.instance_id, .number_of_files, .size, .pid[]] | @csv' < ${index} >> ${inventory}

# commit
git add ${index} ${inventory}
git commit -m "Updated $(date +%F)"
git push origin inventories
