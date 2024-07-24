# update-helm-registry-to-oci

One time script to convert helm registry `index.yaml` with GitHub releases to
oci registry.

It uploads the files to oci registry and then changes `index.yaml` with new
urls.

The `index.yaml` file needs to be copied from `gh-pages` branch and placed here.

## Setup

To install dependencies:

```bash
bun install
```

To log in to OCI registry:

```bash
gcloud auth application-default print-access-token | helm registry login -u oauth2accesstoken --password-stdin europe-docker.pkg.dev/helmbasecharts-shared-5ebb/coop-helm-charts
```

To run:

```bash
bun run update-helm-registry-to-oci.ts
```

This project was created using `bun init` in bun v1.1.20. [Bun](https://bun.sh) is a fast 
all-in-one JavaScript runtime.
