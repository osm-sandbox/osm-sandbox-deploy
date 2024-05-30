# OpenStreetMap Sandbox Deploy

OSM Sandbox Deploy is a repository that contains helm charts. It is based on [osm-seed](https://github.com/developmentseed/osm-seed) and a customized Web image.


## Deploying locally

Replace the values in values.template.yaml and deploy it into kubernetes cluster.

```sh
helm dependency update
helm upgrade --install osm --wait osm-sandbox/ -f values.dev.yaml -f osm-sandbox/values.yaml --dry-run
# helm upgrade --install osm --wait osm-sandbox/ -f values.dev.yaml
```