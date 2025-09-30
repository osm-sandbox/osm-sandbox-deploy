# OpenStreetMap Sandbox Stack Deployment

Helm chart for deploying an OSM Sandbox. The chart is based on [osm-seed](https://github.com/developmentseed/osm-seed), but extends it with two custom container images:

- `osm-sandbox-web` - OpenStreetMap Rails webapp, with tweaked configs to support sandbox authentication flow (the sandbox uses the 'password' OAuth grant type, which is normally disabled)
- `sandbox-populate-apidb` - initialization job for importing data from an OSM PBF file into the sandbox database

Images are built and published to ghcr.io via chartpress when changes are pushed to main. The chart itself is published to https://osm-sandbox.github.io/osm-sandbox-deploy.

The [OSM Sandbox dashboard](https://github.com/osm-sandbox/osm-sandbox-dashboard) uses this chart to deploy Sandbox instances on demand.

## Deployment

### Using the published chart

```sh
helm repo add osm-sandbox https://osm-sandbox.github.io/osm-sandbox-deploy
helm repo update
helm install osm osm-sandbox/osm-sandbox-deploy -f your-values.yaml
```

### Deploying from source

Copy and customize values:
```sh
cp values.template.yaml values.dev.yaml
# Edit values.dev.yaml with your configuration
```

Deploy to your cluster:
```sh
helm dependency update ./osm-sandbox
helm upgrade --install osm ./osm-sandbox -f values.dev.yaml
```

### Local development with Docker Compose

For testing the web image locally:
```sh
docker-compose up
```
