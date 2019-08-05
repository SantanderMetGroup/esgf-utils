# Recipes for data search, data inventory generation and data download

## CMIP6 search, inventory and download

Generate a local index using `index.sh`

CSV from index

```bash
< $INDEX jq -r --slurp 'map(map_values([.]|flatten|first)) | (map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] |@csv'
```

Inventory

```bash
# Aggregate variables by dataset
jq --slurp 'map(. + { dataset_id: (.master_id|split(".")|del(.[7])|join(".")),master_id})    | group_by(.dataset_id)       | map(   reduce .[] as $item ({variables: []}; {dataset_id: $item.dataset_id, variables: (.variables + $item.variable)}  )   )' < $INDEX

# Export to csv
jq -r 'map({dataset_id, variables: .variables|join(" ")})  |   (map(keys) | add | unique) as $cols   |     map(. as $row | $cols | map($row[.])) as $rows  |   $cols, $rows[]  |@csv'
```

Download

```bash
models='AWI-CM-1-1-MR BCC-CSM2-MR BCC-ESM1 CAMS-CSM1-0 CanESM5 CNRM-CM6-1 CNRM-ESM2-1 EC-Earth3-Veg EC-Earth3 IPSL-CM6A-LR MIROC6 HadGEM3-GC31-LL UKESM1-0-LL MRI-ESM2-0 GISS-E2-1-G GISS-E2-1-H CESM2-WACCM CESM2 GFDL-CM4 GFDL-ESM4 SAM0-UNICON'
experiments='historical esm-hist ssp585'
variables='tas pr'

parallel -j1 synda install -y source_id={1} experiment_id={2} variable_id={3} member_id=r1i1p1f1 table_id=Amon ::: $models ::: $experiments ::: $variables

parallel -j1 synda install -y source_id={1} experiment_id={2} variable_id=sftlf member_id=r1i1p1f1 table_id=fx ::: $models ::: $experiments
```

<!-- COMMENT by Antonio


base_url='https://esgf-data.dkrz.de/esg-search/search?project=CMIP6&format=application%2Fsolr%2Bjson&latest=true&replica=false'


activity=CMIP
experiment=historical

curl -s "${base_url}&activity_id=${activity}&experiment_id=${experiment}&fields=numFound" | vi -c 'set syntax=json' -

#numFound
curl -s "${base_url}&activity_id=${activity}&experiment_id=${experiment}&limit=0"

https://esgf-data.dkrz.de/esg-search/search/?
offset=0&
limit=10&
type=Dataset&
replica=false&
latest=true&
activity_id=CMIP%2CScenarioMIP&
variable_id=pr%2Csftlf%2Ctas&
experiment_id=historical%2Cssp585&
frequency=fx%2Cmon&
table_id=Amon%2Cfx&
mip_era=CMIP6
&facets=mip_era%2Cactivity_id%2Cmodel_cohort%2Cproduct%2Csource_id%2Cinstitution_id%2Csource_type%2Cnominal_resolution%2Cexperiment_id%2Csub_experiment_id%2Cvariant_label%2Cgrid_label%2Ctable_id%2Cfrequency%2Crealm%2Cvariable_id%2Ccf_standard_name%2Cdata_node
&format=application%2Fsolr%2Bjson


ACTIVITY_ID=CMIP,ScenarioMIP:;
EXPERIMENT_ID="historical,ssp585"
TABLE_ID="Amon,fx"
VARIABLE_ID="sftlf,pr,tas"
FREQUENCY="fx,mon"


BASE_URL='https://esgf-data.dkrz.de/esg-search/search?format=application%2Fsolr%2Bjson&latest=true&replica=false'

QUERY="project=CMIP6&activity_id=CMIP,ScenarioMIP&experiment_id=historical,ssp585&table_id=Amon,fx&frequency=fx,mon&variable_id=sftlf,pr,tas"

FIELDS="fields=master_id,size,number_of_files,variable_id,experiment_id,variant_label,source_id,institution_id,experiment_id"
FACETS="facets=activity_id,source_id,institution_id,source_type,nominal_resolution,experiment_id,variant_label,grid_label,table_id,frequency,realm,variable_id"


curl -s "${BASE_URL}&${QUERY}&${FACETS}&${FIELDS}&limit=1000"

####
keys_unsorted as $headers | [flatten] | map(. as $row | $headers | with_entries({ "key": .value,"value": $row[.key]}) )

-->