# OSM Sandbox Deploy

- Deploy osm-sandbox



```
cd osm-sandbox
helm dependency update
cd ..
helm upgrade --install osm --wait osm-sandbox/ -f values.dev.yaml -f osm-sandbox/values.yaml --dry-run
helm upgrade --install osm --wait osm-sandbox/ -f values.dev.yaml

```