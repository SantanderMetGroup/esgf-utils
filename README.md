# Recipes for data search, data inventory generation and data download

## CMIP6 search, inventory and download

Local index generation

1. Generate a local index using `index.sh`
1. To clean the index, use `< $INDEX jq --slurp 'map(map_values([.]|flatten|first))'`

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