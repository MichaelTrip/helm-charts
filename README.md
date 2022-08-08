# MichaelTrip Helm Charts Repo

This is the MichaelTrip charts repository.

### Helm Documentation

https://github.com/kubernetes/helm/blob/master/docs/index.md

### Install helm on minishift

https://blog.openshift.com/deploy-helm-charts-minishifts-openshift-local-development/

### How It Works

We use the master branch to store our charts code, and gh-pages branch as the charts repository.

GitHub Pages points to the `docs` folder and our repository is accessible on https://michaeltrip.github.io/helm-charts

### Add this repo to helm

```
helm repo add michaeltrip https://michaeltrip.github.io/helm-charts
```

### Add a chart

Create a chart and put it in the `charts` directory. Github actions will do rest.


### Github Action workflow

A workflow in the `.github/workflows/release.yaml` is created to auto release new charts. https://github.com/helm/chart-releaser-action

### Github pages

Make sure you create a `gh-pages` branch for the Github action workflow to work correctly.

### Hello-world chart

The hello-world chart was created from a [tutorial](https://hackernoon.com/the-missing-ci-cd-kubernetes-component-helm-package-manager-1fe002aac680) on charts. It's here as an example to understand basic concepts of charts.

