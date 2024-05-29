# OSM Sandbox Deploy

- Deploy osm-sandbox

```
helm upgrade --install osm --wait osm-sandbox/ -f values.dev.yaml -f osm-sandbox/values.yaml --dry-run
```