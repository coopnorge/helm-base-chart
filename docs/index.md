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
    version: 0.5.0
    repository: "https://coopnorge.github.io/helm-base-chart"
    alias: app
```

After adding the dependencies, generate the lock using the following:

```bash
helm dependency build
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
      helloworld:
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
    # configconnector and external secrets require this terraform module in 
    # the service project infrastructure
    # https://github.com/coopnorge/terraform-google-gke-config-connector
    # if you don't want to consume secrets you can not remove this section.
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
* The helm schema is generated using [helm-schema][helm-schema]

[helm-schema]: https://github.com/dadav/helm-schema

## Automatic updating of helm charts

Dependabot does not support automatic updates for helm charts. So, we use
[renovate bot][renovate bot] for configuring automatic updates. The
following files need to be setup for this to work:

```yaml title=".github/workflows/renovate.yaml"
# .github/workflows/renovate.yaml
on:
  workflow_dispatch:
    inputs:
      logLevel:
        description: "Override default log level"
        required: false
        default: "info"
        type: string
  schedule:
    # At 07:30 AM and 12:30 PM, every day
    - cron: '30 7,12 * * *'
jobs:
  renovate:
    permissions:
      contents: write
      pull-requests: write
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Get token
        id: get_token
        uses: actions/create-github-app-token@v1.8.1
        with:
          app-id: 635546
          private-key: ${{ secrets.RENOVATE_APP_PRIVATE_KEY_PEM }}
          owner: coopnorge
          repositories: helloworld
      - name: Run Renovate
        uses: renovatebot/github-action@v40.1.2
        env:
          # Repository taken from variable to keep configuration file generic
          RENOVATE_REPOSITORIES: ${{ github.repository }}
          # Onboarding not needed for self-hosted
          RENOVATE_ONBOARDING: "false"
          # Username for GitHub authentication (should match GitHub App name + [bot])
          RENOVATE_USERNAME: "coopnorge-renovate[bot]"
          # Git commit author used, must match GitHub App
          RENOVATE_GIT_AUTHOR: "coopnorge-renovate <121964725+coopnorge-renovate[bot]@users.noreply.github.com>"
          # Use GitHub API to create commits (this allows for signed commits from GitHub App)
          RENOVATE_PLATFORM_COMMIT: "true"
          # Override schedule if set
          RENOVATE_FORCE: "true"
          #RENOVATE_FORCE: ${{ github.event.inputs.overrideSchedule == 'true' && '{''schedule'':null}' || '' }}
          LOG_LEVEL: ${{ inputs.logLevel || 'info' }}
        with:
          configurationFile: .github/renovate.json
          token: ${{ steps.get_token.outputs.token }}
```

```json title=".github/renovate.json"
{
    "baseBranches": ["main"],
    "rebaseWhen": "conflicted",
    "labels": ["dependencies","renovate"],
    "automergeStrategy": "merge-commit",
    "enabledManagers": ["helmv3"],
    "packageRules": [
        {
            "matchDatasources" : ["helm"],
            "automerge": true
        }
    ]
}
```

In addition, make the following changes to allow automatic merging of helm chart
updates:

```yaml title=".policy.yml"
# .policy.yml
policy:
  approval:
    - or:
        # - ...
        # - ...
        - Renovatebot update

approval_rules:
  # ...
  # ...
  # ...

  - name: Renovatebot update
    requires:
      count: 1
      teams:
        - "coopnorge/engineering"
    options:
      invalidate_on_push: true
      request_review:
        enabled: true
        mode: all-users
      methods:
        github_review: true
    if:
      only_has_contributors_in:
        users:
          - "renovate-coop-norge[bot]"
      only_changed_files:
        paths:
          - "^infrastructure/kubernetes/helm/.*/Chart\\.(yaml|lock)$"
      has_valid_signatures_by_keys:
        key_ids: ["B5690EEEBB952194"]
```

[renovate bot]: https://github.com/renovatebot/renovate
