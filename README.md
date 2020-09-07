# ESGF utils

Tools for dealing with ESGF.

## esgf-search

Query ESGF using either facet parameters or selection files. `esgf-search` requires `jq` and `curl`

Each paragraph in a SELECTION file will perform a query.

Examples:

- Return the JSON response: `esgf-search -q "project=CMIP5 variable=psl time_frequency=day cmor_table=day"`
- Using SELECTION files: `esgf-search SELECTION1 SELECTION2`
- Query and SELECTION files: `esgf-search -q "project=CMIP5 variable=psl time_frequency=day cmor_table=day" SELECTION1 SELECTION2 SELECTION3`
- Return number of items: `esgf-search -q "project=CMIP5 variable=psl time_frequency=day cmor_table=day" | jq --slurp 'length'`
- Return the search size: `esgf-search -q "project=CMIP5 variable=psl time_frequency=day cmor_table=day" SELECTION1 | jq --slurp 'map(.size)|add' | numfmt --to=iec`

Selection file example (note that multiple facets are allowed in one line):

```
project=CMIP6 experiment_id=historical,ssp585
source_id=CanESM5 variant_label=r1i1p1f1
type=File

project=CMIP6
experiment_id=historical,ssp585
source_id=CNRM-CM6-1
variant_label=r1i1p1f2
```

## esgf-metalink

Create metalink files from the results of esgf-search

`esgf-search -q "project=CMIP6 experiment_id=ssp585 variable_id=pr frequency=mon type=File" | esgf-metalink > $METALINK_FILE`

To download data protected by ESGF accounts:

`
aria2c --check-certificate=false --certificate=/PATH/TO/certificate-file --private-key=/PATH/TO/certificate-file --ca-certificate=/PATH/TO/certificate-file -M $METALINK_FILE
`

Set up the graphical interface:

```
git clone https://github.com/ziahamza/webui-aria2
xdg-open webui-aria2/docs/index.html
```

`esgf-download` is provided to help with aria2c download although it's use is not mandatory.

```
esgf-download -d /oceano/gmeteo/DATA/ESGF/REPLICA/DATA -g .globus/ -l logs metalink
```

Also, CEDA has disabled range requests, required by `aria2c`, so `esgf-download-ceda` is provided to extract CEDA urls and use `curl` to perform the download. Note that when replicas are used this is not needed but CORDEX files have no replicas so this is the only workaround.

```
esgf-download-ceda -d /oceano/gmeteo/DATA/ESGF/REPLICA/DATA -g .globus/ metalink
```

## esgf-facets-report

Report ESGF facet counts for local installed files
