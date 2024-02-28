# Coop App Chart

A Reusable Helm chart for deployments to the API-Platform. The chart can be
used for both HTTP and gRPC deployments.

As of version 0.2.7 it provides

* Deployment with best practices and Datadog universal tagging
* Service and connectivity through HTTP and gRPC
* Setup autoscaling
* Secret injection (if you setup the namespace for it)
* HTTP to gRPC transcoding
* Ability to add arbitrary resources

## Using

The intended way to use this chart is to use this as a dependency. This means
that you create a new chart for your service and depend on the
`coop-app-chart`. We first create an empty helm chart.

```shell
helm create <service>
cd service
echo --- > values.yaml
rm -fr templates/*
```

Now edit `Chart.yaml` and add

```yaml
dependencies:
  - name: coop-app-chart
    version: 0.2.7
    repository: "https://coopnorge.github.io/helm-base-chart"
    alias: app
```

We take an gRPC service as an example setup. Edit `values.yaml`

```yaml
---

app: # app key related to the alias defined in the dependencies.
  name: helloworld
  
  image: 
    repository: path-to-repo/helloworld
    tag: v1.2.9999
  port: 3000
  
  environmentVariables:
    APIS: coopnorge.helloworld.v1 coopnorge.helloworld.v1beta 
  
  secrets:  # requires external secret manager
    helloworld:
      provider: gcp 
      secrets:
        TEST: testy
      mountAsEnvironment: true
  
  resources:
    memory: 128M
    cpu: 2
  
  connectivity:
    gRPC:
      enabled: true
 
    externalServices:
      hellworld:
        hosts:
          - google.com
          - vg.no 
          - coop.no
        ports:
          - name: https
            number: 443
            protocol: https
    httpToGRPC:
      enabled: true
      services:
      - coopnorge.helloworld.v1.HelloWorldAPI
      - coopnorge.helloworld.v1beta1.HelloWorldAPI
      protoDescriptorBinValue: some-base-64-encodedvalue
```

Then create another file called `values-production.yaml`

```yaml
app:
  environment: production 
  image: path-to-repo/helloworld:<my-prd-tag>
```

More examples can be found [helm-base-chart repo][helm-base-chart]. The full
spec the input can be found [here][coop-app-chart-values]

In [`kubernetes-projects`][kubernetes-projects] configure you projects as this

```yaml
manifestRepos:
  - repoURL: https://github.com/coopnorge/helloworld
    service: helloworld
    path: infrastructure/kubernetes/helm/helloworld
    helmValueFiles:
    - values.yaml
    - values-production.yaml
    targetRevision: main
    destinationCluster: api-production
    # configconnector and exteral secrets require this terraform module in 
    # the service project infrastructure
    # https://github.com/coopnorge/terraform-google-gke-config-connector
    # if you dont want to consume sercets you can not remove this section.
    configConnector:
      enabled: true
      version: v2
    externalSecretsStores:
      gcp:
        enabled: true
    gcp:
      projectId: helloworld-production-5120
```

[helm-base-chart]: https://github.com/coopnorge/helm-base-chart/tree/main/examples
[kubernetes-projects]: https://github.com/coopnorge/kubernetes-projects
[coop-app-chart-values]: https://github.com/coopnorge/helm-base-chart/blob/main/charts/coop-app-chart/values.yaml

## Development

* When developing make sure to keep the examples up to date
* The helm schema is generated using https://github.com/dadav/helm-schema

